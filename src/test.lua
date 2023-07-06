local mongo = require 'mongo'
local uuid = require "misc.uuid"
local hex = require "misc.hex"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()

--- # Test endpoint
return function(request)
    local message = request.req:read_body_as_string()

    return {json=uuid.stringify(hex.from(uuid.stringify(uuid.generate())), true)}
end