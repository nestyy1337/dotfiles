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

  environment.systemPackages = with pkgs; [
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
    basedpyright
    deadnix
    nixd
    python3
    statix
    uv
    watchexec
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

  home-manager.useGlobalPkgs = true;
}
