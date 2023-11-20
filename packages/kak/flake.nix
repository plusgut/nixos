
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
  outputs = { self, nixpkgs, flake-utils, kak-auto-pairs, kak-wakatime, kak-active-window }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        packages = {
            default =
                (pkgs.kakoune.override {
                  plugins = with pkgs.kakounePlugins; [
                    (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
                      pname = "auto-pairs";
                      version = "master";
                      src = kak-auto-pairs;
                    })
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
            kakoune-cr = pkgs.kakoune-cr;
        };
    }
  );
}
