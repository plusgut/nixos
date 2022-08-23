{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.plusgut-dell= nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./common.nix
        ./custom-dell.nix
      ];
    };
    nixosConfigurations.plusgut-lenovo= nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./common.nix
        ./custom-lenovo.nix
      ];
    };
  };
}
