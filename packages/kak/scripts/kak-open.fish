#! /usr/bin/env fish

set -l session $(kak-create-server)
set -l file $argv[1]

if string match -r '^file:\/\/(?<host>[^\/]*)(?<path>\/[^#]+)(#(?<line>[0-9]+)(:(?<column>[0-9]+))?)?$' $file > /dev/null
    set file $path $line $column
end

printf 'eval %%sh{
    client=$(echo $kak_client_list | awk \"{print \$1}");
    if [ -n "$client" ]; then
        echo evaluate-commands -client $client edit %s;
    else
        echo new edit %s;
    fi
}' "$file" "$file" | kak -p $session

