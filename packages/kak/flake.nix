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
            default =
                (pkgs.wrapKakoune (pkgs.kakoune-unwrapped.overrideAttrs (oldAttrs: { src = kakoune; patches = []; })) {
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
            ide = pkgs.writeShellScriptBin "ide" ''
              KAK_SESSION=ide_$$
              kak -d -s $KAK_SESSION &
              KAK_SESSION_ID=$last_pid

              KAK_SESSION=$KAK_SESSION EDITOR=ide-edit broot --listen=$KAK_SESSION

              echo $KAK_SESSION_ID

              kill $KAK_SESSION_ID
            '';
            ide-edit = pkgs.writeShellScriptBin "ide-edit" ''
              echo "ide-edit $1" | kak -p $KAK_SESSION
            '';
        };
    }
  );
}
