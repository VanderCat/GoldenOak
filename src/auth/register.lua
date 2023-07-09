local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()
local socket = require "socket"

return function (request)
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
    if user then
        return errors.NicknameTaken()
    end

    local hash = auth.createHash(body.password)
    local result, err = usersDb:insert{
        _id = mongo.ObjectID(),
        uuid = mongo.Binary(uuid.generate(), 4),
        username = body.username,
        password = mongo.Binary(hash, 128),
        registrationDate = mongo.DateTime(math.floor(socket.gettime()*1000))
    }
    if not result then
        error(err)
    end
    return {json={}}
end