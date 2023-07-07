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
    local response = {}

    local tokenDocument, error = auth.getToken(body.accessToken, body.clientToken)
    if error then
        return error
    end

    local usersDb = config.db:getCollection('goldenoak', 'users')
    local user, err = usersDb:findOne{uuid=mongo.Binary(tokenDocument.owner[1], 4)}
    if not user then
        return errors.new{}()
    end
    user = user:value()

    local profile = {
        id = uuid.stringify(user.uuid[1], true),
        name = user.username
    }
    response.selectedProfile = profile

    if body.requestUser then
        response.user = {
            username = user.username, --TODO: use email
            properties = cjson.empty_array, --TODO: user properties
            id = "" -- TODO: wth is remoteID?????????????
        }
    end
    
    response.clientToken = body.clientToken
    response.accessToken = auth.generateAccessToken(tokenDocument.owner[1], body.clientToken)
    local result, err = auth.invalidateToken(body.accessToken)
    if err then
        return err
    end

    return {json=response}
end