#!/usr/bin/env python3
"""Choose a recency-weighted learning-mode go-word and record its use."""

from __future__ import annotations

import argparse
import csv
import math
import os
import random
import tempfile
from dataclasses import dataclass, replace
from datetime import datetime
from pathlib import Path
from typing import Sequence


FIELDS = ("word", "language", "last_used_at")


@dataclass(frozen=True)
class GoWord:
    word: str
    language: str
    last_used_at: datetime | None


class GoWordError(ValueError):
    """Raised when the catalog or state file is invalid."""


def parse_timestamp(value: str, *, path: Path, line_number: int) -> datetime | None:
    if not value or value == "never":
        return None

    try:
        timestamp = datetime.fromisoformat(value)
    except ValueError as error:
        raise GoWordError(
            f"{path}:{line_number}: invalid ISO 8601 timestamp {value!r}"
        ) from error

    if timestamp.tzinfo is None:
        raise GoWordError(f"{path}:{line_number}: timestamp must include a time zone")

    return timestamp


def read_words(path: Path) -> list[GoWord]:
    try:
        source = path.open(encoding="utf-8", newline="")
    except OSError as error:
        raise GoWordError(f"cannot read {path}: {error}") from error

    with source:
        reader = csv.DictReader(source, delimiter="\t")
        if tuple(reader.fieldnames or ()) != FIELDS:
            expected = "\\t".join(FIELDS)
            raise GoWordError(f"{path}: expected header {expected!r}")

        words: list[GoWord] = []
        seen: set[str] = set()

        for line_number, row in enumerate(reader, start=2):
            word = row["word"].strip()
            language = row["language"].strip()

            if not word or not language:
                raise GoWordError(f"{path}:{line_number}: word and language are required")

            if word in seen:
                raise GoWordError(f"{path}:{line_number}: duplicate surface form {word!r}")

            seen.add(word)
            words.append(
                GoWord(
                    word=word,
                    language=language,
                    last_used_at=parse_timestamp(
                        row["last_used_at"].strip(),
                        path=path,
                        line_number=line_number,
                    ),
                )
            )

    if not words:
        raise GoWordError(f"{path}: catalog is empty")

    return words


def merge_state(catalog: Sequence[GoWord], state: Sequence[GoWord]) -> list[GoWord]:
    state_by_word = {entry.word: entry for entry in state}
    merged: list[GoWord] = []

    for entry in catalog:
        previous = state_by_word.get(entry.word)
        if previous is None:
            merged.append(entry)
            continue

        if previous.language != entry.language:
            raise GoWordError(
                f"language changed for {entry.word!r}: "
                f"{previous.language!r} to {entry.language!r}"
            )

        merged.append(replace(entry, last_used_at=previous.last_used_at))

    return merged


def selection_weight(entry: GoWord, now: datetime) -> float:
    if entry.last_used_at is None:
        raise GoWordError("unused words do not have recency weights")

    elapsed_hours = max((now - entry.last_used_at).total_seconds() / 3600, 0)
    return math.sqrt(elapsed_hours + 1)


def choose_word(
    words: Sequence[GoWord],
    *,
    now: datetime,
    rng: random.Random | random.SystemRandom,
) -> GoWord:
    unused = [entry for entry in words if entry.last_used_at is None]
    if unused:
        return rng.choice(unused)

    weights = [selection_weight(entry, now) for entry in words]
    return rng.choices(words, weights=weights, k=1)[0]


def write_words(path: Path, words: Sequence[GoWord]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent,
        prefix=f".{path.name}.",
        text=True,
    )

    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as target:
            writer = csv.DictWriter(
                target,
                fieldnames=FIELDS,
                delimiter="\t",
                lineterminator="\n",
            )
            writer.writeheader()
            for entry in words:
                writer.writerow(
                    {
                        "word": entry.word,
                        "language": entry.language,
                        "last_used_at": (
                            entry.last_used_at.isoformat(timespec="seconds")
                            if entry.last_used_at is not None
                            else ""
                        ),
                    }
                )
            target.flush()
            os.fsync(target.fileno())

        os.replace(temporary_name, path)
    except BaseException:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass
        raise


def select_and_record(
    *,
    catalog_path: Path,
    state_path: Path,
    now: datetime,
    rng: random.Random | random.SystemRandom,
) -> GoWord:
    catalog = read_words(catalog_path)
    state = read_words(state_path) if state_path.exists() else []
    words = merge_state(catalog, state)
    selected = choose_word(words, now=now, rng=rng)
    updated = [
        replace(entry, last_used_at=now) if entry.word == selected.word else entry
        for entry in words
    ]
    write_words(state_path, updated)
    return selected


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, required=True)
    parser.add_argument("--state", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    now = datetime.now().astimezone()

    try:
        selected = select_and_record(
            catalog_path=args.catalog,
            state_path=args.state,
            now=now,
            rng=random.SystemRandom(),
        )
    except GoWordError as error:
        raise SystemExit(f"go-word: {error}") from error

    print(f"{selected.word}\t{selected.language}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
