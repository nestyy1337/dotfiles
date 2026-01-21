# Personal home-manager configuration (GUI apps)
{ config, pkgs, lib, zen-browser, stylix, ... }:
let hostName = config.networking.hostName;
in {
  imports = [ ./dev.nix ];

  home-manager.users.szymon = { config, pkgs, zen-browser, ... }:
    let
      wallpaper = "${config.home.homeDirectory}/.config/gui/its_rapta.png";
      monitorConfig = {
        pc = [ "DP-1,2560x1440@144,auto,1" "DP-2,1920x1080@239,auto,1" ];
        laptop = [ "eDP-1,1920x1200@60,auto,1" ];
      };
    in {

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
              timeout = 150;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 150;
              on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
              on-resume = "brightnessctl -rd rgb:kbd_backlight";
            }
            {
              timeout = 500;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      programs.hyprlock = {
        enable = true;
        extraConfig = builtins.readFile ../../../gui/hypr/hyprlock.conf;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        settings.monitor = monitorConfig.${hostName} or [ ",preferred,auto,1" ];
        extraConfig = builtins.readFile ../../../gui/hypr/hyprland.conf;
      };

      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };

      programs.hyprshot = { enable = true; };

      programs.waybar = {
        enable = true;

        settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            height = 18;
            spacing = 4;

            modules-left = [ "custom/arch" "hyprland/workspaces" ];

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
                default = [ "" "" "" ];
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
              exec = "~/.config/bin/waybar_vpn.sh";
              on-click = "~/.config/bin/waybar_vpn.sh toggle";
            };

          };
        };

        style = builtins.readFile ../../../gui/waybar/style.css;
      };

      programs.fuzzel = {
        enable = true;
        # settings = {
        #   main = {
        #     font = "JetBrainsMono Nerd Font:size=12";
        #     prompt = "❯ ";
        #     icon-theme = "Papirus-Dark";
        #     terminal = "alacritty -e";
        #     layer = "overlay";
        #   };
        #
        #   colors = {
        #     background = "1e1e2eff";
        #     text = "cdd6f4ff";
        #     match = "f38ba8ff";
        #     selection = "585b70ff";
        #     selection-text = "cdd6f4ff";
        #     border = "b4befeff";
        #   };
        # };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          ipc = "on";
          preload = [ wallpaper ];
          wallpaper = {
            monitor = "";
            path = wallpaper;
            fit_mode = "cover";
          };
        };
      };

      home.packages = with pkgs; [
        firefox
        zen-browser.packages.${pkgs.system}.default
        alacritty
        wl-clipboard
        wofi
        cliphist
        keepassxc
        pavucontrol
        pulseaudio
        gimp
        signal-desktop
        spotify
        libnotify
        swaynotificationcenter
        hyprlock
        vlc
        fuzzel
        nautilus
        hyprpolkitagent
        seahorse
        vivaldi
      ];
    };
}
