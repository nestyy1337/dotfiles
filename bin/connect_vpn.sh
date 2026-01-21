secret-tool lookup vpn netxp | sudo openconnect \
  --user=szymon.gluch@netxp.pl \
  --passwd-on-stdin \
  --os=win \
  --no-dtls \
  --csd-wrapper=/run/current-system/sw/bin/csd-post \
  --servercert pin-sha256:1BuuNVdh90VGY21cybHhyLN8qZp448h5/lHwlFmB6J0= \
  --authgroup="TunellALL" \
  vpn.networkexpert.pl
