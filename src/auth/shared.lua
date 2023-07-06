local mongo = require 'mongo'
local uuid = require "misc.uuid"
local config = require("lapis.config").get()
local luasodium = require "luasodium"
local hex       = require "misc.hex"

local shared = {
    checks = {}
}
--- ### Create hash from string
--- uses .salt file!!!
--- @param string string
--- @return string binaryHash
function shared.createHash(string)
    return luasodium.crypto_pwhash(
        32,
        string,
        config.secret,
        luasodium.crypto_pwhash_OPSLIMIT_INTERACTIVE,
        luasodium.crypto_pwhash_MEMLIMIT_INTERACTIVE,
        luasodium.crypto_pwhash_ALG_DEFAULT)
end

--- ### Check hash
--- Generates hash on second parameter and then compares new and old hash.
--- @param hash string 
--- @param string string
--- @return boolean checkPassed
function shared.checkHash(hash, string)
    return shared.createHash(string) == hash
end

--- ### Check password
--- @param password string 
--- @return boolean checkPassed
--- @return string? cause
function shared.checks.password(password)
    if not password then
        return false, "Missing password"
    end
    local length = #password
    if password == "" then
        return false, "Password cannot be empty"
    end
    if length < 8 then
        return false, "Password is too short"
    end
    if length > 64 then
        return false, "Password is too big"
    end
    return true
end

--- ### Check username
--- @param username string 
--- @return boolean checkPassed
--- @return string? cause
function shared.checks.username(username)
    if not username then
        return false, "Missing username"
    end
    local length = #username
    local legal = username:find("^[%w_]+$")
    if username == "" then
        return false, "Username cannot be empty"
    end
    if not legal then
        return false, "Username has illegal characters"
    end
    if length < 3 then
        return false, "Username is too big"
    end
    if length > 16 then
        return false, "Username is too big"
    end
    return true
end

--- ### Generate Access Token
--- See: tokenSpecification.md  
--- `"User not found"` can also mean userUuid is not an UUID
--- @param password string 
--- @return string? error
--- @return string? token
function shared.generateAccessToken(userUuid)
    -- TODO: use more complex uuid check
    if uuid.isUuid(userUuid) then
        userUuid = uuid.parse(userUuid)
    end
    --check if user exists just in case
    local usersDb = config.db:getCollection('goldenoak', 'users')
    local user, err = usersDb:findOne{uuid=mongo.Binary(userUuid,4)}
    if not user then
        return nil, "User not found"
    end

    local expirationDate = os.time() + os.time{year=1970, month=0, day=7, hour=0} -- TODO: Make configurable
    local dashlessUuid = uuid.stringify(userUuid)
    local token = {"go", expirationDate, dashlessUuid}
    local sign = luasodium.crypto_sign_detached(table.concat(token), config.secretKey)
    -- TODO: Convert to base64
    return table.concat(token, ".").."."..hex.to(sign)
end

return shared