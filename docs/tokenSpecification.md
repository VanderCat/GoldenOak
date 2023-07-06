# Auth Token
also stored in db but to avoid excessive lookups it checks if token is valid before

## example
```
    go.12381837123.a0d21c3418ff1a34e3123a0d21c3418ff1a34e3123.a0d21c3418ff1a34e3123a0d21c3418ff1a34e3123
```
## Anathomy
### Header
simply means that is a golden oak token
```
    go
```
### Expiration Date
Unix timestamp
```
    12381837123
```
### Data
for now it just hex encoded uuid
```
    a0d21c3418ff1a34e3123a0d21c3418ff1a34e3123
```
### Signature
hex encoded
```
    a0d21c3418ff1a34e3123a0d21c3418ff1a34e3123
```