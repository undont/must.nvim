#!/usr/bin/env bash
# render a tmux pane to an image with freeze
# usage: shot.sh <pane> <output> [extra freeze flags]
set -euo pipefail

if (($# < 2)); then
    echo "usage: $0 <pane> <output> [freeze flags]" >&2
    exit 1
fi

pane=$1
output=$2
shift 2

tmux capture-pane -pet "$pane" |
    freeze --font.family "${FREEZE_FONT:-JetBrainsMono Nerd Font Mono}" \
        -c full --font.size 20 --language ansi -o "$output" "$@"
