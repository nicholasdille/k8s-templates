# App for external-dns

XXX

## Variables

XXX

## Usage

XXX

```yaml
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: examplednsrecord
spec:
  endpoints:
  - dnsName: foo.bar.com
    recordTTL: 180
    recordType: A
    targets:
    - 192.168.99.216
```
