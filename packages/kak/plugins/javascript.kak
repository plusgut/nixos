hook global WinSetOption filetype=(javascript|typescript) %{
  set-option window lintcmd 'run() { cat "$1" |npx eslint -f unix --stdin --stdin-filename "$kak_buffile";} && run'
}

