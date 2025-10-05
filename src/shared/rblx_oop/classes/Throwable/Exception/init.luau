
local Throwable = require(script.Parent)

export type Exception = Throwable.Throwable & {
    isChecked: boolean
}

local Exception = setmetatable({}, Throwable)
Exception.__index = Exception
setmetatable(Exception, Throwable)

function Exception.new(message: string) : Exception
    local self: Exception = Throwable.new("Exception", message)
    self.isChecked = true
    return setmetatable(self, Exception)
end

return Exception