local errors = require "errorList"
local lapis = require "lapis"

local app = lapis.Application()

app:match("*", function()
  return errors.MethodNotAllowed()
end)

app:post("*", function()
  return errors.NotFound()
end)

app:match("/", function()
  local versionInfo = require "misc.getVersionInfo"
  return {
    json = {
      identity = "Golden Oak Auth server",
      branch = versionInfo.getBranch(),
      lastChange = versionInfo.lastChange(),
      commit = versionInfo.getCommit()
    }
  }
end)

app:post("/authenticate", function(request)
  local auth = require "auth.login"
  return auth(request)
end)
app:post("/register", function(request)
  local auth = require "auth.register"
  return auth(request)
end)
app:post("/refresh", function(request)
  local auth = require "auth.refresh"
  return auth(request)
end)
app:post("/validate", function(request)
  local auth = require "auth.validate"
  return auth(request)
end)
app:post("/invalidate", function(request)
  local auth = require "auth.invalidate"
  return auth(request)
end)
app:post("/signout", function(request)
  local auth = require "auth.logout"
  return auth(request)
end)
app:post("/changepassword", function(request)
  return require "auth.changePassword" (request)
end)

app:put("/changename/:name", function(request)
  return require "user.changeName" (request)
end)
app:get("/checkname/:name", function(request)
  return require "user.nameAvailable" (request)
end)

app:get("/session/minecraft/hasJoined", function(request)
  return require "session.hasJoined" (request)
end)

app:post("/session/minecraft/join", function(request)
  return require "session.join" (request)
end)

app:get("/session/minecraft/profile/:uuid", function(request)
  return require "session.profile" (request)
end)

app:match("/test", function(request)
  local test = require "test"
  return test(request)
end)

function app:handle_404()
  return errors.NotFound()
end

function app:handle_error(err, trace)
  print(err)
  print(trace)
  if os.getenv("GOLDENOAK_DEBUG") then
    return errors.new{error=err, errorMessage=trace}()
  else
    return errors.new{error="Internal Server Error", errorMessage="Something went wrong"}()
  end
end

return app
