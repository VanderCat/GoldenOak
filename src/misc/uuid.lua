local luasodium = require "luasodium"
local hex = require "misc.hex"
--- uuidv4 generation
local uuid = {}

--- ### Generate uuid v4
--- pure random <sup>TM</sup>
--- @return string uuid 
function uuid.generate()
    local randomBytes = {string.unpack(">BBBBBBBBBBBBBBBB", luasodium.randombytes_buf(16))}
    randomBytes[7] = (randomBytes[7] & 0x0f) | 0x40 --version
    randomBytes[7] = (randomBytes[7] & 0x3f) | 0x80 --variant
    return string.pack(">BBBBBBBBBBBBBBBB", table.unpack(randomBytes))
end

--- @param binaryUuid string
--- @param dashesEnabled ?boolean
--- @return string fancyUuid
function uuid.stringify(binaryUuid, dashesEnabled)
    local uuidString = hex.to(binaryUuid)
    if dashesEnabled then
        uuidString = uuidString:sub(1, 8)..'-'..uuidString:sub(9, 12)..'-'..uuidString:sub(13, 16)..'-'..uuidString:sub(17, 20)..'-'..uuidString:sub(21, 32)
    end
    return uuidString
end

--- @param fancyUuid string
--- @return string binaryUuid
function uuid.parse(fancyUuid)
    fancyUuid = fancyUuid:gsub("-", "")
    local result = fancyUuid:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end)
    return result
end

--TODO: add bit check
--- @param fancyUuid string
--- @return boolean isUuid
function uuid.isUuid(fancyUuid)
    local isDashed = fancyUuid:find("^%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w$")
    local monolith = fancyUuid:find("^%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w$")
    return (monolith or isDashed) ~= nil
end

return uuid