# Golden Oak Auth server
Heavily work in progress

The drop in replacement of Yggdrasil authentication system

See: https://wiki.vg/Legacy_Mojang_Authentication
## Implemented enpoints
### `POST` /register
### `POST` /authenticate
### `POST` /refresh
### `POST` /validate
### `POST` /invalidate
### `POST` /signout
### `POST` /changepassword
// custom made, not present on wiki.vg
```json
{
    "username": "test",
    "password": "testing123",
    "newPassword": "testingtesting123"
}
```
### `PUT` /changename/:newname
### `PUT` /checkname/:name
### `POST` /session/minecraft/join
### `GET` /session/minecraft/hasJoined
### `GET` /session/minecraft/profile/:uuid

## Why?
- Because i want to know how auth works
- Because i love Lua
- Because i like Minecraft
## Trivia
This project has the name "Golden Oak" because mojang system also called after tree. Also i love MLP *shrug face*