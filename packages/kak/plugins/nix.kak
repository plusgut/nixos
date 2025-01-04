hook global BufSetOption filetype=nix %{
    set-option buffer formatcmd "nix fmt -- --"
}
