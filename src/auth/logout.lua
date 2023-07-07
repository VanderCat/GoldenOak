local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()
local socket = require "socket"

--TODO: Rate limit: 3 operations/sec
--                  More -> timeout for 10 seconds
return function (request)
    ---@type table<string, (string | nil)>
    local body = cjson.decode(request.req:read_body_as_string())

    local checkResult, cause = auth.checks.username(body.username)
    if checkResult then
        checkResult, cause = auth.checks.password(body.password)
    end
    if not checkResult then
        return errors.InvalidCredentials{
            cause = cause
        }
    end

    local usersDb = config.db:getCollection('goldenoak', 'users')
    local user, err = usersDb:findOne{username=body.username}
    if not user then
        return errors.InvalidCredentials()
    end
    user = user:value()
    local correctPassword = auth.checks.hash(user.password[1], body.password)
    if not correctPassword then
        return errors.InvalidCredentials()
    end

    local tokensDb = config.db:getCollection('goldenoak', 'tokens')
    local result, err = tokensDb:updateMany({owner=mongo.Binary(user.uuid[1],4)}, {["$set"]={valid=false, expirationDate=mongo.DateTime(math.floor(socket.gettime()*1000))}})
    print(err)
    if not result then
        error(err)
    end

    return {status=204}
end