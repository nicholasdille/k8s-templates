# `cert-manager`

XXX

XXX based on 0.11 (0.13 has issues with TLS secret which is fixed in 0.14)

## Usage

XXX apply base

XXX apply letsencrypt-cloudflare

### base

XXX

### letsencrypt-cloudflare

XXX mind variables `certmanager.cloudflare.email` and `certmanager.cloudflare.key`

## Request certificate

XXX after applying base and letsencrypt-cloudflare

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: my-service
spec:
  secretName: certificate-my-service
  duration: 2160h
  renewBefore: 360h
  commonName: my-service.someone.io
  isCA: false
  keySize: 2048
  keyAlgorithm: rsa
  keyEncoding: pkcs1
  usages:
    - server auth
    - client auth
  dnsNames:
  - my-service.someone.io
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
```

See the [official documentation](https://cert-manager.io/docs/usage/certificate/)
