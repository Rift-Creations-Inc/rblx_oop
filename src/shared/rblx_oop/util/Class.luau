
local Class = {}
Class.__index = Class

function Class.HasMethod(x: {any}, methodName: string): boolean
    local ok, _ = pcall(function()
        x[methodName]()
    end)

    if not ok then
        return false
    end

    return true
end

return Class