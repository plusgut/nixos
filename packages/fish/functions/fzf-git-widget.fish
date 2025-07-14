function fzf-git-widget
    set -l result $(git status -s | awk '{print $2}' | fzf --preview "fzf-file-preview {}")
    and commandline -rt -- (string join -- ' ' $result)

    commandline -f repaint
end
