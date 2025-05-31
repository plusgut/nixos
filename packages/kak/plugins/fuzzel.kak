define-command pick-buffers -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    BUFFER=$(printf "%s\n" "${kak_buflist}" | tr " " "\n" | fuzzel --dmenu | tr -d \')
    if [ -n "$BUFFER" ]; then
      printf "%s\n" "buffer ${BUFFER}"
    fi
  }
}
