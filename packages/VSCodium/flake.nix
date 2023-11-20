
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
    strictly-vscode-extension = {
      url = "github:strictly-lang/vscode-plugin/streams";
    };
  };
  outputs = { self, nixpkgs, flake-utils, nix-vscode-extensions, strictly-vscode-extension }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default =
                (pkgs.vscode-with-extensions.override {
                  vscode = pkgs.vscodium;
                  vscodeExtensions =
                    with nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
                      mkhl.direnv
                      haskell.haskell
                      justusadam.language-haskell
                      bbenoist.nix
                      rust-lang.rust-analyzer
                      wakatime.vscode-wakatime
                      dbaeumer.vscode-eslint
                      orta.vscode-jest
                      strictly-vscode-extension.packages.${system}.strictly
                    ];
                });
        };
    }
  );
}
