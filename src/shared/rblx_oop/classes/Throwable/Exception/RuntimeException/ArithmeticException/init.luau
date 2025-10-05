local RuntimeException = require(script.Parent)

export type ArithmeticException = RuntimeException.RuntimeException & {
    operation: string?,
}

local ArithmeticException = setmetatable({},RuntimeException)
ArithmeticException.__index = ArithmeticException
setmetatable(ArithmeticException, { __index = RuntimeException })

function ArithmeticException.toString(self: ArithmeticException)
    if self.operation then
        return `{self.name}: {self.message} (operation: {self.operation})`
    end
    
    return `{self.name}: {self.message} (operation: not provided)`
end

function ArithmeticException.new(message: string,operation: string?) : ArithmeticException
    local self: ArithmeticException = RuntimeException.new(message) :: any
    self.name = "ArithmeticException"
    self.operation = operation

    setmetatable(self, ArithmeticException)

    self:printStackTrace()
    
    return self
end

return ArithmeticException