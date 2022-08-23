{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  networking.hostName = "plusgut-dell";

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1bc14dc9-41b4-4650-90c4-86620ceabbd8";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/36cd934c-0dea-4f28-9737-756943ffdfb3";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C3A9-5899";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/82d96b65-acee-4ba0-9e2c-16ae4b3b49ca"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
