function fzf-buffer-widget
    set -l kak_session_id $(kak-get-server)
    if test -n "$kak_session_id"
        set -l result $(kak-get-bufferfiles $kak_session_id | string match $PWD"/*" | string sub -s $(string length $PWD"//" ) | fzf --preview "fzf-file-preview {}")
        and commandline -rt -- (string join -- ' ' $result)

        commandline -f repaint
    end
end
