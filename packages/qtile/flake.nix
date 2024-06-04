{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = pkgs.python3.withPackages (_p: [
            pkgs.python3.pkgs.qtile
            pkgs.wlroots_0_17
            pkgs.python3.pkgs.pyxdg
          ]);
          swaybg = pkgs.swaybg;
          swaylock = pkgs.swaylock;
        };

      }
    );
}
