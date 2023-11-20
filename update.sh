sudo sh -c 'find . -name flake.nix -execdir nix flake --extra-experimental-features nix-command --extra-experimental-features flakes update --commit-lock-file \; ;nixos-rebuild switch --impure --flake ".#"'
git push
