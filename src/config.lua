local config = require "lapis.config"
local luasodium = require "luasodium"

--generate and liad salt
local file = io.open("../data/.salt", "rb")
local randombytes
if file then
  --- @type string
  randombytes = file:read("a")
else
  print("Generating salt")
  file = io.open("../data/.salt", "wb")
  assert(file, "failed to open .salt")
  --- @type string
  randombytes = luasodium.randombytes_buf(128)
  file:write(randombytes)
end
file:close()

local mongo = require("mongo")

local publicKey, secretKey = luasodium.crypto_sign_seed_keypair(randombytes:sub(1, 32))

config("development", {
  server = "cqueues",
  secret = randombytes:sub(1, luasodium.crypto_pwhash_SALTBYTES),
  publicKey = publicKey,
  secretKey = secretKey,
  db = mongo.Client(os.getenv("MONGODB_URL") or "mongodb://goldenoakadmin:goldenoak@localhost:27017/"),
  port = 9090
})
