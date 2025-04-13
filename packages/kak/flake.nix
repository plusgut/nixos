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
            KAK_SESSION=ide_$$; EDITOR="ide-edit $KAK_SESSION"; broot --listen=$KAK_SESSION
          '';
          ide-edit = pkgs.writeShellScriptBin "ide-edit" ''
            echo $1 $2> /home/plusgut/ide.log
            if kak -l | grep -wq $1
            then
              echo "ide-edit $2" | kak -p $1;
            else
              $TERM kak -s $1 $2 > /dev/null &
            fi
          '';
        };
      }
    );
}
