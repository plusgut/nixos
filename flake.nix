{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = github:NixOS/nixos-hardware;
    kak-auto-pairs = {
      url = "github:alexherbo2/auto-pairs.kak";
      flake = false;
    };
    kak-wakatime= {
      url = "github:WhatNodyn/kakoune-wakatime";
      flake = false;
    };
    kak-active-window= {
      url = "github:greenfork/active-window.kak";
      flake = false;
    };
    strictly-vscode-extension.url = "github:strictly-lang/vscode-plugin/streams";
  };

  outputs = { self, nixpkgs, nixos-hardware, kak-auto-pairs, kak-wakatime, kak-active-window, strictly-vscode-extension, ... }@attrs:
    let common = ({ pkgs, ... }: {
      nix.settings.auto-optimise-store = true;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

      system.autoUpgrade.enable = true;
      system.autoUpgrade.allowReboot = false;

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 3;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # networking.hstName = "nixos"; # Define your hostname.
      networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
      networking.wireless.userControlled.enable = true;

      networking.wireless.networks.BlackRain.psk = "heileris23";
      networking.wireless.networks.BlackRain.extraConfig = "freq_list=2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472 2484";
      networking.wireless.networks.Vanitha.psk = "vanitha1963";
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

      xdg = {
        portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
          ];
          gtkUsePortal = true;
        };
      };


      users.users.root.initialHashedPassword = "";
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.plusgut = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "sudo"
        ]; # Enable ‘sudo’ for the user.
        shell = pkgs.zsh;
      };

      environment.loginShellInit = ''
        if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
        fi
      '';

      environment.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        XDG_CURRENT_DESKTOP = "sway";
        XDG_CONFIG_HOME = "/home/plusgut/nixos/packages";
        CHROME_BIN="chromium";
        EDITOR = "kak";
        TERMINAL = "kitty";
      };

      environment.etc = {
        "xdg/waybar".source = ./packages/waybar;
        "xdg/kitty/kitty.conf".source = ./packages/kitty/kitty.conf;
        "xdg/gtk-3.0/settings.ini".source = ./packages/gtk-3.0/settings.ini;
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      #
      environment.systemPackages = with pkgs ; [
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
        (vscode-with-extensions.override {
          vscode = vscodium;
          vscodeExtensions = with vscode-extensions; [
            mkhl.direnv
            haskell.haskell
            justusadam.language-haskell
            bbenoist.nix
            rust-lang.rust-analyzer
            WakaTime.vscode-wakatime
            dbaeumer.vscode-eslint
            strictly-vscode-extension.packages.${system}.strictly
          ];
        })
        mtr
        phinger-cursors
        nmap
        steam
        xdg-utils
        nmap
        nix-prefetch-scripts
        nodePackages.typescript-language-server
        broot
        (kakoune.override {
          plugins = with kakounePlugins ; [
            (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
              pname = "auto-pairs";
              version = "master";
              src = kak-auto-pairs;
            })
            (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
              pname = "wakatime";
              version = "master";
              src = kak-wakatime;
            })
            (pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
              pname = "active-window";
              version = "master";
              src = kak-active-window;
            })
          ];
        })
        kakoune-cr
        kak-lsp
        wakatime
        fzf
        lf
        fd
        tig
        wl-clipboard
        nb
        zoxide
        direnv
        bat
        marksman
      ];


      hardware.opengl.driSupport32Bit = true;
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          dmenu
          waybar
          kitty
          mako
          grim
          gtk-engine-murrine
          gtk_engines
          swayidle
          swaylock
        ];
      };

      fonts.fonts = with pkgs;  [
        font-awesome
      ];

      programs.git = {
        enable = true;
        config = {
          init = {
            defaultBranch = "main";
          };
        };
      };

      programs.zsh = {
        enable = true;
        interactiveShellInit = ''
          source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

          setopt nobanghist
          eval "$(zoxide init zsh)"
          eval "$(direnv hook zsh)"
          alias cd="_ZO_ECHO=1 z"
        '';
        promptInit = "";
      };

      programs.neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;
        defaultEditor = false;
        configure = {
          customRC = "
            source $XDG_CONFIG_HOME/nvim/init.lua
          ";
          packages.myVimPackage = with pkgs.vimPlugins; {
            # loaded on launch
          start = [ barbar-nvim telescope-nvim nord-nvim nerdtree nvim-lspconfig ];
            # manually loadable by calling `:packadd $plugin-name`
            opt = [ ];
          };
        };
      };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;
      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [];
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
    nixosConfigurations.plusgut-dell= nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        common
        ./custom-dell.nix
      ];
    };
    nixosConfigurations.plusgut-lenovo= nixpkgs.lib.nixosSystem {
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
