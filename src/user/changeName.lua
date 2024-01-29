local cjson = require "cjson"
local mongo = require 'mongo'
local errors = require "errorList"
local config = require("lapis.config").get()
local auth = require "auth.shared"
local socket = require "socket"

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
    local user = usersDb:findOne({uuid=mongo.Binary(token.owner[1], 4)})
    if usersDb:findOne({username = request.params.name}) then
        return errors.NicknameTaken()
    end
    local user, err = usersDb:updateOne({uuid=mongo.Binary(token.owner[1], 4)}, {
        ["$set"]={
            username = request.params.name,
            lastUsernameChangeDate = mongo.DateTime(math.floor(socket.gettime()*1000))
        }, ["$addToSet"]={
            previousNames=user:value().username
        }
    })
    if err then
        error(err)
    end
    return {json={
        name = newName,
        skins = cjson.empty_array,
        capes = cjson.empty_array --TODO: Skins and capes
    }}
end