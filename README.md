# k3s-tf
Terraform IAC for K3S on AWS

## TODO

* better `modules/nodepool/files/bootstrap.sh`
  * CIS benchmark node configuration
  * selinux
  * more k3s options?
  * rds CA pem
* ha server with datastore (waiting for permissions)
* external ccm/aws-ebs-csi-driver
* registry mirroring inputs/settings
* docs for [caddy](https://caddyserver.com/docs/quick-starts/static-files) file server

### `k3ama` / airgap assumptions

The following important assumptions are made which make ssh-less bootstrapping and immutable clusters possible:

* `k3s` dependencies (just the k3s binary) can be fetched from somewhere accessible by the agents and servers (configurable)
* a registry accessible from servers and agents is accessible with the required images preloaded

Thankfully, by it's very nature, k3s makes setting this up _extremely_ simple.  Please see [`k3ama`](https://github.com/rancherfederal/k3ama) to get started.