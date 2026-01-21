# Development user configuration (for remote dev hosts)
{ config, pkgs, llm-agents, ... }:

{
  imports = [ ./base.nix ];

  home-manager.users.szymon = { config, pkgs, ... }: {
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    home.packages = with pkgs;
      let
        llmP = llm.withPlugins {
          llm-anthropic = true;
          llm-cmd = true;
        };
      in [ llmP llm-agents.claude-code llm-agents.gemini-cli nix-tree rr ];
  };
}
