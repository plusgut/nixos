
{
  inputs = {
    eww.url = "github:elkowar/eww";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    eww.inputs.nixpkgs.follows = "nixpkgs";
    eww.inputs.rust-overlay.follows = "rust-overlay";
  };
  outputs = { self, eww, nixpkgs, rust-overlay, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages = {
            default = eww.packages.${system}.default.override { withWayland = true; };
        };
    }
  );
}
