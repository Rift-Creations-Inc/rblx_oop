
local Throwable = require(script.Parent)

export type Error = Throwable.Throwable & {
    isFatal: true
}

local Error = setmetatable({}, Throwable)
Error.__index = Error
setmetatable(Error, { __index = Throwable})

function Error.new(message: string) : Error
    local self: Error = Throwable.new("Error", message)
    self.isFatal = true
    return setmetatable(self, Error)
end

return Error