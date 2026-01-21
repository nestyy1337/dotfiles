# Host configuration for pc (desktop)
{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/personal.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "pc";

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };

}

