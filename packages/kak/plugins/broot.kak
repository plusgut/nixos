map global user f -docstring "file explorer cwd" ":broot-cwd<ret>"

declare-option str last_client ""

define-command -override broot-cwd %{
  evaluate-commands %{
    terminal "env" "EDITOR=ide-edit %val{session}" "broot" "--listen" %val{session}
  }
}

define-command ide-edit -hidden -params 1 %{
  evaluate-commands %sh{
      if [ -n "$kak_opt_last_client" ]; then
        echo evaluate-commands -client $kak_opt_last_client e $1
      fi
  }
}

define-command update-broot -hidden %{
  nop %sh{
    ROOT_PATH=$(broot --send $kak_session --get-root 2> /dev/null)
    if [ -n "$ROOT_PATH" ]; then
        broot --send $kak_session -c ep/$(realpath $kak_buffile --relative-base=$ROOT_PATH | sed 's;/;\\/;g')
    fi
  }
}

hook global FocusIn .* %{
  set-option global last_client %val{client}
}

hook global WinDisplay ^(?!\*).* %{
  set-option global last_client %val{client}
  update-broot
  hook global FocusIn .* update-broot
}


