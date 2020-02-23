# Deployment for GitLab

This document describes the available deployment options for GitLab

## Prerequisites

The templates for GitLab rely on features in `ytt` that are not available in version 0.25.0. Please install `ytt` from the master branch as well as the latest release of `kapp` using the following commands:

```bash
make ytt kapp
```

## Stateless Deployment

The following commands create a deployment of GitLab without persistent storage:

```bash
./bin/ytt -f app/gitlab/ | kapp deploy --app gitlab --file -
```

## Persistent Deployment

The following commands create a deployment of GitLab using the [Hetzner Cloud CSI driver](https://github.com/hetznercloud/csi-driver):

```bash
./bin/ytt -f app/gitlab/ -f overlay/gitlab/pvc/ | kapp deploy --app gitlab --file -
```
