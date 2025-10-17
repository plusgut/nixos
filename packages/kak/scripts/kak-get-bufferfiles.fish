#! /usr/bin/env fish

set -l tempdir $(mktemp -d -t kak-temp-XXXXXXXX)
set -l output $tempdir/fifo
mkfifo $output
# we ask the session to write the value of 'modified' for the current buffer of the list
printf 'try %%{ evaluate-commands %%{ echo -to-file %s %%sh{ echo $kak_buflist | awk -v RS=\'[\n ]\' \'!/^\*/{print ENVIRON["PWD"] "/" $1}\' } } }' "$output" | kak -p $argv[1]
# read the value ASAP and delete FIFO to avoid lag in client
set -l mod $(timeout 2s cat $output)
echo $mod | tr ' ' '\n'
rm  $tempdir

