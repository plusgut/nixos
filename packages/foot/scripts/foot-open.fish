#! /usr/bin/env fish

set -l normalized_path $argv[1]

if not string match -r "^\w+://.+" $normalized_path > /dev/null
  if string match -r "^[^/]" $normalized_path > /dev/null
      set normalized_path "$PWD/$normalized_path"
  end

  if string match -r "^(?<path>\/[^:#]+)+([:#](?<line>[0-9]+)(:(?<column>[0-9]+))?)?\$" $normalized_path > /dev/null
    echo match
    set normalized_path "file://$hostname$path"
    if test -n "$line"
        set normalized_path "$normalized_path#$line"
        if test -n "$column"
            set normalized_path "$normalized_path:$column"
        end
    end
  end
end

xdg-open $normalized_path
