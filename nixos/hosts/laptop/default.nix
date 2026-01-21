# Host configuration for laptop
{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/personal.nix
    ../../modules/laptop.nix
  ];

  networking.hostName = "laptop";

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Microcode updates for Intel
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime-legacy1
      intel-vaapi-driver
      libva-vdpau-driver
    ];
  };

  services.thermald.enable = true;

  services.fwupd.enable = true;
}

