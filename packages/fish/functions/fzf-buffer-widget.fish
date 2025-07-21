function fzf-buffer-widget
    set -l result $(kak-get-bufferfiles $(kak-get-server) | fzf --preview "fzf-file-preview {}")
    and commandline -rt -- (string join -- ' ' $result)

    commandline -f repaint
end
