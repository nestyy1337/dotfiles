# Personal home-manager configuration (GUI apps)
{
  config,
  pkgs,
  lib,
  zen-browser,
  stylix,
  ...
}:
let
  hostName = config.networking.hostName;
in
{
  imports = [ ./dev.nix ];

  home-manager.users.szymon =
    {
      config,
      pkgs,
      zen-browser,
      ...
    }:
    let
      monitorConfig = {
        pc = [
          "DP-1,2560x1440@144,auto,1"
          "DP-2,1920x1080@239,auto,1"
        ];
        laptop = [
          "HDMI-A-1,1920x1080@60,0x0,1"
          "eDP-1,1920x1200@60,0x1080,1"
        ];
      };
      workspaceConfig = {
        pc = [
          "1,monitor:DP-2"
          "2,monitor:DP-1"
          "3,monitor:DP-1"
          "4,monitor:DP-1"
          "5,monitor:DP-2"
          "6,monitor:DP-2"
        ];
        laptop = [
          "1,monitor:eDP-1"
          "2,monitor:HDMI-A-1"
          "3,monitor:HDMI-A-1"
          "4,monitor:eDP-1"
          "5,monitor:HDMI-A-1"
          "6,monitor:HDMI-A-1"
          "7,monitor:eDP-1"
        ];
      };
    in
    {

      stylix.cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      stylix.targets = {
        fish.enable = false;
        neovim.enable = false;
        alacritty.enable = false;
        tmux.enable = false;
        waybar.enable = false;
        hyprlock.enable = false;
      };

      programs.hyprlock = {
        enable = true;
        extraConfig = builtins.readFile ../../../gui/hypr/hyprlock.conf;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        settings.monitor = monitorConfig.${hostName} or [ ",preferred,auto,1" ];
        settings.workspace = workspaceConfig.${hostName} or [ ];
        extraConfig = builtins.readFile ../../../gui/hypr/hyprland.conf;
      };

      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };

      programs.hyprshot = {
        enable = true;
      };

      programs.waybar = {
        enable = true;

        settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            height = 18;
            spacing = 4;

            modules-left = [
              "custom/arch"
              "hyprland/workspaces"
            ];

            modules-right = [
              "custom/vpn"
              "idle_inhibitor"
              "pulseaudio"
              "network"
              "cpu"
              "memory"
              "hyprland/language"
              "clock"
            ];

            "hyprland/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
              warp-on-scroll = false;
              format = "{name}";
              format-icons = {
                urgent = "";
                active = "";
                default = "";
              };
            };

            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "";
                deactivated = "";
              };
            };

            "pulseaudio" = {
              format = "{icon}  {volume}%";
              format-bluetooth = "{icon} {volume}%  {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = " {volume}%";
              format-source-muted = "";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "pavucontrol";
            };

            "network" = {
              format-wifi = "   {essid} ({signalStrength}%)";
              format-ethernet = "{ipaddr}/{cidr} ";
              tooltip-format = "{ifname} via {gwaddr} ";
              format-linked = "{ifname} (No IP) ";
              format-disconnected = "Disconnected ⚠";
            };

            "cpu" = {
              format = "  {usage}%";
              tooltip = true;
            };

            "memory" = {
              format = "  {}%";
              tooltip = true;
            };

            "clock" = {
              format = "{:%H:%M | %e %B} ";
              tooltip-format = ''
                <big>{:%Y %B}</big>
                <tt><small>{calendar}</small></tt>'';
              format-alt = "{:%Y-%m-%d}";
            };

            "custom/vpn" = {
              format = "{}";
              return-type = "json";
              interval = 5;
              signal = 8;
              exec = "~/.config/bin/waybar_vpn.sh";
              on-click = "~/.config/bin/waybar_vpn.sh toggle";
            };

          };
        };

        style = builtins.readFile ../../../gui/waybar/style.css;
      };

      programs.fuzzel = {
        enable = true;
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          ipc = "on";
        };
      };

      # systemd.user.services.hyprpolkitagent = {
      #   Unit = {
      #     Description = "Hyprland Polkit Agent";
      #     After = [ "graphical-session.target" ];
      #   };
      #   Service = {
      #     ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      #     Restart = "on-failure";
      #   };
      #   Install.WantedBy = [ "graphical-session.target" ];
      # };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
          };

          listener = [
            {
              timeout = 160;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 300;
              on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
              on-resume = "brightnessctl -rd rgb:kbd_backlight";
            }
            {
              timeout = 360;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
              timeout = 600;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 1400;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      home.packages = with pkgs; [
        firefox
        google-chrome
        zen-browser.packages.${pkgs.system}.default
        alacritty
        wl-clipboard
        wofi
        slack
        cliphist
        keepassxc
        pavucontrol
        pulseaudio
        gimp
        qbittorrent
        signal-desktop
        spotify
        libnotify
        swaynotificationcenter
        brightnessctl
        vlc
        discord
        nautilus
        kdePackages.dolphin
        hyprpolkitagent
        seahorse
        vivaldi
      ];
    };
}
