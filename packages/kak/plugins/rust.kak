hook global WinSetOption filetype=rust %{
    set-option buffer formatcmd 'rustfmt'

    hook window BufWritePre .* format
}

