#!/bin/bash
echo 'path "dm/square/efd/test-gke" {capabilities = ["read"]}' | vault policy write vault-secrets-operator -
