local RuntimeException = require(script.Parent)

export type NotImplementedException =  RuntimeException.RuntimeException

local NotImplementedException = setmetatable({},RuntimeException)
NotImplementedException.__index = NotImplementedException
setmetatable(NotImplementedException, { __index = RuntimeException })


function NotImplementedException.new(message: string) : NotImplementedException
    local self: NotImplementedException = RuntimeException.new(message) :: any
    self.name = "NotImplementedException"

    setmetatable(self, NotImplementedException)

    self:printStackTrace()
    
    return self
end

return NotImplementedException