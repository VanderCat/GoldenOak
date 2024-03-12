local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"

return function (request)
    local username = request.params.username
    if (username == nil) then 
        return errors.NotFound()
    end
    local serverId = request.params.serverId
    if (serverId == nil) then
        return errors.NotFound()
    end
    local ip = request.params.id

    local serversDb = config.db:getCollection('goldenoak', 'servers')
    local userRecord = serversDb:findOne({username=username})
    if userRecord then
        return
    end
    return errors.InvalidCredentials()
end