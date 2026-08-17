# IKEv2 client configuration for the NETXP lab network.
#
# Credentials deliberately live outside the Nix store, which is world-readable.
# Before rebuilding, create /etc/swanctl/netxp-secrets.conf as root (0600) with
# the IKE PSK and the EAP password; the ids must match `remote.primary.id` and
# `local.primary.eap_id` below:
#
#   secrets {
#     ike-netxp { id = 185.230.156.17  secret = "<IKE_PSK>" }
#     eap-netxp { id = "szymon"        secret = "<EAP_PASSWORD>" }
#   }
#
# The service stays inert until that file exists (see ConditionPathExists).
{ pkgs, ... }:

{
  services.strongswan-swanctl = {
    enable = true;

    # NixOS renders the connection configuration into the world-readable Nix
    # store, so secrets must be loaded from a separately managed file.
    includes = [ "/etc/swanctl/netxp-secrets.conf" ];

    swanctl.connections.lab = {
      version = 2;
      proposals = [ "aes256-sha256-modp2048" ];
      dpd_delay = "15s";
      rekey_time = "23h";

      local_addrs = [ "%defaultroute" ];
      remote_addrs = [ "185.230.156.17" ];
      encap = true;
      vips = [ "0.0.0.0" ];
      send_cert = "never";

      local.primary = {
        auth = "eap-mschapv2";
        eap_id = "szymon";
        id = "szymon";
      };
      remote.primary = {
        auth = "psk";
        id = "185.230.156.17";
      };

      children.net = {
        remote_ts = [ "172.24.41.0/24" ];
        esp_proposals = [ "aes256-sha256-modp2048" ];
        start_action = "start";
        life_time = "60m";
        rekey_time = "55m";
      };
    };
  };

  # Do not start a daemon that would continuously attempt (and fail) EAP
  # authentication if the credentials have not been installed yet.
  systemd.services.strongswan-swanctl.unitConfig.ConditionPathExists =
    "/etc/swanctl/netxp-secrets.conf";

  environment.systemPackages = [ pkgs.strongswan ];
}
