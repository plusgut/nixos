nix flake --extra-experimental-features nix-command --extra-experimental-features flakes update --commit-lock-file
sudo nixos-rebuild switch --impure --flake ".#"
git push
