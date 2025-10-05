local RuntimeException = require(script.Parent)

export type FailedToFindFieldException = RuntimeException.RuntimeException & {
    fieldName: string?,
    sourceTable: string?
}

local FailedToFindFieldException = setmetatable({},RuntimeException)
FailedToFindFieldException.__index = FailedToFindFieldException
setmetatable(FailedToFindFieldException, { __index = RuntimeException })

function FailedToFindFieldException.new(message: string,sourceTable: string, fieldName: string?) : FailedToFindFieldException
    local self: FailedToFindFieldException = RuntimeException.new(message) :: any
    self.name = "FailedToFindFieldException"
    self.sourceTable = sourceTable
    self.fieldName = fieldName

    setmetatable(self, FailedToFindFieldException)

    self:printStackTrace()
    
    return self
end

return FailedToFindFieldException