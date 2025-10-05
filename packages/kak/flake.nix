{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    kakoune = {
      url = "github:mawww/kakoune";
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
  outputs = { self, nixpkgs, flake-utils, kakoune, kak-wakatime, kak-active-window }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default =
            (pkgs.wrapKakoune pkgs.kakoune-unwrapped {
              plugins = with pkgs.kakounePlugins; [
                (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
                  pname = "wakatime";
                  version = "master";
                  src = kak-wakatime;
                })
                (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
                  pname = "active-window";
                  version = "master";
                  src = kak-active-window;
                })
              ];
            });
        };
      }
    );
}
