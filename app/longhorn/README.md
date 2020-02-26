# App for Longhorn

XXX https://github.com/longhorn/longhorn

XXX based on version 0.7.0

## Prerequisites

[Mount propagation](https://kubernetes.io/docs/concepts/storage/volumes/#mount-propagation) must work:

```bash
$ cat /etc/systemd/system/docker.service.d/override.conf
[Service]
MountFlags=shared
$ systemctl daemon-reload
$ systemctl restart docker.service
```

This is the case for [k3s](https://github.com/rancher/k3s) and [kind](https://github.com/kubernetes-sigs/kind) but not for [k3d](https://github.com/rancher/k3d)

## Usage

Create PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-volv-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 2Gi
```

Use volume in pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
  namespace: default
spec:
  containers:
  - name: volume-test
    image: nginx:stable-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: volv
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: volv
    persistentVolumeClaim:
      claimName: longhorn-volv-pvc
```
