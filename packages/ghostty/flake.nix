{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };
  outputs = { self, nixpkgs, flake-utils, ghostty }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = ghostty.packages.${system}.default;
        };
      }
    );
}
