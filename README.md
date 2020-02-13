# App Templates

This repository contains templates for applications and overlay to use with [ytt](https://github.com/k14s/ytt)

## Usage

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

## Testing

Test folders can contains a file `run.sh` which is executed instead of a generic test.
