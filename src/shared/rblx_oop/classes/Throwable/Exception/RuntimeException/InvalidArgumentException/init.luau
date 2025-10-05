local RuntimeException = require(script.Parent)

export type InvalidArgumentException = RuntimeException.RuntimeException & {
    paramName: string?,
}

local InvalidArgumentException = setmetatable({},RuntimeException)
InvalidArgumentException.__index = InvalidArgumentException
setmetatable(InvalidArgumentException, { __index = RuntimeException })


function InvalidArgumentException.new(message: string,paramName: string?) : InvalidArgumentException
    local self: InvalidArgumentException = RuntimeException.new(message) :: any
    self.name = "InvalidArgumentException"
    self.paramName = paramName

    setmetatable(self, InvalidArgumentException)

    self:printStackTrace()
    
    return self
end

return InvalidArgumentException