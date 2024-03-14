local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"
local uuid = require "misc.uuid"

return function (request)
    local body = cjson.decode(request.req:read_body_as_string())
    local accessToken = body.accessToken
    local check, err = auth.checks.accessToken(accessToken)
    if not check then 
        return errors.InvalidSession{errorMessage=err}
    end
    local id = body.selectedProfile
    if not id then 
        return errors.InvalidSession{errorMessage="uuid is  missing"}
    end
    if not uuid.isUuid(id) then
        return errors.InvalidSession{errorMessage="uuid is not correct"}
    end
    local serverId = body.serverId
    if not serverId then
        return errors.InvalidSession({errorMessage="no serverId"})
    end
    local token, err = auth.getToken(accessToken)
    if err then
        return err
    end
    local usersDb = config.db:getCollection('goldenoak', 'users')
    local user = usersDb:findOne({uuid=mongo.Binary(token.owner[1], 4)})
    if not user then
        return errors.new{}()
    end
    user = user:value()
    if uuid.stringify(user.uuid[1]) ~= id then
        return errors.InvalidSession({errorMessage="Token was given to another user."})
    end
    local serversDb = config.db:getCollection('goldenoak', 'servers')
    serversDb:insert{
        _id = mongo.ObjectID(),
        username = user.username,
        serverId = serverId
    }
    return {status=204}
end