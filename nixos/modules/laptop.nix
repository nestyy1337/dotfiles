# Laptop-specific configuration
{ config, pkgs, lib, ... }:

{
  # Networking
  networking.networkmanager.enable = true;

  # Power management
  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "PowerOff";
  };

  # Power profiles (performance/balanced/power-saver)
  services.power-profiles-daemon.enable = true;

  services.logind = {
    # Lid Behavior
    # Suspend on battery, ignore on AC
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";

    # Power Button Behavior
    powerKey = "suspend-then-hibernate";
    powerKeyLongPress = "poweroff";
  };

  # Brightness control
  programs.light.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    wl-mirror
    powertop
    acpi
  ];

  # Bluetooth power saving
  hardware.bluetooth.settings = { Policy = { AutoEnable = true; }; };
}

