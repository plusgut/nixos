# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hstName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;

  networking.wireless.networks.BlackRain.psk = "heileris23";
  networking.wireless.networks.BlackRain.extraConfig = "freq_list=2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472 2484";
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
    CHROME_BIN="chromium";
 };

  environment.extraInit = ''
     export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
  '';

  environment.etc = {
    "sway/config".source = ./packages/sway/config;
    "xdg/waybar".source = ./packages/waybar;
    "xdg/kitty/kitty.conf".source = ./packages/kitty/kitty.conf;
    "xdg/gtk-3.0/settings.ini".source = ./packages/gtk-3.0/settings.ini;
    zshrc.text = (builtins.readFile ./packages/zsh/zshrc); 
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    brightnessctl
    wget
    btop
    killall
    firefox
    chromium
    font-awesome
    pulsemixer
    vscode
    nodejs
    yarn
    ghc
    cabal-install
    haskell-language-server
    mtr
    phinger-cursors
    ntfy
    nmap
    steam
    xdg-utils
    nmap
  ];

  hardware.opengl.driSupport32Bit = true;

  programs.vim.defaultEditor = true;

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
      glib
      gtk-engine-murrine
      gtk_engines
      gsettings-desktop-schemas
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
}

