local hex = {}

function hex.to(binary)
    local variableType = type(binary)
    if variableType == "number" then
        local string = ("%x"):format(binary)
        string = ("0"):rep(#string%2)..string
        return string
    end
    if variableType == "string" then
        local numTable = {}
        for i = 1, #binary do
            numTable[i] = (">B"):unpack(binary:sub(i,i)) 
        end
        return hex.to(numTable)
    end
    if variableType == "table" then
        local string = ""
        for _, item in ipairs(binary) do
            string = string..hex.to(item)
        end
        return string
    end
    error("Can't convert "..variableType.."("..tostring(binary)..") to hex")
end

function hex.from(hexCode, isInt)
    local bytes = ""
    if isInt then
        return tonumber(hexCode, 16)
    end
    for i = 1, #hexCode, 2 do
        bytes = bytes..(">B"):pack(tonumber(hexCode:sub(i, i+1),16))
    end
    return bytes
end

return hex