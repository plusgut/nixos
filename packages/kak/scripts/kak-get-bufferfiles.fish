#! /usr/bin/env fish

set index 100

function end-on-signal -s SIGTERM
  set index 0
end

printf 'try %%{
  evaluate-commands %%{
    nop %%sh{
      echo $kak_buflist | awk -v RS=\'[\n ]\' \'!/^\*/{print ENVIRON["PWD"] "/" $1}\' > %s
      kill %s
    }
  }
}' "/proc/$fish_pid/fd/1" "$fish_pid" | kak -p $argv[1]

while test $index -gt 0
    sleep 0.01
    set index $(math $index - 1)
end
