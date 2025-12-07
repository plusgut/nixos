define-command -override lsp-show-goto-buffer -params 4 %{
    evaluate-commands %sh{
        echo "$4" | awk 'match($0, /^((.)+?:[0-9]+:[0-9]+):/, a){print a[1]}' | ffzf |  awk 'match($0, /^(.+?):([0-9]+):([0-9]+)/, a){print "edit " a[1] " " a[2] " " a[3]}'
    }
}
