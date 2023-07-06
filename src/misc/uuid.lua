local luasodium = require "luasodium"

--- uuidv4 generation
local uuid = {}

function uuid.generate()
    local randomBytes = {string.unpack(">BBBBBBBBBBBBBBBB", luasodium.randombytes_buf(16))}
    randomBytes[7] = (randomBytes[7] & 0x0f) | 0x40 --version
    randomBytes[7] = (randomBytes[7] & 0x3f) | 0x80 --variant
    return string.pack(">BBBBBBBBBBBBBBBB", table.unpack(randomBytes))
end

function uuid.stringify(binaryUuid, dashesEnabled)
    local uuidString = ""
    local uuidBytes = {string.unpack(">BBBBBBBBBBBBBBBB", binaryUuid)}
    for _, byte in pairs(uuidBytes) do
        uuidString = uuidString..("%x"):format(byte)
    end
    if dashesEnabled then
        uuidString = uuidString:sub(1, 8)..'-'..uuidString:sub(9, 12)..'-'..uuidString:sub(13, 16)..'-'..uuidString:sub(17, 20)..'-'..uuidString:sub(21, 32)
    end
    return uuidString
end

function uuid.parse()
    error("NYI")
end

return uuid