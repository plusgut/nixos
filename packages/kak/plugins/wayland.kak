define-command -override wayland-terminal-tab -params 1.. -docstring '
wayland-terminal-window <program> [<arguments>]: create a new terminal as a Wayland window
The program passed as argument will be executed in the new terminal' \
%{
    evaluate-commands -save-regs 'a' %{
        set-register a %arg{@}
        evaluate-commands %sh{
            if [ -z "${kak_opt_termcmd}" ]; then
                echo "fail 'termcmd option is not set'"
                exit
            fi
            termcmd=$kak_opt_termcmd
            args=$kak_quoted_reg_a
            unset kak_opt_termcmd kak_quoted_reg_a
            setsid ${termcmd} "$args" < /dev/null > /dev/null 2>&1 &
        }
    }
}

define-command -override wayland-terminal-floating -params 1.. -docstring '
wayland-terminal-window <program> [<arguments>]: create a new floating terminal as a Wayland window
The program passed as argument will be executed in the new terminal' \
%{
    evaluate-commands -save-regs 'a' %{
        set-register a %arg{@}
        evaluate-commands %sh{
            if [ -z "${kak_opt_termcmd}" ]; then
                echo "fail 'termcmd option is not set'"
                exit
            fi
            termcmd=$kak_opt_termcmd
            args=$kak_quoted_reg_a
            unset kak_opt_termcmd kak_quoted_reg_a
            setsid foot --app-id=floating -m sh -c "$args"< /dev/null > /dev/null 2>&1 &
        }
    }
}
