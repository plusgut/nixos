function __k_getinode
    echo inode_$(ls -id $argv[1] | awk '{print $1}')
end

function k
    set -l servers $(kak -l)
    set -l cwd $(pwd)
    set -l search $cwd
    set -l result

    while true
        if test $search = "/"
            set -l inode $(__k_getinode $cwd)
            setsid -f kak -d -s $inode
            while not contains $inode $(kak -l)
                 sleep 0.1
            end

            set result $inode
            break
        else
            set -l inode $(__k_getinode $search)
            set -l index $(contains -i $inode $servers)
            if test -z $index
                set search $(path normalize $search/..)
            else
                set result $servers[$index]
                break
            end
        end
    end

    kak -c $result $argv
end
