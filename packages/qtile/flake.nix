
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default = pkgs.python3.withPackages (_p: [
              pkgs.python3.pkgs.qtile
              pkgs.python3.pkgs.catppuccin
            ]);
            swaybg = pkgs.swaybg;
        };

    }
  );
}
