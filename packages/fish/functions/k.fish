function k
    set -g servers $(kak -l)
    set -l cwd $(pwd)

    function __k_getinode
        echo inode_$(ls -id $argv[1] | awk '{print $1}')
    end

    function __k_search
        if test $argv[1] = "/"
            set -l inode $(__k_getinode $(pwd))
            setsid -f kak -d -s $inode
            sleep 0.5
            echo $inode
        else
            set -l inode $(__k_getinode $argv[1])
            set -l index $(contains -i $inode $servers)
            if test -z $index
                __k_search $(path normalize $(echo $argv/..))
            else
                echo $servers[$index]
            end
        end
    end

    kak -c $(__k_search $(pwd)) $argv
end
