# Personal machine configuration (GUI + personal services)
{ config, lib, pkgs, ... }:

{
  imports = [ ./dev.nix ./home/personal.nix ];

  # Hyprland
  programs.hyprland.enable = true;

  # Display manager (ly)
  services.displayManager.ly.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = { Policy = { AutoEnable = true; }; };
  };

  # Graphics
  hardware.graphics.enable = true;

  # Screen sharing (xdg portal for Hyprland)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Input
  services.libinput.enable = true;

  # Sound (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # XServer (needed for XWayland)
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # Security
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;

  services.jackett.enable = true;

}
