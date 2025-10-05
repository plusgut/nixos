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
          default = (pkgs.makeDesktopItem {
            name = "k";
            desktopName = "k";
            exec = ''
                k-open
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
          k-open = pkgs.writeShellScriptBin "k-open" ''
            kak_server=$(fish -c kak-get-server)
            if [ -n "$kak_server" ]; then
                echo edit $@ | kak -p $kak_server
            else
                setsid -f foot -D . fish -liC "k $@"
            fi
          '';
        };
      }
    );
}
