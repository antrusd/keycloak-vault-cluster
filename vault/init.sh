#!/usr/bin/env sh

set -e

unseal () {
  vault operator unseal $(grep 'Key 1:' /vault/creds/keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 2:' /vault/creds/keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 3:' /vault/creds/keys | awk '{print $NF}')
}

init () {
  vault operator init > /vault/creds/keys
}

if [ -s /vault/creds/keys ]; then
   unseal
else
   init
   unseal
fi

vault status > /vault/creds/status
