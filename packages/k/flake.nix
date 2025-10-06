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
            if [ -z "$kak_server" ]; then
                kak_server=$(echo inode_$(ls -id . | awk '{print $1}'))
                setsid -f kak -d -s $kak_server
                while [-z $(kak -l | grep $kak_server ) ]
                do
                    sleep 0.1
                done

            fi
            printf 'eval %%sh{
                client=$(echo $kak_client_list | awk \"{print \$1}");
                if [ -n "$client" ]; then
                    echo evaluate-commands -client $client edit %s
                else
                    echo new edit %s
                fi
            }' $1 $1 | kak -p $kak_server
          '';
        };
      }
    );
}
