{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    qtile = {
      url = "github:qtile/qtile";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, qtile }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = pkgs.python3.withPackages (_p: [
            (pkgs.python3.pkgs.qtile.overrideAttrs {
              src = qtile;
              patches = [
                (pkgs.fetchpatch {
                  url = "https://github.com/plusgut/qtile/commit/4772c2fca9c8570652247ba2c813c414ab5e5f64.patch";
                  hash = "sha256-vUn1se0coAfkZZ8qwGDLoweLbp2OU+CyUHKsPWzqL0E=";
                })
              ];
            })
            pkgs.wlroots_0_16
            pkgs.python3.pkgs.pyxdg
          ]);
          swaybg = pkgs.swaybg;
          swaylock = pkgs.swaylock;
        };

      }
    );
}
