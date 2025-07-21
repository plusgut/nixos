function __k_getinode
    echo inode_$(ls -id $argv[1] | awk '{print $1}')
end

function kak-get-server
    set -l servers $(kak -l)
    set -l cwd $(pwd)
    set -l search $cwd

    while true
        if test $search = "/"
            return 1
        else
            set -l inode $(__k_getinode $search)
            set -l index $(contains -i $inode $servers)
            if test -z $index
                set search $(path normalize $search/..)
            else
                echo $servers[$index]
                return 0
            end
        end
    end
end
