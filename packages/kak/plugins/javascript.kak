hook global WinSetOption filetype=(javascript|typescript) %{
  set-option window formatcmd "prettier --stdin-filepath=%val{buffile}"
}

hook global BufWritePre .*\.(js|ts)x? %{
    evaluate-commands format
}

