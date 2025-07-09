if status is-interactive
    zoxide init fish | source
    starship init fish | source
    direnv hook fish | source
    fzf --fish | source
end

function fish_greeting
end

function fish_title
    # If we're connected via ssh, we print the hostname.
    set -l ssh
    set -q SSH_TTY
    and set ssh "["(prompt_hostname | string sub -l 10 | string collect)"]"
    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
        echo -- $ssh (string sub -l 20 -- $argv[1]) (prompt_pwd)
    else
        # Don't print "fish" because it's redundant
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- $ssh (string sub -l 20 -- $command) (prompt_pwd)
    end
end

set -g fish_prompt_pwd_dir_length 0
set -x STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/config.toml

# alias cd="_ZO_ECHO=1 z"
alias cd="z"
alias codium="codium --ozone-platform-hint=auto"
alias rm="rip"
alias ls="lsd --hyperlink auto"
alias ll="lsd --long --almost-all --hyperlink auto --git"

alias gs="git status"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gu="git pull"
alias gl="git log --all --graph"
alias gb="git branch"
alias gap="git add --patch"

bind \ch backward-bigword
bind \cl forward-bigword
