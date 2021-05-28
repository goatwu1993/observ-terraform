# Aks Nvidia Device Plugin

## What is

This module deploy Nvidia Device Plugin on AKS.

## Why need this module

- Helm chart is good to describe as an resource in terraform
- [Helm chart of Nvidia device plugin](https://nvidia.github.io/k8s-device-plugin) is not compatible with AKS. It has arguments (see [here](https://github.com/NVIDIA/k8s-device-plugin/blob/master/deployments/helm/nvidia-device-plugin/templates/daemonset.yml)) at daemonset container run , where Aks need none (see [here](https://docs.microsoft.com/zh-tw/azure/aks/gpu-cluster)).

As a result, we host a similar helm chart until nvidia helm chart is configurable.
