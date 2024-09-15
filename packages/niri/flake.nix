{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    niri = {
        url = "github:YaLTeR/niri/event-stream";
    };
  };
  outputs = { self, nixpkgs, flake-utils, niri }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = pkgs.niri;
        };
      }
    );
}
