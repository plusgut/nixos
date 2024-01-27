{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    helix = { url = "github:helix-editor/helix"; };
  };

  outputs = { self, nixpkgs, nixos-hardware, helix, ... }@attrs:
    let
      common = ({ pkgs, ... }: {
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
        networking.wireless.enable =
          true; # Enables wireless support via wpa_supplicant.
        networking.wireless.userControlled.enable = true;

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
          nssmdns = true;
          publish.userServices = true;
        };

        services.tlp = { enable = true; };

        xdg = {
          portal = {
            enable = true;
            wlr.enable = true;
            configPackages = [ pkgs.river ];
            extraPortals = with pkgs; [
              xdg-desktop-portal-wlr
              xdg-desktop-portal-gtk
            ];
          };
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
            exec qtile start -b wayland
          fi
        '';

        environment.sessionVariables = {
          MOZ_ENABLE_WAYLAND = "1";
          QT_SCALE_FACTOR = "2";
          NIXOS_OZONE_WL="1";
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
          builtins.concatMap (flake: builtins.attrValues flake.packages.${pkgs.system})
          (map (x: builtins.getFlake (toString x))
            (builtins.filter (x: builtins.pathExists (x + "/flake.nix"))
              (map (x: ./. + "/packages/${x}")
                (builtins.attrNames (builtins.readDir ./packages)))))
          ++ [ helix.packages.${pkgs.system}.default ] ++ (with pkgs; [
            foot
            nixfmt
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
            phinger-cursors
            nmap
            steam
            xdg-utils
            nmap
            nix-prefetch-scripts
            nodePackages.typescript-language-server
            broot
            kak-lsp
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
            waybar
            mako
            grim
            qutebrowser
          ]);

        hardware.opengl.driSupport32Bit = true;
        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };
        programs.river = {
            enable = true;
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

        fonts.packages = with pkgs; [
          font-awesome
          (nerdfonts.override { fonts = [ "FiraCode" ]; })
        ];

        programs.git = {
          enable = true;
          config = { init = { defaultBranch = "main"; }; };
        };

        programs.fish = { enable = true; };

        programs.neovim = {
          enable = true;
          withRuby = false;
          withPython3 = false;
          defaultEditor = false;
          configure = {
            customRC =
              "\n            source $XDG_CONFIG_HOME/nvim/init.lua\n          ";
            packages.myVimPackage = with pkgs.vimPlugins; {
              # loaded on launch
              start = [
                barbar-nvim
                telescope-nvim
                nord-nvim
                nerdtree
                nvim-lspconfig
              ];
              # manually loadable by calling `:packadd $plugin-name`
              opt = [ ];
            };
          };
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

    in {
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
