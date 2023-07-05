local lapis = require("lapis")
local app = lapis.Application()

app:get("/", function()
  local versionInfo = require "misc.getVersionInfo"
  return {
    json = {
      name = "Golden Oak Auth server",
      branch = versionInfo.getCommit(),
      commit = ""
    }
  }
end)

return app
