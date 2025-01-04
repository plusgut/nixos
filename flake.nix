{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    helix = { url = "github:helix-editor/helix"; };
  };

  outputs = { self, nixpkgs, nixos-hardware, helix, ... }@attrs:
    let
      common = ({ pkgs, ... }:
        let
          flakes = builtins.listToAttrs
            (map
              (x:
                {
                  name = x;
                  value = builtins.getFlake (toString (./packages + "/${x}"));
                }
              )
              (builtins.filter
                (x: builtins.pathExists (./packages + "/${x}/flake.nix"))
                (builtins.attrNames (builtins.readDir ./packages))
              )
            );
        in
        {
          nix = {
            settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
              substituters = [ "https://helix.cachix.org" ];
              trusted-public-keys = [
                "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
              ];
            };
          };
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.chromium.commandLineArgs =
            "--enable-features=UseOzonePlatform --ozone-platform=wayland";

          system.autoUpgrade.enable = true;
          system.autoUpgrade.allowReboot = false;

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.systemd-boot.configurationLimit = 8;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.kernelPackages = pkgs.linuxPackages_latest;

          # networking.hstName = "nixos"; # Define your hostname.
          networking.wireless = {
              secretsFile = "/root/secrets/wireless.conf";
              enable = true; # Enables wireless support via wpa_supplicant.
              networks = {
                  BlackRain.pskRaw="ext:blackrain";
              };
          };

          # Set your time zone.
          time.timeZone = "Europe/Amsterdam";

          # The global useDHCP flag is deprecated, therefore explicitly set to false here.
          # Per-interface useDHCP will be mandatory in the future, so this generated config
          # replicates the default behaviour.
          networking.useDHCP = true;

          # Configure network proxy if necessary
          # networking.proxy.default = "http://user:password@proxy:port/";
          # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

          # Select internationalisation properties.
          # i18n.defaultLocale = "en_US.UTF-8";
          console = {
            #   font = "Lat2-Terminus16";
            keyMap = "de";
          };

          # Enable CUPS to print documents.
          # services.printing.enable = true;

          security.sudo.enable = true;
          security.rtkit.enable = true;

          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          services.fwupd.enable = true;

          services.printing = {
            enable = true;
            drivers = [ pkgs.gutenprint ];
          };

          services.avahi = {
            enable = true;
            nssmdns4 = true;
            publish.userServices = true;
          };

          services.tlp = { enable = true; };

          xdg = {
            portal = {
              enable = true;
              wlr.enable = true;
              extraPortals = with pkgs; [
                xdg-desktop-portal-wlr
                xdg-desktop-portal-gnome
                xdg-desktop-portal-gtk
              ];
              config = {
                qtile = {
                  default = ["wlr" "gtk"];
                };
                niri-session = {
                  default = ["gnome" "gtk"];
                };
                niri = {
                  default = ["gnome" "gtk"];
                };
              };
            };
            icons.enable = true;
          };

          users.users.root.initialHashedPassword = "";
          # Define a user account. Don't forget to set a password with ‘passwd’.
          users.users.plusgut = {
            isNormalUser = true;
            extraGroups = [ "wheel" "sudo" ]; # Enable ‘sudo’ for the user.
            shell = pkgs.fish;
          };


          environment.loginShellInit = ''
            if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
                # Reset failed state of all user units.
                systemctl --user reset-failed

                # Import the login manager environment.
                systemctl --user import-environment

                dbus-update-activation-environment --all

                # Start niri and wait for it to terminate.
                systemctl --user --wait start niri.service

                # Force stop of graphical-session.target.
                systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target

                # Unset environment that we've set.
                systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
            fi
          '';

          environment.sessionVariables = {
            MOZ_ENABLE_WAYLAND = "1";
            QT_SCALE_FACTOR = "2";
            NIXOS_OZONE_WL = "1";
            XDG_CURRENT_DESKTOP = "qtile";
            XDG_CONFIG_HOME = "/home/plusgut/nixos/packages";
            CHROME_BIN = "chromium";
            EDITOR = "kak";
            TERMINAL = "foot";
          };

          environment.etc = {
            "xdg/gtk-3.0/settings.ini".source = ./packages/gtk-3.0/settings.ini;
          };

          # List packages installed in system profile. To search, run:
          # $ nix search wget
          #
          environment.systemPackages =
            builtins.concatMap (flake: builtins.attrValues flake.packages.${pkgs.system}) (builtins.attrValues flakes)
            ++ [ helix.packages.${pkgs.system}.default ] ++ (with pkgs; [
              foot
              nixfmt-rfc-style
              gh
              lsd
              pciutils
              usbutils
              brightnessctl
              wget
              bottom
              killall
              firefox
              chromium
              font-awesome
              pulsemixer
              mtr
              nmap
              steam
              xdg-utils
              nmap
              nix-prefetch-scripts
              nodePackages.typescript-language-server
              broot
              wakatime
              fzf
              wl-clipboard
              zoxide
              direnv
              bat
              marksman
              rm-improved
              mpv
              fuzzel
              mako
              grim
            ]);

          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
          # Some programs need SUID wrappers, can be configured further or are
          # started in user sessions.
          # programs.mtr.enable = true;
          # programs.gnupg.agent = {
          #   enable = true;
          #   enableSSHSupport = true;
          # };
          #
          #
          programs = {
            dconf.enable = true;
            xwayland.enable = true;
          };

          programs.river = {
            enable = false;
          };

          programs.sway = {
            # enable = true;
            wrapperFeatures.gtk = true;
            extraPackages = with pkgs; [
              gtk-engine-murrine
              gtk_engines
              swayidle
              swaylock
              swaycons
            ];
          };


          programs.git = {
            enable = true;
            config = { init = { defaultBranch = "main"; }; };
          };

          programs.fish = { enable = true; };

          fonts = {
            enableDefaultPackages = true;
            packages = with pkgs; [
              font-awesome
              nerd-fonts.fira-code
            ];
          };

          # List services that you want to enable:

          # Enable the OpenSSH daemon.
          # services.openssh.enable = true;
          # Open ports in the firewall.
          networking.firewall.allowedTCPPorts = [ ];
          # networking.firewall.allowedUDPPorts = [ ... ];
          # Or disable the firewall altogether.
          # networking.firewall.enable = false;
          # This value determines the NixOS release from which the default
          # settings for stateful data, like file locations and database versions
          # on your system were taken. It‘s perfectly fine and recommended to leave
          # this value at the release version of the first install of this system.
          # Before changing this value read the documentation for this option
          # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
          system.stateVersion = "21.11"; # Did you read the comment?
        });

    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      nixosConfigurations.plusgut-dell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [ common ./custom-dell.nix ];
      };
      nixosConfigurations.plusgut-lenovo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          common
          nixos-hardware.nixosModules.dell-xps-13-9380
          ./custom-lenovo.nix
        ];
      };
    };
}
