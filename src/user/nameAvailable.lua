local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"

return function (request)
    local newName = request.params.name
    if not newName then
        return errors.NotFound()
    end
    local checkResult, cause = auth.checks.username(newName)
    if not checkResult then
        return errors.InvalidCredentials {
            cause=cause
        }
    end
    local usersDb = config.db:getCollection('goldenoak', 'users')
    if usersDb:findOne({username = request.params.name}) then
        return {json={
            status="DUPLICATE"
        }}
    end
    return {json={
        status="AVAILABLE"
    }}
end