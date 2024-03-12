local mongo = require 'mongo'
local uuid = require "misc.uuid"
local config = require("lapis.config").get()
local luasodium = require "luasodium"
local hex       = require "misc.hex"
local socket = require "socket"
local errors = require "errorList"

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
function shared.checks.hash(hash, string)
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
--- ### Check client token
--- subject to change, idk about mojang limits
--- @param clientToken string 
--- @return boolean checkPassed
--- @return string? cause
function shared.checks.clientToken(clientToken)
    if not clientToken then
        return false, "Missing Client Token"
    end
    local length = #clientToken
    if clientToken == "" then
        return false, "Client Token cannot be empty"
    end
    if length < 8 then
        return false, "Client Token is too short"
    end
    if length > 64 then
        return false, "Client Token is too big"
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
--- @param userUuid string 
--- @param clientToken string 
--- @return string? token
--- @return string? error
function shared.generateAccessToken(userUuid, clientToken)
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

    local creationDate = math.floor(socket.gettime()*1000)
    local expirationDate = creationDate + 604800000 -- TODO: Make configurable
    local dashlessUuid = uuid.stringify(userUuid)
    local token = {"go", expirationDate, dashlessUuid}
    local sign = luasodium.crypto_sign_detached(table.concat(token), config.secretKey)

    local tokenString = table.concat(token, ".").."."..hex.to(sign)

    local tokensDb = config.db:getCollection('goldenoak', 'tokens')
    tokensDb:insert{
        _id = mongo.ObjectID(),
        owner = mongo.Binary(userUuid, 4),
        accessToken = tokenString,
        creationDate = mongo.DateTime(creationDate),
        clientToken = mongo.Binary(clientToken, 128), -- it is not necessary uuid so it will be saved as cusom binary
        expirationDate = mongo.DateTime(expirationDate),
        valid = true,
    }

    return tokenString
end

--- Check access token
--- @param accessToken string 
--- @return boolean valid
--- @return string? error
function shared.checks.accessToken(accessToken)
    if not accessToken then
        return false, "Access Token is nil"
    end
    local split = accessToken:split(".")
    if split[1] ~= "go" then
        return false, "Access Token is invalid"
    end
    if tonumber(split[2]) < math.floor(socket.gettime()*1000) then
        return false, "Access Token is expired"
    end
    local signature = hex.from(table.remove(split, 4))
    if not ((#signature == luasodium.crypto_sign_BYTES) and ( luasodium.crypto_sign_verify_detached(signature, table.concat(split), config.publicKey))) then
        return false, "Signature is not valid"
    end
    return true
end

function shared.getToken(accessToken, clientToken)
    local valid, err = shared.checks.accessToken(accessToken)
    if not valid then
        return nil, errors.InvalidToken {
            cause = err
        }
    end
    if type(clientToken) == "string" then
        local valid, err = shared.checks.clientToken(clientToken)
        if not valid then
            return nil, errors.InvalidToken {
                cause = err
            }
        end
    end
    local tokenDocument, err =  shared.accessTokenDb(accessToken, clientToken)
    return tokenDocument, err
end

function shared.accessTokenDb(accessToken, clientToken)
    local tokensDb = config.db:getCollection('goldenoak', 'tokens')
    local tokenDocument, err = tokensDb:findOne{accessToken = accessToken}
    if not tokenDocument then
        return nil, errors.InvalidToken {
            cause = "Access Token does not exist"
        }
    end
    tokenDocument = tokenDocument:value()
    if clientToken then
        if tokenDocument.clientToken[1] ~= clientToken then
            return tokenDocument, errors.InvalidToken {
                cause = "Access Token was given to another client"
            }
        end
    end
    if not tokenDocument.valid then
        return tokenDocument, errors.InvalidToken {
            cause = "Access Token was invalidated"
        }
    end
    return tokenDocument, nil, false
end

function shared.invalidateToken(accessToken)
    local tokensDb = config.db:getCollection('goldenoak', 'tokens')
    local result, err = tokensDb:updateOne({accessToken = accessToken}, {["$set"]={valid=false, expirationDate=mongo.DateTime(math.floor(socket.gettime()*1000))}})
    if not result then
        return false, errors.InvalidToken {
            cause = "Access Token no longer exist"
        }
    end
    return true
end

return shared