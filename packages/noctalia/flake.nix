{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };
  };
  outputs = { self, nixpkgs, flake-utils, noctalia }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages = {
          default = noctalia.packages.${system}.default;
        };
      }
    );
}
