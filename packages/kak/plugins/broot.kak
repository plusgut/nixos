map global user f -docstring "file explorer cwd" ": broot-cwd<ret>"
map global user F -docstring "file explorer current" ": broot-local<ret>"

define-command -override broot-cwd %{
  connect kitty-terminal-overlay sh -c %{
    EDITOR="kcr edit --" broot
  }
}

define-command -override broot-local %{
  connect kitty-terminal-overlay sh -c %{
    kcr get --raw --value bufname | EDITOR="kcr edit --" xargs -o broot -c ':toggle_preview'
  }
}
