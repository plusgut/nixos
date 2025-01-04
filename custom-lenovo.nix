{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  networking.hostName = "plusgut-lenovo";

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/5f480972-b1fe-44b5-b7c7-80bde19eb40d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/97eb88ee-8fe5-4681-be27-88789a223503";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/A073-431A";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c3f18bfc-42f0-407e-a087-e293b3faa066"; }];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.openvpn = {
    servers = {
      percha = {
        autoStart = true;
        updateResolvConf = true;
        config = "config /etc/openvpn/percha.ovpn";
      };
    };
  };

  environment.etc = {
    "openvpn/percha.ovpn".source = /home/plusgut/nixos/private/openvpn/percha.ovpn;
  };

  security.pki.certificateFiles = [
    /home/plusgut/nixos/private/pki/ca-chain-percha.pem
    /home/plusgut/nixos/private/pki/ca-chain-qsc-muc.pem
  ];

  environment.sessionVariables = {
    WORK_MODE = "professional";
  };
}
