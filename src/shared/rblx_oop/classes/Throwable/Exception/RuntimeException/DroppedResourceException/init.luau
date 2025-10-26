local RuntimeException = require(script.Parent)

export type DroppedResourceException =  RuntimeException.RuntimeException

local DroppedResourceException = setmetatable({},RuntimeException)
DroppedResourceException.__index = DroppedResourceException
setmetatable(DroppedResourceException, { __index = RuntimeException })


function DroppedResourceException.new(message: string) : DroppedResourceException
    local self: DroppedResourceException = RuntimeException.new(message) :: any
    self.name = "DroppedResourceException"

    setmetatable(self, DroppedResourceException)

    self:printStackTrace()
    
    return self
end

return DroppedResourceException