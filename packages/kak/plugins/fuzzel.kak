define-command pick-buffers -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    BUFFER=$(printf "%s\n" "${kak_buflist}" | tr " " "\n" | grep -v "*" | ffzf --preview 'bat --style=numbers,changes --color=always  {}')
    if [ -n "$BUFFER" ]; then
      printf "buffer %s\n" "${BUFFER}"
    fi
  }
}

define-command pick-file -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    BUFFER=$(fd  --hidden --exclude .git --type f | ffzf --preview 'bat --style=numbers,changes --color=always  {}')
    if [ -n "$BUFFER" ]; then
      printf "edit %s\n" "${BUFFER}"
    fi
  }
}

