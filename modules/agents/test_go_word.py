import importlib.util
import random
import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("go_word.py")
SPEC = importlib.util.spec_from_file_location("go_word", MODULE_PATH)
assert SPEC is not None
assert SPEC.loader is not None
go_word = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = go_word
SPEC.loader.exec_module(go_word)

GoWord = go_word.GoWord
GoWordError = go_word.GoWordError
choose_word = go_word.choose_word
read_words = go_word.read_words
select_and_record = go_word.select_and_record
selection_weight = go_word.selection_weight


HEADER = "word\tlanguage\tlast_used_at\n"


class GoWordTests(unittest.TestCase):
    def test_tracked_catalog_is_valid(self) -> None:
        catalog = Path(__file__).with_name("go_words.tsv")

        words = read_words(catalog)

        self.assertGreaterEqual(len(words), 50)

    def test_unused_words_are_chosen_before_used_words(self) -> None:
        now = datetime(2026, 8, 3, tzinfo=timezone.utc)
        words = [
            GoWord("gaan", "Afrikaans", now - timedelta(days=30)),
            GoWord("kreni", "Croatian", None),
        ]

        selected = choose_word(words, now=now, rng=random.Random(4))

        self.assertEqual("kreni", selected.word)

    def test_recency_weight_increases_with_age(self) -> None:
        now = datetime(2026, 8, 3, tzinfo=timezone.utc)
        recent = GoWord("gaan", "Afrikaans", now - timedelta(hours=1))
        old = GoWord("kreni", "Croatian", now - timedelta(days=30))

        self.assertGreater(
            selection_weight(old, now),
            selection_weight(recent, now),
        )

    def test_select_and_record_initializes_and_updates_state(self) -> None:
        now = datetime(2026, 8, 3, 12, 30, tzinfo=timezone.utc)

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            catalog = root / "catalog.tsv"
            state = root / "state.tsv"
            catalog.write_text(
                HEADER + "gaan\tAfrikaans\t\n" + "kreni\tCroatian\t\n",
                encoding="utf-8",
            )

            selected = select_and_record(
                catalog_path=catalog,
                state_path=state,
                now=now,
                rng=random.Random(0),
            )
            saved = {entry.word: entry for entry in read_words(state)}

            self.assertIn(selected.word, saved)
            self.assertEqual(now, saved[selected.word].last_used_at)
            self.assertEqual({"gaan", "kreni"}, set(saved))

    def test_duplicate_surface_forms_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            catalog = Path(directory) / "catalog.tsv"
            catalog.write_text(
                HEADER + "gå\tSwedish\t\n" + "gå\tDanish\t\n",
                encoding="utf-8",
            )

            with self.assertRaisesRegex(GoWordError, "duplicate surface form"):
                read_words(catalog)


if __name__ == "__main__":
    unittest.main()
