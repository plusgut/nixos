#! /usr/bin/env sh

fifo=$1

read_fifo() {
    while IFS= read -r stdin; do
        available_lines=$(tput lines)
        line=${stdin##*:}
        file=${stdin%%:*}
        context=$(calc "floor($available_lines / 2) - 1")
        from=$(calc "$line - $context")
        if [ $from -lt 0 ]; then
            from=0
        fi
        to=$(calc "$from + $available_lines - 2")
        range=$(printf "%s:%s" $from $to)
        bat -p --highlight-line $line -r $range $file
    done < $fifo

    read_fifo
}

read_fifo

rm -f $temp
