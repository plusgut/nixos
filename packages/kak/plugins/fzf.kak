define-command pick-buffers -docstring 'Select an open buffer using fzf' %{
  evaluate-commands %sh{
    BUFFER=$(printf "%s\n" "${kak_buflist}" | tr " " "\n" | grep -v "*" | ffzf --scheme=path --preview 'fzf-preview {}')
    if [ -n "$BUFFER" ]; then
      printf "buffer %s\n" "${BUFFER}"
    fi
  }
}

define-command pick-modified -docstring 'Select an changed file using fzf' %{
  evaluate-commands %sh{
    BUFFER=$(git status --short --porcelain | awk '!match($1, /D/){print $2}' | ffzf --scheme=path --preview 'fzf-preview {}')
    if [ -n "$BUFFER" ]; then
      printf "edit %s\n" "${BUFFER}"
    fi
  }
}

define-command pick-file -docstring 'Select an open buffer using fzf' %{
  evaluate-commands %sh{
    query="--prompt=>" # Workaround of needing a valid default-option
    if [ -n "$kak_buffile" ]; then
      directory=$(realpath --relative-base=$PWD $(dirname $kak_buffile))
      if [ "$directory" != "." ]; then
        query="--query=^$directory/ "
      fi
    fi

    buffer=$(fd  --hidden --exclude .git --type f | ffzf "$query" --scheme=path --preview 'fzf-preview  {}')

    if [ -n "$buffer" ]; then
      printf "edit %s\n" "${buffer}"
    fi
  }
}

define-command -override -hidden lsp-show-goto-buffer -params 4 %{
   evaluate-commands %sh{
        export FILE=$(realpath -m --relative-to=. $kak_buffile)
        echo "$4" | grep -v '^$' | awk 'match($0, /^%:(.+)/, a){print ENVIRON["FILE"] ":" a[1]} !/^%/{print $0}' | ffzf --scheme=path --delimiter=':\s*'  --preview='fzf-preview {1}:{2}' --preview-window="+{2}/2" --accept-nth "edit \"$3/{1}\" {2} {3}"
    }
}

# Needed to be overwritten, to avoid jumping to the start of the buffer
define-command -override -hidden lsp-show-document-symbol -params 4 -docstring "Render document symbols" %{
    lsp-show-goto-buffer *goto* lsp-document-symbol %arg{1} %arg{3}
}
