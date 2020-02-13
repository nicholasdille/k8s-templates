# `cert-manager`

XXX

## Variables

XXX

## Request certificate

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
