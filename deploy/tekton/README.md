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
