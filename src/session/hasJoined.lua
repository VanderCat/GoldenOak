local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"
local uuid = require "misc.uuid"

return function (request)
    local username = request.params.username
    if (username == nil) then 
        return errors.InvalidSession()
    end
    local serverId = request.params.serverId
    if (serverId == nil) then
        return errors.InvalidSession()
    end
    local ip = request.params.id

    local serversDb = config.db:getCollection('goldenoak', 'servers')
    local userRecord = serversDb:findOne({username=username})
    if userRecord then
        return {json={
            id = uuid.stringify(config.db:getCollection('goldenoak', 'users'):findOne({username=username}):value().uuid[1]),
            name = username,
            properties = {
                {
                    name = "textures",
                    value = "",
                    signature = "<base64 string; signed data using Yggdrasil's private key>"
                }
            }
        }}
    end
    return errors.InvalidSession()
end