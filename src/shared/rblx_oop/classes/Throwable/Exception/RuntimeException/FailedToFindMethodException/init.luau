local RuntimeException = require(script.Parent)

export type FailedToFindMethodException = RuntimeException.RuntimeException & {
    methodName: string?,
    sourceTable: string?
}

local FailedToFindMethodException = setmetatable({},RuntimeException)
FailedToFindMethodException.__index = FailedToFindMethodException
setmetatable(FailedToFindMethodException, { __index = RuntimeException })

function FailedToFindMethodException.new(message: string,sourceTable: string, methodName: string?) : FailedToFindMethodException
    local self: FailedToFindMethodException = RuntimeException.new(message) :: any
    self.name = "FailedToFindMethodException"
    self.sourceTable = sourceTable
    self.methodName = `{methodName}()`

    setmetatable(self, FailedToFindMethodException)

    self:printStackTrace()
    
    return self
end

return FailedToFindMethodException