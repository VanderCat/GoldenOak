local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"
local uuid = require "misc.uuid"
local mongo = require 'mongo'

return function (request)
    local id = request.params.uuid
    if (id == nil) then 
        return errors.InvalidCredentials()
    end
    
    local usersDb = config.db:getCollection('goldenoak', 'users')
    local userRecord = usersDb:findOne({uuid=mongo.Binary(uuid.parse(id), 4)})
    if userRecord then
        userRecord = userRecord:value()
        return {json={
            legacy = false,
            id = uuid,
            name = userRecord.username,
            properties = {
                {
                    name = "textures",
                    value = "",
                }
            }
        }}
    end
    return errors.InvalidCredentials()
end