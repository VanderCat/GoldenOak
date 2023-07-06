local luasodium = require "luasodium"

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
--- @param dashesEnabled boolean
--- @return string fancyUuid
function uuid.stringify(binaryUuid, dashesEnabled)
    local uuidString = ""
    local uuidBytes = {string.unpack(">BBBBBBBBBBBBBBBB", binaryUuid)}
    for _, byte in pairs(uuidBytes) do
        local byte = ("%x"):format(byte)
        if #byte < 2 then 
            byte = "0"..byte
        end
        uuidString = uuidString..byte
    end
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

return uuid