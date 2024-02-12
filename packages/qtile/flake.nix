
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    qtile = {
      url = "github:plusgut/qtile/cursor_size";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, qtile }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default = pkgs.python3.withPackages (_p: [
              (pkgs.python3.pkgs.qtile.overrideAttrs { src = qtile; })
              pkgs.wlroots_0_16
              pkgs.python3.pkgs.pyxdg
            ]);
            swaybg = pkgs.swaybg;
            swaylock = pkgs.swaylock;
        };

    }
  );
}
