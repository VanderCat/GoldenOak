local function error(table)
    table.__mt = {
        __call = function (t, override)
            return function()
                override = override or {}
                return {
                    status = override.status or t.status or 500,
                    layout = false,
                    json = {
                        error = override.error or t.error or "Unknown Error",
                        cause = override.cause or t.cause,
                        errorMessage = override.errorMessage or t.errorMessage or ""
                    }
                }
            end
        end,
        __index = table
    }
    local newTable = {}
    setmetatable(newTable, table.__mt)
    return newTable
end

return {
    --- An attempt to send a POST request with incorrect request headers to any endpoint
    UnsupportedMediaType = error {
        status = 415,
        error = "Unsupported Media Type",
        errorMessage = "The server is refusing to service the request because the entity of the request is in a format not supported by the requested resource for the requested method "
    },
    --- An attempt to use a request method other than POST to access any of the endpoints. 
    MethodNotAllowed = error {
        status = 405,
        error = "Method Not Allowed",
        errorMessage = "The method specified in the request is not allowed for the resource identified by the request URI"
    },
    --- An attempt to send a request to a non-existent endpoint. 
    NotFound = error {
        status = 404,
        error = "Not Found",
        errorMessage = "The server has not found anything matching the request URI"
    },
    --- An attempt to sign in using invalid credentials. 
    InvalidCredentials = error {
        status = 403,
        error = "ForbiddenOperationException",
        errorMessage = "Invalid credentials. Invalid username or password."
    },
    --- An attempt to refresh an access token that has been invalidated, no longer exists, or has been erased. 
    InvalidToken = error {
        status = 403,
        error = "ForbiddenOperationException",
        errorMessage = "Invalid token"
    },
    --- An attempt to register using existing nickname. 
    NicknameTaken = error {
        status = 403,
        error = "ForbiddenOperationException",
        errorMessage = "Invalid credentials. Username is already taken."
    },
    new = error
}