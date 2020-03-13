# Tekton Pipelines

XXX

## Prepare if on kind

None if running worker nodes

## Prepare if on k3s

None

## Prepare if on k3d

???

## Prepare else

XXX local-path-provisioner

```bash
./bin/ytt -f app/local-path-provisioner/ | ./bin/kapp deploy --app lpp --file -
```

## Install tekton pipelines

XXX storage class is standard on kind

```bash
./bin/ytt -f app/tekton/ -v tekton.volume.storageClass=standard | ./bin/kapp deploy --app tekton --file -
```
