
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ristate = {
        url = "git+https://gitlab.com/snakedye/ristate.git";
        flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ristate }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default = pkgs.river;
            ristate = pkgs.rustPlatform.buildRustPackage rec {
              pname = "ristate";
              version = "0.1.0";
              src = ristate;
              cargoLock.lockFile = ristate + "/Cargo.lock";
            };
        };
    }
  );
}
