declare-option str last_client ""

define-command ide-edit -hidden -params 1 %{
  evaluate-commands %sh{
      if [ -n "$kak_opt_last_client" ]; then
        echo evaluate-commands -client $kak_opt_last_client e $1
      else
        echo new e $1
      fi
  }
}

define-command update-broot -hidden %{
  nop %sh{
    broot --send $kak_session -c ep/$(realpath $kak_buffile --relative-base=$(broot --send $kak_session --get-root) | sed 's;/;\\/;g')
  }
}

hook global FocusIn .* %{
  set-option global last_client %val{client}
}

hook global WinDisplay ^(?!\*).* %{
  update-broot
  hook global FocusIn -group foo .* update-broot
}

hook global WinDisplay ^\*.* %{
  remove-hooks global foo 
}


