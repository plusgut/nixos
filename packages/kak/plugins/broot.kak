map global user f -docstring "file explorer cwd" ":broot-cwd<ret>"

define-command -override broot-cwd %{
  evaluate-commands %{
    terminal sh -c "EDITOR='ide-edit %val{session}'; broot --listen %val{session}"
  }
}

