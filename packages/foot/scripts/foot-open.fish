#! /usr/bin/env fish

set -l normalized_path $argv[1]

if string match -r "^(?<path>\/[^:#]+)+([:#](?<line>[0-9]+)(:(?<column>[0-9]+))?)?\$" $normalized_path > /dev/null
  set normalized_path "file://$hostname$path"
  if test -n "$line"
      set normalized_path "$normalized_path#$line"
      if test -n "$column"
          set normalized_path "$normalized_path:$column"
      end
  end
end

xdg-open $normalized_path
