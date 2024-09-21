
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    kakoune = {
      url = "github:mawww/kakoune";
      flake = false;
    };
    kak-auto-pairs = {
      url = "github:alexherbo2/auto-pairs.kak";
      flake = false;
    };
    kak-wakatime = {
      url = "github:WhatNodyn/kakoune-wakatime";
      flake = false;
    };
    kak-active-window = {
      url = "github:greenfork/active-window.kak";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, kakoune, kak-auto-pairs, kak-wakatime, kak-active-window }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default = pkgs.kak-tree-sitter;
        };
    }
  );
}
