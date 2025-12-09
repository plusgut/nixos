{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    kak-tree-sitter = {
      flake = false;
      url = "sourcehut:~hadronized/kak-tree-sitter";
    };
  };
  outputs = { self, nixpkgs, flake-utils, kak-tree-sitter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = pkgs.rustPlatform.buildRustPackage {
            name = "kak-tree-sitter";
            src = kak-tree-sitter;
            cargoHash = "sha256-G4GBpoFiL/len/uE9CFPRwQPYAAMOhXZEDzV0BvRdRQ=";
          };
        };
      }
    );
}
