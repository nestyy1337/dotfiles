# Minimal shell configuration for all hosts
{
  config,
  pkgs,
  lib,
  ...
}@osConfig:

{
  home-manager.users.szymon =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      nvimConfigPath = "${config.home.homeDirectory}/.config/editor/nvim";
      fontSize = if osConfig.config.networking.hostName == "laptop" then 11 else 14;
    in
    {
      home.file.".cargo/config.toml".text = ''
        [registries.kellnr]
        index = "sparse+https://crates.netxp.pl/api/v1/crates/"

        [net]
        git-fetch-with-cli = true
      '';

      home.file.".gitconfig".text = ''
        [user]
            name = Szymon Głuch
            email = szymongluch100@gmail.com
            signingKey = ~/.ssh/id_rsa.pub

        [commit]
            gpgSign = true

        [gpg]
            format = ssh

        [includeIf "gitdir:~/work/"]
            path = ~/.gitconfig-work
      '';

      home.file.".gitconfig-work".text = ''
        [user]
            name = Szymon Głuch
            email = szymon.gluch@netxp.pl
            signingKey = ~/.ssh/id_rsa_work.pub
      '';

      programs.bash.enable = true;

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.fish = {
        enable = true;
        shellAbbrs = {
          nrp = "sudo nixos-rebuild switch --flake ~/.config/nixos#pc";
          nrl = "sudo nixos-rebuild switch --flake ~/.config/nixos#laptop";
          ns = "nix-shell --run fish";
          nd = "nix develop -c fish";
          gst = "git status -sb";
          gl = "git log --oneline --decorate --graph -20";
        };

        plugins = [
          {
            name = "autopair";
            src = pkgs.fishPlugins.autopair.src;
          }
          {
            name = "plugin-sudope";
            src = pkgs.fishPlugins.plugin-sudope.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];

        shellInitLast = builtins.readFile ../../../shell/fish/config.fish;
      };

      programs.git = {
        enable = true;
        includes = [ { path = ../../../shell/git/config; } ];
      };

      programs.alacritty = {
        enable = true;
        theme = "moonfly";
        settings = builtins.fromTOML (builtins.readFile ../../../shell/alacritty/alacritty.toml) // {
          font.size = fontSize;
          font.normal.family = "JetBrainsMono Nerd Font Mono";
        };
      };

      programs.lazygit = {
        settings = {
          git.overrideGpg = true;
        };
        enable = true;
      };

      programs.ssh = {
        enable = true;
        matchBlocks = {
          "internal-servers" = {
            host = "10.0.1.* 192.168.10.* 172.24.* 172.26.* *.netxp.pl *.consul.service";
            identityFile = "~/.ssh/sg";
            identitiesOnly = true;
          };
          "*" = {
            identityFile = "~/.ssh/id_rsa";
          };
        };
      };

      programs.tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          vim-tmux-navigator
        ];
        extraConfig = builtins.readFile ../../../shell/tmux/tmux.conf;
      };

      programs.neovim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withPython3 = false;
        withRuby = false;

        # These environment variables help external package managers like
        # mason.nvim build native binaries without relying on global linker
        # environment variables.
        extraWrapperArgs = with pkgs; [
          "--suffix"
          "LIBRARY_PATH"
          ":"
          "${lib.makeLibraryPath [
            stdenv.cc.cc
            zlib
          ]}"
          "--suffix"
          "PKG_CONFIG_PATH"
          ":"
          "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
            stdenv.cc.cc
            zlib
          ]}"
        ];

        extraPackages = with pkgs; [ tree-sitter ];

      };
      xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
      xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

      programs.atuin = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          style = "compact";
          inline_height = 20;
        };
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = builtins.fromTOML (builtins.readFile ../../../shell/starship/starship.toml);
      };

      home.packages = with pkgs; [
        bat
        eza
        fd
        jq
        nix-tree
      ];

      home.stateVersion = "25.11";
    };
}
