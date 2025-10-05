local RuntimeException = require(script.Parent)

export type UnitializedObjectException = RuntimeException.RuntimeException

local UnitializedObjectException = setmetatable({},RuntimeException)
UnitializedObjectException.__index = UnitializedObjectException
setmetatable(UnitializedObjectException, { __index = RuntimeException })

function UnitializedObjectException.new(message: string) : UnitializedObjectException
    local self: UnitializedObjectException = RuntimeException.new(message) :: any
    self.name = "UnitializedObjectException"

    setmetatable(self, UnitializedObjectException)

    self:printStackTrace()
    
    return self
end

return UnitializedObjectException