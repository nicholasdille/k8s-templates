# Deployment for GitLab

This document describes the available deployment options for GitLab

## Persistent Deployment

The following commands create a deployment of GitLab using the [Hetzner Cloud CSI driver](https://github.com/hetznercloud/csi-driver):

```bash
./bin/ytt -f app/gitlab/ -f overlay/gitlab/pvc/ | kapp deploy --app gitlab --file -
```
