# Auth Token
also stored in db but to avoid excessive lookups it checks if token is valid before

## example
```
    go.1689341523880.e162d619ae0f86ffea374852f354bdb6.2c598dc6470f3fc177ce2b6e85b51eea17801f681075d88945c7caecba82647c0a1be860bbc863845f1920eff6475dc1c05b408c5bbd399813e96d2be15d2d04
```
## Anathomy
### Header
simply means that is a golden oak token
```
    go
```
### Expiration Date
Unix timestamp in ms
```
    1689341523880
```
### Data
for now it just hex encoded uuid
```
    e162d619ae0f86ffea374852f354bdb6
```
### Signature
hex encoded
```
    2c598dc6470f3fc177ce2b6e85b51eea17801f681075d88945c7caecba82647c0a1be860bbc863845f1920eff6475dc1c05b408c5bbd399813e96d2be15d2d04
```