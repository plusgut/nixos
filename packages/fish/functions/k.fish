function __k_getinode
    echo inode_$(ls -id $argv[1] | awk '{print $1}')
end

function k
    set -l result $(kak-get-server)
    if test -z $result
        set -l inode $(__k_getinode $cwd)
        setsid -f kak -d -s $inode
        while not contains $inode $(kak -l)
             sleep 0.1
        end

        set result $inode
    end

    if string match -r -g "^(?<path>.+?):(?<line>\d+(:\d+)?)\$" $argv > /dev/null 2> /dev/null
        kak -c $result +$line $path
    else
        kak -c $result $argv
    end
end
