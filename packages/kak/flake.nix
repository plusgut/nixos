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
            kak-open-desktop = (pkgs.makeDesktopItem {
            name = "k";
            desktopName = "k";
            exec = ''
                kak-open %u
            '';
            mimeTypes = [
              "text/english"
              "text/plain"
              "text/x-makefile"
              "text/x-c++hdr"
              "text/x-c++src"
              "text/x-chdr"
              "text/x-csrc"
              "text/x-java"
              "text/x-moc"
              "text/x-pascal"
              "text/x-tcl"
              "text/x-tex"
              "application/x-shellscript"
              "text/x-c"
              "text/x-c++"
            ];
          });
          kak-open = pkgs.writeScriptBin "kak-open" (builtins.readFile ./scripts/kak-open);
          kak-get-server = pkgs.writeScriptBin "kak-get-server" (builtins.readFile ./scripts/kak-get-server.fish);
          kak-get-bufferfiles = pkgs.writeScriptBin "kak-get-bufferfiles" (builtins.readFile ./scripts/kak-get-bufferfiles.fish);
        };
      }
    );
}
