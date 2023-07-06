local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()

--- # Test endpoint
return function(request)
    local id = uuid.generate()
    return {json=uuid.parse(uuid.stringify(id, true))==id}
end