#!/usr/bin/env sh

/sbin/ip -6 monitor prefix dev eth0 | sed 's/.* //g' | while read newaddr; do
  if [ "$newaddr" == "[NEWADDR]" ]; then
    /usr/local/bin/ddns-update.sh
  fi
done
