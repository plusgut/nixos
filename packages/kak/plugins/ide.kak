declare-option str last_client ""

define-command ide-edit -params 1 %{
  evaluate-commands %sh{
      if [ -n "$kak_opt_last_client" ]; then
        echo evaluate-commands -client $kak_opt_last_client e $1
      else
        echo new e $1
      fi
  }
}

hook global FocusIn .* %{
  set-option global last_client %val{client}
}

