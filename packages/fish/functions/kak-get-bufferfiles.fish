function kak-get-bufferfiles
    set -l tempdir $(mktemp -d -t kak-temp-XXXXXXXX)
    set -l output $tempdir/fifo
    mkfifo $output
    # we ask the session to write the value of 'modified' for the current buffer of the list
    printf 'try %%{ evaluate-commands -try-client "%s" %%{ echo -to-file %s %%val{buflist} } }' "client0" "$output" | kak -p $argv[1]
    # read the value ASAP and delete FIFO to avoid lag in client
    set -l mod $(timeout 2s cat $output)
    echo $mod | tr ' ' '\n'
    rm  $tempdir
end
