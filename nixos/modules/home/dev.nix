# Development user configuration (for remote dev hosts)
{
  config,
  pkgs,
  llm-agents,
  paseo,
  ...
}:

{
  imports = [ ./base.nix ];

  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyfinal: pyprev: {
          llm-anthropic = pyprev.llm-anthropic.overridePythonAttrs {
            doCheck = false;
          };

          json-schema-to-pydantic = pyprev.json-schema-to-pydantic.overridePythonAttrs {
            doCheck = false;
          };
        })
      ];
    })
  ];

  home-manager.users.szymon =
    { config, pkgs, ... }:
    {
      services.gpg-agent = {
        enable = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
      };

      home.packages =
        with pkgs;
        let
          llmP = llm.withPlugins {
            llm-anthropic = true;
            llm-cmd = true;
          };
          # Upstream ships a stale nix/npm-deps.hash at v0.7.2; the pinned
          # lockfile actually prefetches to this. Recheck when the pin moves.
          paseoP = paseo.paseo.override {
            npmDepsHash = "sha256-0hOGev0HglOQmofzPQMfiWh1opg6cpiEgsfK22AKcGk=";
          };
        in
        [
          llmP
          llm-agents.claude-code
          llm-agents.opencode
          llm-agents.codex
          llm-agents.grok
          llm-agents.t3code
          llm-agents.t3code-desktop
          paseoP
          rr
        ];
    };
}
