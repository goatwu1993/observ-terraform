# Observ Cloud

## What is

This module deploy observ-cloud with existed observ-cloud-infra (resource group, AKS, Storage, Database Server, etc)

Use when creating isolated environment without create new infra. Useful with dev site, pull request site.

## What it does

- Create a database with existing Azure PostgreSQL server.
- Create a container with existing storage account.
- Create a namespace
- Create necessary configmap/secrets
- Install a helm release within this namespace

and more others.
