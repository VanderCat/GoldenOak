local config = require("lapis.config").get()
local luasodium = require "luasodium"

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

return shared