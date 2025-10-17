define-command pick-buffers -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    BUFFER=$(printf "%s\n" "${kak_buflist}" | tr " " "\n" | grep -v "*" | ffzf --preview 'bat --style=numbers,changes --color=always  {}')
    if [ -n "$BUFFER" ]; then
      printf "%s\n" "buffer ${BUFFER}"
    fi
  }
}
