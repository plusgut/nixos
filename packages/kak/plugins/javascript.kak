hook global WinSetOption filetype=(javascript|typescript) %{
  set-option window formatcmd "prettier --stdin-filepath=%val{buffile}"
}

