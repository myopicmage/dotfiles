---
name: nix-dev-env
description: Nix dev-shell quirks for BRBAviation — flake.nix location, the correct `nix develop` invocation, running test/lint/build commands, Xcode version selection, and the gcloud/beta-macOS workaround. Use whenever running a command that needs the nix devshell (npm test, npm run lint, npm run build, xcodebuild), whenever `nix develop` fails with a missing flake.nix error, or when deciding which Xcode to build with.
---

# Nix dev environment (BRBAviation)

## flake.nix + flake.lock are tracked on both `main` and `staging`

**Updated 2026-07-17:** both `flake.nix` AND `flake.lock` are now git-tracked on
`main` and `staging` (flake.lock was committed to main then merged to staging).
A fresh clone or worktree off either branch has both, so `nix develop` works
out of the box — no need to copy `flake.nix` in from a staging checkout anymore.

(Historical: `flake.lock` used to be missing and `flake.nix` was once only on
`staging`. If you're ever on some old branch/worktree that lacks one, fetch it:
`git show origin/main:flake.nix > flake.nix` — but this shouldn't happen now.)

## Always use `nix develop 'path:.'`, never `nix develop .`

`nix develop .` and direnv's `use flake .` resolve relative to the *git tree*,
which can exclude `flake.nix` depending on branch/worktree state (see above) —
this makes them fail even when the file is sitting right there on disk. The
filesystem-path form sidesteps that:

```bash
nix develop 'path:.'                          # from repo root
nix develop 'path:..' --command <cmd>          # from a subdirectory, e.g. web/ or firebase-tests/
```

`.envrc` is wired the same way (`use flake "path:$PWD"`), so direnv picks up the
shell automatically once you `cd` into the repo — no need to invoke `nix
develop` by hand in an interactive shell.

## Standard commands

Run each from the stated directory:

| What | Where | Command |
|---|---|---|
| Firestore/Storage rules tests | `firebase-tests/` | `nix develop 'path:..' --command npm test` |
| Web unit tests (vitest) | `web/` | `nix develop 'path:..' --command npm test -- --run` |
| Web e2e (Playwright, emulator) | `web/` | `nix develop 'path:..' --command npm run e2e` |
| Web lint | `web/` | `nix develop 'path:..' --command npm run lint` |
| Web typecheck + build | `web/` | `nix develop 'path:..' --command npm run build` |
| Functions build/lint/test | `functions/` | `nix develop 'path:..' --command npm test` (run `npm install` first if `@stylistic/eslint-plugin` or similar is missing after a merge) |

After merging in dependency changes (e.g. a `package.json` update from
`staging`), run `npm install` inside the nix shell before lint/build/test —
otherwise you'll hit `ERR_MODULE_NOT_FOUND` for newly-added ESLint plugins etc.

## iOS builds: which Xcode

The Mac runs a **beta macOS (27.0)**, and there are two Xcodes installed:

- **`/Applications/Xcode.app` = 26.6 GA** — use this for App Store / TestFlight
  archives (Apple rejects beta-Xcode builds). Verified working for device
  builds (`generic/platform=iOS`) and the iOS unit test target.
- **`/Applications/Xcode-beta.app` = 27 beta** — fine for simulator builds only,
  never for submission.

Set `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` when you need
26.6 specifically.

## Building iOS inside the nix shell works (post-fix)

Nix's `mkShell` used to force `DEVELOPER_DIR`/`SDKROOT`/`CC` onto a nix
`apple-sdk` store path with no real Swift toolchain, breaking SourceKit
("Loading the standard library failed") and `xcodebuild` (gRPC/C++ compile
errors). `flake.nix` now uses `pkgs.mkShellNoCC` with a `shellHook` that:

- sets `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- unsets `SDKROOT MACOSX_DEPLOYMENT_TARGET CC CXX LD AR NM OBJCOPY
  NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_BINTOOLS LD_DYLD_PATH`

So `xcodebuild` and simulator/emulator runs both work fine **inside**
`nix develop 'path:.'` now. If you ever land in a shell that has the nix
toolchain vars injected but *not* this shellHook (e.g. a stale environment),
strip them manually as a fallback:

```bash
env -u CC -u CXX -u LD -u AR -u NM -u OBJCOPY -u SDKROOT \
  -u MACOSX_DEPLOYMENT_TARGET -u LD_DYLD_PATH -u NIX_CFLAGS_COMPILE \
  -u NIX_LDFLAGS -u NIX_CC -u NIX_BINTOOLS \
  xcodebuild build -project BRBAviation.xcodeproj -scheme BRBAviation \
  -destination 'platform=iOS Simulator,id=<UDID>' COMPILER_INDEX_STORE_ENABLE=NO -quiet
```

## gcloud doesn't work through nix on this machine

Both nix's `google-cloud-sdk` package and `brew install --cask gcloud-cli` fail
on this beta macOS (nix: libffi/Python trampoline crash; brew: "unknown macOS
version"). gcloud is installed from the **official Google tarball** at
`~/google-cloud-sdk` instead. For a shell session:

```bash
source ~/google-cloud-sdk/path.zsh.inc
```

It is *not* on `PATH` by default and is *not* managed by nix.
