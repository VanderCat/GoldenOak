--- Returns table with string separated by sep (supports lua patterns)
---@param s string
---@param sep ?string lua pattern
---@return table<string>
function string.split (s, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end
