local errors = require "errorList"
local lapis = require "lapis"

local app = lapis.Application()

app:get("/", function()
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
function app:handle_404()
  return errors.NotFound()
end

return app
