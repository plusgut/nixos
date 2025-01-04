{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          default = pkgs.eww;
          niri-bar = pkgs.writeShellScriptBin "niri-bar" ''
            NODE_NO_WARNINGS=1 ${pkgs.nodejs_22}/bin/node --experimental-transform-types ./niri-bar.ts
          '';
          screencast-on = pkgs.writeShellScriptBin "screencast-on" ''
            NODE_NO_WARNINGS=1 ${pkgs.nodejs_22}/bin/node --experimental-transform-types ./screencast-on.ts
          '';
        };
      }
    );
}
