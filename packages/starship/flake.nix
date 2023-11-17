{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        duration = (pkgs.writeShellScriptBin "duration" ''
          ONE_SECOND=1
          ONE_MINUTE=$((ONE_SECOND * 60))
          ONE_HOUR=$((ONE_MINUTE * 60))
          ONE_DAY=$((ONE_HOUR * 24))
          ONE_MONTH=$((ONE_DAY * 31))
          ONE_YEAR=$((ONE_DAY * 365))

          NOW=$(date +%s)

          while read line
          do
              DIFF=$((NOW - line))

              SECONDS=$((DIFF / ONE_SECOND))
              MINUTES=$((DIFF / ONE_MINUTE))
              HOURS=$((DIFF / ONE_HOUR))
              DAYS=$((DIFF / ONE_DAY))
              MONTHS=$((DIFF / ONE_MONTH))
              YEARS=$((DIFF / ONE_YEAR))

              UNIT=""
              if [ $YEARS -ge 2 ]; then
          	UNIT="$YEARS years ago"
              elif [ $YEARS -ge 1 ]; then
          	UNIT="$YEARS year ago"

              elif [ $MONTHS -ge 2 ]; then
          	UNIT="$MONTHS months ago"
              elif [ $MONTHS -ge 1 ]; then
          	UNIT="$MONTHS month ago"

              elif [ $DAYS -ge 2 ]; then
          	UNIT="$DAYS days ago"
              elif [ $DAYS -ge 1 ]; then
          	UNIT="$DAYS day ago"

              elif [ $HOURS -ge 2 ]; then
          	UNIT="$HOURS hours ago"
              elif [ $HOURS -ge 1 ]; then
          	UNIT="$HOURS hours ago"

              elif [ $MINUTE -ge 2 ]; then
          	UNIT="$MINUTE minutes ago"
              elif [ $MINUTE -ge 1 ]; then
          	UNIT="$MINUTE minute ago"

              elif [ $SECOND -ge 2 ]; then
          	UNIT="$SECOND seconds ago"
              elif [ $SECOND -ge 1 ]; then
          	UNIT="$SECOND second ago"
              fi

              echo $UNIT
          done

        '');

      in { packages = { default = pkgs.writeShellScriptBin "starship" ''
           STARSHIP_CONFIG=/home/plusgut/nixos/packages/starship/config.toml ${pkgs.starship}/bin/starship $@
        ''; }; });
}
