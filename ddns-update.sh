#!/usr/bin/env sh
# Modified from...
# Author: Jari Pennanen
# Url: https://gist.github.com/Ciantic/4e543f2d878a87a38c25032d5c727bf2

TOKEN="$(cat /etc/cloudflare/token)"
ZONE="$(cat /etc/cloudflare/zone)"
HOST="$(hostname)"

ZONE_ID=$(
  wget -qO- \
    --header="Authorization: Bearer $TOKEN" \
    --header="Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones?name=$ZONE&status=active" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['result'][0]['id'])"
)
if [ -z "$ZONE_ID" ]; then
  exit 1
fi

IPV6_ADDRESS=$(
  wget -qO- -6 https://ifconfig.co/ip
)
if [ -z "$IPV6_ADDRESS" ]; then
  exit 1
fi

RECORD_IPV6_ID=$(
  wget -qO- \
    --header="Authorization: Bearer $TOKEN" \
    --header="Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=AAAA&name=$HOST" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['result'][0]['id'])"
)

if [ -z "$RECORD_IPV6_ID" ]; then
  IPV6_CREATE_RESULT=$(
    wget -qO- \
      --method=POST \
      --header="Authorization: Bearer $TOKEN" \
      --header="Content-Type: application/json" \
      --body-data='{"type":"AAAA","name":"'"$HOST"'","content":"'"$IPV6_ADDRESS"'","ttl":1,"proxied":false}' \
      "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['success'])"
  )

  if [ "$IPV6_CREATE_RESULT" != "True" ]; then
    exit 1
  fi
else
  IPV6_UPDATE_RESULT=$(
    wget -qO- \
      --method=PUT \
      --header="Authorization: Bearer $TOKEN" \
      --header="Content-Type: application/json" \
      --body-data='{"type":"AAAA","name":"'"$HOST"'","content":"'"$IPV6_ADDRESS"'","ttl":1,"proxied":false}' \
      "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_IPV6_ID" \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['success'])"
  )

  if [ "$IPV6_UPDATE_RESULT" != "True" ]; then
    exit 1
  fi
fi
