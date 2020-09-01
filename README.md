# k3s-tf

__Warning__: This repo is still a WIP.  While it contains ready deployments, many of the components are still subject to change.

Terraform IAC for HA K3S on Commercial, GovCloud, or (T)C2S AWS regions.

Since k3s doesn't enforce an installation approach, there are many approaches to cluster bootstrapping.  This repository demonstrates _one_ of the many ways to go from 0 to infrastructure + HA cluster in just a few minutes.  

This repo is tailored to deploy on all AWS regions, and uses only the cloud services that exist on all environments.  As such, the following services are required:

* Autoscaling Groups
* RDS MySQL
* Classic Load Balancers (C2S compatibility)
* S3 (C2S compatibility)

TODO: More docs on architecture, inputs, etc...