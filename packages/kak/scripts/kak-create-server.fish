#! /usr/bin/env fish

set -l result $(kak-get-server)

if test -z $result
    set -l inode "inode_$(ls -id $cwd | awk '{print $1}')"
    setsid -f kak -d -s $inode
    while not contains $inode $(kak -l)
         sleep 0.1
    end

    set result $inode
end

echo $result

