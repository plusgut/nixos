define-command pick-buffers -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    BUFFER=$(printf "%s\n" "${kak_buflist}" | tr " " "\n" | grep -v "*" | ffzf --scheme=path --preview 'bat --style=numbers,changes --color=always  {}')
    if [ -n "$BUFFER" ]; then
      printf "buffer %s\n" "${BUFFER}"
    fi
  }
}

define-command pick-file -docstring 'Select an open buffer using fuzzel' %{
  evaluate-commands %sh{
    query="--prompt=>" # Workaround of needing a valid default-option
    if [ -n "$kak_buffile" ]; then
      directory=$(realpath --relative-base=$PWD $(dirname $kak_buffile))
      if [ "$directory" != "." ]; then
        query="--query=^$directory/ "
      fi
    fi

    buffer=$(fd  --hidden --exclude .git --type f | ffzf "$query" --scheme=path  --preview 'bat --style=numbers,changes --color=always  {}')

    if [ -n "$buffer" ]; then
      printf "edit %s\n" "${buffer}"
    fi
  }
}

