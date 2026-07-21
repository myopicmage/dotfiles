#!/usr/bin/env bash
# Open a single iTerm2 window tiled into panes, one Claude Code session per
# directory. With no directory arguments it uses the current repo's worktrees
# (the main checkout plus everything `git worktree list` reports), which is the
# usual "one session per branch" setup.
#
#   claude-panes                      # a pane per worktree of the current repo
#   claude-panes ~/code/a ~/code/b    # a pane per named directory
#   claude-panes --cmd 'echo hi' .    # run something else instead of claude
#   claude-panes --dry-run            # print the AppleScript, open nothing

set -euo pipefail

cmd='claude'
dry_run=0
dirs=()

usage()
{
  sed -n '2,12p' "$0" | cut -c3-
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --cmd)
      cmd="$2"
      shift 2
      ;;
    -n|--dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage 0
      ;;
    --)
      shift
      dirs+=("$@")
      break
      ;;
    -*)
      echo "claude-panes: unknown option $1" >&2
      usage 1 >&2
      ;;
    *)
      dirs+=("$1")
      shift
      ;;
  esac
done

if [ ${#dirs[@]} -eq 0 ]; then
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "claude-panes: not in a git repo and no directories given" >&2
    exit 1
  fi
  while IFS= read -r line; do
    dirs+=("${line%% *}")
  done < <(git worktree list --porcelain | sed -n 's/^worktree //p')
fi

n=${#dirs[@]}
[ "$n" -gt 0 ] || { echo "claude-panes: nothing to open" >&2; exit 1; }

# Column-major tiling: ceil(sqrt(n)) columns, panes filled top-to-bottom.
cols=1
while [ $((cols * cols)) -lt "$n" ]; do
  cols=$((cols + 1))
done

# rows_c for each column, as evenly as we can split n panes across `cols`.
rows=()
remaining=$n
for ((c = 0; c < cols; c++)); do
  left=$((cols - c))
  r=$(((remaining + left - 1) / left))
  rows+=("$r")
  remaining=$((remaining - r))
done

esc()
{
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# `label` is what the pane's title shows: the branch for a worktree, else the
# directory's basename.
label()
{
  local dir="$1" branch
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [ -n "$branch" ] && [ "$branch" != HEAD ]; then
    printf '%s' "$branch"
  else
    printf '%s' "$(basename "$dir")"
  fi
}

{
  echo 'tell application "iTerm2"'
  echo '  activate'
  echo '  set w to (create window with default profile)'
  echo '  set s1 to (current session of w)'

  # Columns first: split the top-left pane vertically once per extra column.
  prev_col=1
  idx=1
  col_head=(1)
  for ((c = 1; c < cols; c++)); do
    idx=$((idx + 1))
    echo "  tell s${prev_col}"
    echo "    set s${idx} to (split vertically with same profile)"
    echo '  end tell'
    col_head+=("$idx")
    prev_col=$idx
  done

  # Then rows within each column.
  order=()
  for ((c = 0; c < cols; c++)); do
    head=${col_head[$c]}
    order+=("$head")
    prev=$head
    for ((r = 1; r < rows[c]; r++)); do
      idx=$((idx + 1))
      echo "  tell s${prev}"
      echo "    set s${idx} to (split horizontally with same profile)"
      echo '  end tell'
      order+=("$idx")
      prev=$idx
    done
  done

  # Finally point each pane at its directory and start the command.
  for ((i = 0; i < n; i++)); do
    dir=$(cd "${dirs[$i]}" && pwd)
    sess=${order[$i]}
    echo "  tell s${sess}"
    echo "    set name to \"$(esc "$(label "$dir")")\""
    echo "    write text \"cd $(esc "$dir") && $(esc "$cmd")\""
    echo '  end tell'
  done

  echo '  select s1'
  echo 'end tell'
} > /tmp/claude-panes.$$.applescript

if [ "$dry_run" -eq 1 ]; then
  cat /tmp/claude-panes.$$.applescript
  rm -f /tmp/claude-panes.$$.applescript
  exit 0
fi

osascript /tmp/claude-panes.$$.applescript
rm -f /tmp/claude-panes.$$.applescript
