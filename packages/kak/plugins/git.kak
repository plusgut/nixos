declare-user-mode git

map global git a -docstring "add" ":git add<ret>"
map global git c -docstring "commit" ":git commit<ret>"
map global git p -docstring "push" ":git push<ret>"
map global git f -docstring "fuzzy" ":pick-modified<ret>"

