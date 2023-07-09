local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"

return function (request)
    --- @type string
    local tokenHeader = request.req.headers["authorization"]
    if not tokenHeader then 
        return errors.InvalidCredentials()
    end
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
    local tokenString = tokenHeader:split()[2]

    local token, err = auth.getToken(tokenString)
    if err then
        return err
    end

    local usersDb = config.db:getCollection('goldenoak', 'users')
    if usersDb:findOne({username = request.params.name}) then
        return errors.NicknameTaken()
    end
    local user, err = usersDb:updateOne({uuid=mongo.Binary(token.owner[1], 4)}, {["$set"]={username = request.params.name}})
    if err then
        error(err)
    end
end