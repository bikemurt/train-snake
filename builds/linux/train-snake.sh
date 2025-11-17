#!/bin/sh
printf '\033c\033]0;%s\a' train-snake
base_path="$(dirname "$(realpath "$0")")"
"$base_path/train-snake.x86_64" "$@"
