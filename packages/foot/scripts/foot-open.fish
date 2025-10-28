#! /usr/bin/env fish

set -l normalized_path $(echo $argv[1] | awk "/^\// {print \"file://$hostname\"\$1} ""!/^\// {print \$1}")

xdg-open $normalized_path
