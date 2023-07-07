local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()

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

    local response = {}

    local clientToken, newClientToken = body.clientToken, false
    if not clientToken then
        --TODO: Invalidate all tokens? not sure...
        clientToken = uuid.generate()
        newClientToken = true
    else
        local valid, err = auth.checks.clientToken(clientToken)
        if not valid then
            return errors.InvalidToken {
                cause = err
            }
        end
    end
    response.clientToken = newClientToken and uuid.stringify(clientToken, true) or clientToken
    
    local accessToken, err = auth.generateAccessToken(user.uuid[1], response.clientToken)
    if  not accessToken then
        error(err)
    end
    response.accessToken = accessToken

    local profile = {
        id = uuid.stringify(user.uuid[1], true),
        name = user.username
    }
    response.availableProfiles = {profile}
    response.selectedProfile = profile

    if body.requestUser then
        response.user = {
            username = user.username, --TODO: use email
            properties = cjson.empty_array, --TODO: user properties
            id = "" -- TODO: wth is remoteID?????????????
        }
    end

    return {json=response}
end