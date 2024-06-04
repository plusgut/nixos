map global user f -docstring "file explorer cwd" ":broot-cwd<ret>"
map global user F -docstring "file explorer current" ":broot-local<ret>"

define-command -override broot-cwd %{
  evaluate-commands %{
    set local windowing_placement floating
    connect terminal sh -c %{
      EDITOR="kcr edit --" broot
    }
  }
}

define-command -override broot-local %{
  evaluate-commands %{
    set local windowing_placement floating
    connect terminal sh -c %{
      kcr get --raw --value bufname | EDITOR="kcr edit --" xargs -o broot -c ':toggle_preview'
    }
  }
}
