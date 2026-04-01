secret-tool lookup vpn netxp | sudo openconnect \
  --user=szymon.gluch@netxp.pl \
  --passwd-on-stdin \
  --os=win \
  --csd-wrapper=/run/current-system/sw/bin/csd-post \
  --servercert pin-sha256:1BuuNVdh90VGY21cybHhyLN8qZp448h5/lHwlFmB6J0= \
  --authgroup="SAML" \
  vpn.networkexpert.pl 2>&1 | while IFS= read -r line; do
    url=$(echo "$line" | rg -oP "(?<=')https://[^']+(?=')")
    if [ -n "$url" ]; then
      xdg-open "$url" &
    fi
    echo "$line"
  done
