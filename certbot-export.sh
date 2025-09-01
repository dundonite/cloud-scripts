#!/usr/bin/env sh

DIR="/ssl/"
CERT=$(basename $RENEWED_LINEAGE)

mkdir -p "$DIR/$CERT"

cp "$RENEWED_LINEAGE"/fullchain.pem "$DIR/$CERT"/fullchain.pem
cp "$RENEWED_LINEAGE"/privkey.pem "$DIR/$CERT"/privkey.pem
cp "$RENEWED_LINEAGE"/cert.pem "$DIR/$CERT"/cert.pem
cp "$RENEWED_LINEAGE"/chain.pem "$DIR/$CERT"/chain.pem

openssl pkcs12 -export -passout pass: -out "$DIR/$CERT"/certificate.pfx \
    -inkey "$DIR/$CERT"/privkey.pem \
    -in "$DIR/$CERT"/cert.pem \
    -certfile "$DIR/$CERT"/chain.pem

chmod 600 "$DIR/$CERT"/*
chown 1000:1000 "$DIR/$CERT"/*
