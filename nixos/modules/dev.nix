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

  nixpkgs.overlays = [
    (final: prev: {
      mongodb-compass = prev.mongodb-compass.overrideAttrs (old: {
        buildCommand =
          builtins.replaceStrings
            [
              ''
                wrapGAppsHook $out/bin/mongodb-compass
              ''
            ]
            [
              ""
            ]
            old.buildCommand;
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    libxkbcommon
    wayland
    libGL
    bpftrace
    cargo-expand
    cargo-generate
    cargo-deny
    cargo-hack
    cargo-insta
    cargo-machete
    cargo-msrv
    cargo-nextest
    cargo-outdated
    cargo-watch
    cargo-release
    cargo-llvm-cov
    sccache
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
    basedpyright
    deadnix
    nixd
    python3
    statix
    uv
    yt-dlp
    watchexec
    go
    gotestsum
    ruby
    rustup
    nodejs
    pnpm
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
    azure-cli
    bubblewrap
  ];

  home-manager.useGlobalPkgs = true;
}
