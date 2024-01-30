{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.writeTextDir
      "share/icons/default/index.theme"
      ''
        [Icon Theme]
        Name=Default
        Comment=Default Cursor Theme
        Inherits=phinger-cursors-light
      '';
  };
}
