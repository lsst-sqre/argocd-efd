#!/bin/bash

[ ! "$VAULT_TOKEN" ] || [ ! "$VAULT_TOKEN_LEASE_DURATION" ] && 
echo "Set VAULT_TOKEN and VAULT_TOKEN_LEASE_DURATION env variables first." &&
exit 1


echo "apiVersion: v1
kind: Secret
metadata:
  name: vault-secrets-operator
type: Opaque
data:
  VAULT_TOKEN: $(echo -n "$VAULT_TOKEN" | base64)
  VAULT_TOKEN_LEASE_DURATION: $(echo -n "$VAULT_TOKEN_LEASE_DURATION" | base64)"
