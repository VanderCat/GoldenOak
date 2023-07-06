# Database schema
## Users DB
### User list
| USER UUID | Username | Password hash | Registration Date | Last logged in | Name History |
|-----------|----------|---------------|-------------------|----------------|--------------|
| uuid*     | string*  | string        | unix timestamp    | unix timestamp | string[]     |
### Active tokens list
| USER | Token  | Expiration Date | Valid |
|------|--------|-----------------|-------|
| user | string | unix timestamp  | bool  |

## Active Servers DB
| UUID  | ServerID |
|-------|----------|
| uuid* | hash     |