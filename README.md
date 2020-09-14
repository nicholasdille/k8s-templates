# App Templates

This repository contains templates for applications as well as overlays to modify them based on [ytt](https://github.com/k14s/ytt) and [kapp](https://github.com/k14s/kapp)

## Compiling manifests

Creating manifests for an app:

```bash
ytt -f app/nginx
```

Setting values for an app:

```bash
ytt -f app/nginx -v port=8080
```

Adding an overlay:

```bash
ytt -f app/nginx -f overlay/namespace -v stage=nginx-qa
```

## Applying manifests

It is highly recommended to use [kapp](https://github.com/k14s/kapp) for applying template in a k8s cluster because it automatically applies manifests in the correct order and waits for resources to become ready.

Example:

```bash
ytt -f app/nginx/ | kapp deploy --app nginx --file -
```

## Writing apps and overlays

Note that files are processed in alphanumeric order.

## Testing

Test folders can contains a file `run.sh` which is executed instead of a generic test.
