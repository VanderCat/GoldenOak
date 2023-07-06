local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()

return function (request)
    local body = cjson.decode(request.req:read_body_as_string())
    local usersDb = config.db:getCollection('goldenoak', 'users')
    local user, err = usersDb:findOne{username=body.username}
    if not user then
        return errors.InvalidCredentials()
    end
    user = user:value()
    local correctPassword = auth.checkHash(user.password[1], body.password)
    if not correctPassword then
        return errors.InvalidCredentials()
    end
    return "success!"
end