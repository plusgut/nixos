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
            (pkgs.wrapKakoune (pkgs.kakoune-unwrapped.overrideAttrs (oldAttrs: { src = kakoune; patches = [ ]; })) {
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
          kakoune-cr = pkgs.kakoune-cr;
          ide = pkgs.writeShellScriptBin "ide" ''
            KAK_SESSION=ide_$$ EDITOR=ide-edit broot --listen=$KAK_SESSION
          '';
          ide-edit = pkgs.writeShellScriptBin "ide-edit" ''
            if kak -l | grep -wq $KAK_SESSION
            then
              echo "ide-edit $1" | kak -p $KAK_SESSION;
            else
              $TERM kak -s $KAK_SESSION $1 > /dev/null &
            fi
          '';
        };
      }
    );
}
