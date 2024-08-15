#!/usr/bin/env sh

set -e

unseal () {
  vault operator unseal $(grep 'Key 1:' /vault/creds/vault.keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 2:' /vault/creds/vault.keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 3:' /vault/creds/vault.keys | awk '{print $NF}')
}

init () {
  vault operator init > /vault/creds/vault.keys
}

if [ -s /vault/creds/vault.keys ]; then
   unseal
else
   init
   unseal
fi
