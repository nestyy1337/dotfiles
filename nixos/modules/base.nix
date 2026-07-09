# Base system configuration (for ALL hosts)
{ pkgs, config, ... }:
let
  CsdScriptContent = builtins.readFile ../../bin/csd-wrapper.sh;
  csdWrapper = pkgs.writeShellScriptBin "csd-post" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.xmlstarlet
        pkgs.curl
        pkgs.coreutils
      ]
    }:$PATH"
    ${CsdScriptContent}
  '';
  TmuxScriptContent = builtins.readFile ../../bin/tmux_fzf.sh;
  tmux_fzf = pkgs.writeShellScriptBin "tmux_fzf" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.tmux
      ]
    }:$PATH"
    ${TmuxScriptContent}
  '';
  ConnectVPNContent = builtins.readFile ../../bin/connect_vpn.sh;
  connect_vpn = pkgs.writeShellScriptBin "connect_vpn" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.tmux
      ]
    }:$PATH"
    ${ConnectVPNContent}
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Trust the numtide binary cache used by the llm-agents flake
  nix.settings.extra-substituters = [ "https://cache.numtide.com" ];
  nix.settings.extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];

  # Timezone
  time.timeZone = "Europe/Warsaw";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Networking
  networking = {
    hosts = {
      "172.26.26.180" = [
        "api.netxp.pl"
        "rdocs.netxp.pl"
        "iris.netxp.pl"
        "opencti.netxp.pl"
        "deviris.netxp.pl"
        "rapi.netxp.pl"
        "crates.netxp.pl"
        "catalog.netxp.pl"
      ];

    };
    networkmanager.enable = true;
  };

  security.pki.certificateFiles = [
    ../../misc/NETXP_FULLCHAIN.crt
    ../../misc/NETXP_NOMAD_VAULT.crt
  ];

  users.users.szymon = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adm"
      "users"
    ];
    shell = pkgs.fish;
  };

  # OOM prevention
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.sessionVariables = {
    UV_NATIVE_TLS = "true";
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
    image = ../assets/wallpaper.png;
    autoEnable = true;
  };

  stylix.targets = {
    console.enable = false;
    fish.enable = false;
  };

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.geist-font;
      name = "Geist";
    };
    serif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };

  };

  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    connect_vpn
    csdWrapper
    tmux_fzf
    git
    jujutsu
    direnv
    btop
    ripgrep
    zip
    zstd
    unzip
    sudo-rs
    rsync
    pstree
    openssh
    openconnect
    libsecret
  ];

  system.stateVersion = "25.11";
}
