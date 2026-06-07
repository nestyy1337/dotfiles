# Development environment
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./base.nix
    ./home/dev.nix
  ];

  environment = {
    sessionVariables.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.libGL
    ];
    systemPackages = with pkgs; [
      libxkbcommon
      wayland
      libGL
      bpftrace
      cargo-expand
      cargo-generate
      cargo-hack
      cargo-insta
      cargo-machete
      cargo-msrv
      cargo-nextest
      cargo-outdated
      cargo-watch
      cargo-release
      cpuset
      gcc
      hyperfine
      inferno
      kdePackages.kcachegrind
      llvm
      nixfmt-rfc-style
      nodejs
      perf
      gnumake
      air
      python3
      uv
      go
      gotestsum
      ruby
      rustup
      tcpdump
      valgrind
      mongodb-compass
      mongosh
      go-migrate
      templ
      sqlx-cli
      postgresql
      sqlite
      postgresql.pg_config
      dbeaver-bin
      jackett
      gh
      openssl
      terraform
      google-cloud-sdk
      awscli2
      bubblewrap
    ];
  };
  home-manager.useGlobalPkgs = true;
}
