{
  inputs = {
    ags.url = "github:aylur/ags";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, ags, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages = {
          default = ags.packages.${system}.default;
        };
      }
    );
}
