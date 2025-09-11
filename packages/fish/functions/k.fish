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

    set -l args

    for arg in $argv
        if string match -r -g "^(?<path>.+?):(?<line>\d+(:\d+)?)\$" $arg > /dev/null 2> /dev/null
            set args $args +$line $path
        else
            set args $args $arg
        end
    end

    kak -c $result $args
end
