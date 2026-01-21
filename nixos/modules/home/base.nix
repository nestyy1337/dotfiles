# Minimal shell configuration for all hosts
{ config, pkgs, lib, ... }@osConfig:

{
  home-manager.users.szymon = { config, pkgs, lib, ... }:
    let
      nvimConfigPath = "${config.home.homeDirectory}/.config/editor/nvim";
      fontSize =
        if osConfig.config.networking.hostName == "laptop" then 11 else 14;
    in {
      home.file.".cargo/config.toml".text = ''
        [net]
        git-fetch-with-cli = true
      '';

      home.file.".gitconfig".text = ''
        [credential]
            helper = store
        [user]
            name = nestyy1337
            email = szymongluch100@gmail.com
        [includeIf "gitdir:~/work/"]
            path = ~/.gitconfig-work
        [core]
            editor = nvim
        [alias]
            slog = log --all --decorate --oneline
        [url "ssh://git@github.com/"]
            insteadOf = https://github.com/
        [rerere]
            enabled = true
      '';
      home.file.".gitconfig-work".text = ''
        [user]
            name = szymongluchnet
            email = szymon.gluch@netxp.pl
        [url "git@github-work:"]
            insteadOf = git@github.com:
      '';

      programs.bash.enable = true;

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.fish = {
        enable = true;
        shellAliases = {
          nix-rebuild-pc =
            "git -C ~/.config add -A && sudo nixos-rebuild switch --flake ~/.config/nixos#pc";
          nix-rebuild-lap =
            "git -C ~/.config add -A && sudo nixos-rebuild switch --flake ~/.config/nixos#laptop";
          nix-shell = "nix-shell --run fish";
          nix-develop = "nix develop -c fish";
        };

        functions = {
          fish_prompt =
            builtins.readFile ../../../shell/fish/functions/fish_prompt.fish;
        };
        shellInitLast = builtins.readFile ../../../shell/fish/config.fish;
      };

      programs.git = {
        enable = true;
        includes = [
          { path = ../../../shell/git/config; }
          { path = ../../../shell/git/config-work; }
        ];
      };

      programs.alacritty = {
        enable = true;
        theme = "moonfly";
        settings = builtins.fromTOML
          (builtins.readFile ../../../shell/alacritty/alacritty.toml) // {
            font.size = fontSize;
          };
      };

      programs.lazygit = { enable = true; };

      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github-work" = {
            hostname = "github.com";
            identityFile = "~/.ssh/id_rsa_work";
            identitiesOnly = true;
          };
          "internal-servers" = {
            host = "10.0.1.* 192.168.10.* 172.24.* 172.26.*";
            identityFile = "~/.ssh/sg";
            identitiesOnly = true;
          };
          "*" = { identityFile = "~/.ssh/id_rsa"; };
        };
      };

      programs.tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        plugins = with pkgs.tmuxPlugins; [ sensible yank ];
        extraConfig = builtins.readFile ../../../shell/tmux/tmux.conf;
      };

      programs.neovim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # These environment variables are needed to build and run binaries
        # with external package managers like mason.nvim.
        # LD_LIBRARY_PATH is set by nix-ld.
        extraWrapperArgs = with pkgs; [
          "--suffix"
          "LIBRARY_PATH"
          ":"
          "${lib.makeLibraryPath [ stdenv.cc.cc zlib ]}"
          "--suffix"
          "PKG_CONFIG_PATH"
          ":"
          "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
            stdenv.cc.cc
            zlib
          ]}"
        ];

        plugins = with pkgs.vimPlugins; [ ];

        extraPackages = with pkgs; [ tree-sitter ];

      };
      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink nvimConfigPath;

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = builtins.fromTOML
          (builtins.readFile ../../../shell/starship/starship.toml);
      };

      home.packages = with pkgs; [ bat eza fd jq nix-tree ];

      home.stateVersion = "25.11";
    };
}
