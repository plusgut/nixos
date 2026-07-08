function fzf-git-widget
    set -l result $(git status -s -uall | ffzf --scheme=path  --accept-nth 2 --preview "fzf-preview {2}")
    and commandline -rt -- (string join -- ' ' $result)

    commandline -f repaint
end
