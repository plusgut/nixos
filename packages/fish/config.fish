# alias cd="_ZO_ECHO=1 z"
alias cd="z"
alias codium="codium --ozone-platform-hint=auto"
alias rm="rip"
alias ls="lsd --hyperlink auto"
alias ll="lsd --long --almost-all --hyperlink auto --git"
alias rg="rg --hyperlink-format='file://{host}{path}#{line}:{column}'"
alias fd="fd --hyperlink=auto"

if status is-interactive
    set -g fish_prompt_pwd_dir_length 0
    set -x STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/config.toml
    set -g FZF_FILE_OPTS "--preview \"fzf-file-preview \$dir/{}\""
    set -g FZF_CTRL_T_COMMAND "fd --hidden --base-directory \$dir --type f --strip-cwd-prefix"
    set -g FZF_CTRL_T_OPTS $FZF_FILE_OPTS
    set -g FZF_ALT_C_COMMAND "fd --hidden --base-directory \$dir --type d --strip-cwd-prefix" 
    set -g FZF_ALT_C_OPTS $FZF_FILE_OPTS
    set -x DIRPREVARROW 󰧀
    set -x DIRNEXTARROW 󰧂

    starship init fish | source
    zoxide init fish | source
    direnv hook fish | source
    fzf --fish | source

    function fish_right_prompt
	if test -n "$dirprev"
            set -x DIRPREVARROW 󰜱
        else
            set -x DIRPREVARROW 󰧀
        end

        if test -n "$dirnext"
            set -x DIRNEXTARROW 󰜴
        else
            set -x DIRNEXTARROW 󰧂
        end

        switch "$fish_key_bindings"
            case fish_hybrid_key_bindings fish_vi_key_bindings
                set STARSHIP_KEYMAP "$fish_bind_mode"
            case '*'
                set STARSHIP_KEYMAP insert
        end
        set STARSHIP_CMD_PIPESTATUS $pipestatus
        set STARSHIP_CMD_STATUS $status
        # Account for changes in variable name between v2.7 and v3.0
        set STARSHIP_DURATION "$CMD_DURATION$cmd_duration"
        set STARSHIP_JOBS (count (jobs -p))
        if test "$RIGHT_TRANSIENT" = "1"
            set -g RIGHT_TRANSIENT 0
            if type -q starship_transient_rprompt_func
                starship_transient_rprompt_func --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
            else
                printf ""
            end
        else
            /run/current-system/sw/bin/starship prompt --right --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
        end
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

    abbr --add gco git checkout
    abbr --add gs git status
    abbr --add gd git diff
    abbr --add ga git add
    abbr --add gc git commit
    abbr --add gp git push
    abbr --add gu git pull
    abbr --add gl git log --all --graph
    abbr --add gb git branch
    abbr --add ga git add

    bind ctrl-h prevd-or-backward-word 
    bind ctrl-l nextd-or-forward-word
    bind ctrl-g fzf-git-widget
    bind ctrl-b fzf-buffer-widget
end
