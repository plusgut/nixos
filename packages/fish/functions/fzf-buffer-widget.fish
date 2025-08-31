function fzf-buffer-widget
    set -l result $(kak-get-bufferfiles $(kak-get-server) | string match $PWD"/*" | string sub -s $(string length $PWD"//" ) | fzf --preview "fzf-file-preview {}")
    and commandline -rt -- (string join -- ' ' $result)

    commandline -f repaint
end
