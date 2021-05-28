# Observ Edge

## What is

This module deploy observ-edge with existed observ-edge-infra (resource group, AKS, Storage, Database Server, etc)

Use when creating isolated environment without create new infra. Useful with dev site, pull request site.

## What it does

- Download helm chart from acr
- Create a namespace
- Create necessary configmap/secrets
- Install a helm release within this namespace
