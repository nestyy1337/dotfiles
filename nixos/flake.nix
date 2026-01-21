{
  description = "configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    llm-agents.url = "github:numtide/llm-agents.nix";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      llm-agents,
      zen-browser,
      stylix,
    }:
    let
      system = "x86_64-linux";
      hosts = [ "pc" "laptop" ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (
        name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            llm-agents = llm-agents.packages.${system};
          };
          modules = [
            ./hosts/${name}
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                llm-agents = llm-agents.packages.${system};
                zen-browser = zen-browser;
              };
              home-manager.backupFileExtension = "backup";
            }
          ];
        }
      );
    };
}
