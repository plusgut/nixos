hook global WinSetOption filetype=(javascript|typescript) %{
  set-option window formatcmd "prettier --stdin-filepath=%val{buffile}"
}

hook global BufWritePre .*\.(js|ts)x? %{
    evaluate-commands format
}

define-command -override -hidden tree-sitter-initial-set-buffer-lang %{
  evaluate-commands -buffer "*" %{
    set-option buffer tree_sitter_lang %sh{
        if [ "${kak_opt_filetype}" == "typescript" ]; then
            echo "tsx"
        elif [ "${kak_opt_filetype}" == "javascript" ]; then
            echo "jsx"
        else
            echo "${kak_opt_filetype}"
        fi
    }
  }
}

