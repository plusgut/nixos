#! /usr/bin/env fish
set -l args
if test $(count $argv) -gt 0
    set args $(printf '%s\n' $argv | string escape)
end

foot --app-id "float-foot" --working-directory . --fullscreen fish -c "fzf $args < /proc/$fish_pid/fd/0 > /proc/$fish_pid/fd/1 2> /proc/$fish_pid/fd/2"
