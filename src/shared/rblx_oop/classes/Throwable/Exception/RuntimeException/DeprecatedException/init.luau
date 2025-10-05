local RuntimeException = require(script.Parent)

export type DeprecatedException = RuntimeException.RuntimeException

local DeprecatedException = setmetatable({},RuntimeException)
DeprecatedException.__index = DeprecatedException
setmetatable(DeprecatedException, { __index = RuntimeException })


function DeprecatedException.new(message: string) : DeprecatedException
    local self: DeprecatedException = RuntimeException.new(message) :: any
    self.name = "DeprecatedException"

    setmetatable(self, DeprecatedException)

    self:printStackTrace()
    
    return self
end

return DeprecatedException