local mongo = require 'mongo'
local uuid = require "misc.uuid"
local errors = require "errorList"
local cjson = require "cjson"
local luasodium = require "luasodium"
local auth = require "auth.shared"
local config = require("lapis.config").get()
local socket = require "socket"

--TODO: Rate limit: 3 operations/sec
--                  More -> timeout for 10 seconds
return function (request)
    ---@type table<string, (string | nil)>
    local body = cjson.decode(request.req:read_body_as_string())
    local response = {}

    local valid, err = auth.checks.accessToken(body.accessToken)
    if not valid then
        return errors.InvalidToken {
            cause = err
        }
    end
    if body.clientToken then
        local valid, err = auth.checks.clientToken(body.clientToken)
        if not valid then
            return errors.InvalidToken {
                cause = err
            }
        end
    end
    local tokensDb = config.db:getCollection('goldenoak', 'tokens')
    local tokenDocument, err = tokensDb:findOne{accessToken = body.accessToken}
    if not tokenDocument then
        print(err)
        return errors.InvalidToken {
            cause = "Access Token does not exist"
        }
    end
    tokenDocument = tokenDocument:value()
    if body.clientToken then
        if tokenDocument.clientToken[1] ~= body.clientToken then
            return errors.InvalidToken {
                cause = "Access Token was given to another client"
            }
        end
    end
    if not tokenDocument.valid then
        return errors.InvalidToken {
            cause = "Access Token was invalidated"
        }
    end

    return {status=204}
end