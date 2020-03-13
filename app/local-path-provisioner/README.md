# App for Rancher's local-path-provisioner

XXX https://github.com/rancher/local-path-provisioner

XXX based on version 0.0.12

XXX in [k3s](https://github.com/rancher/k3s) this is available by default

XXX in [k3d](https://github.com/rancher/k3d) ???

XXX in [kind](https://github.com/kubernetes-sigs/kind) is available when worker nodes > 0 (storageClass: standard)

## Usage

Create PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
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
      claimName: local-path-pvc
```
