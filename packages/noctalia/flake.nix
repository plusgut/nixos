{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    noctalia = {
      url = "github:noctalia-dev/noctalia?ref=v5.0.0-beta.10";
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
