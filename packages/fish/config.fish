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
alias cd="z"
alias codium="codium --ozone-platform-hint=auto"
alias rm="rip"
alias ls="lsd --hyperlink auto"
alias ll="lsd --long --almost-all --hyperlink auto --git"
