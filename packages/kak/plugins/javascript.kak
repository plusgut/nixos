hook global WinSetOption filetype=(javascript|typescript) %{
  eval %sh{
    if command -v prettier >/dev/null 2>&1; then
      echo set-option window formatcmd \"prettier --stdin-filepath=%val{buffile}\"
    elif command -v oxfmt >/dev/null 2>&1; then
      echo set-option window formatcmd \"oxfmt --stdin-filepath=%val{buffile}\"
    else
      echo nop
    fi
  }
}

hook global BufWritePre .*\.(js|ts)x? %{
  evaluate-commands format
}

# define-command -override -hidden tree-sitter-initial-set-buffer-lang %{
#   evaluate-commands -buffer "*" %{
#     set-option buffer tree_sitter_lang %sh{
#         if [ "${kak_opt_filetype}" == "typescript" ]; then
#             echo "tsx"
#         elif [ "${kak_opt_filetype}" == "javascript" ]; then
#             echo "jsx"
#         else
#             echo "${kak_opt_filetype}"
#         fi
#     }
#   }
# }

