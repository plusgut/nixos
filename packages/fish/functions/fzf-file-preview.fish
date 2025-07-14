function fzf-file-preview
    if path is --type file $argv[1]
        bat --style=full,-header-filesize --color=always $argv[1] 
    else if path is --type dir $argv[1]
        lsd --color=always $argv[1]
    end
end
