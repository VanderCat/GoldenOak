local config = require "lapis.config"
local luasodium = require "luasodium"

--generate and liad salt
local file = io.open("../data/.salt", "rb")
local randombytes
if file then
  randombytes = file:read("a")
else
  file = io.open("../data/.salt", "wb")
  assert(file, "failed to open .salt")
  randombytes = luasodium.randombytes_buf(luasodium.crypto_pwhash_SALTBYTES)
  file:write(randombytes)
end
file:close()

local mongo = require("mongo")

config("development", {
  server = "cqueues",
  secret = randombytes,
  db = mongo.Client(os.getenv("MONGODB_URL") or "mongodb://goldenoakadmin:goldenoak@localhost:27017/"),
  port = 9090
})
