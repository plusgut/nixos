if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
end

set -x STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/config.toml

zoxide init fish | source
starship init fish | source
direnv hook fish | source

# alias cd="_ZO_ECHO=1 z"
alias rm="rip"
