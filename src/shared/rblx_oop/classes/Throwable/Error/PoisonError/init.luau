local Error = require(script.Parent)
type Error = Error.Error


export type PoisonError<T> = {
    lockedValue: T?,
} & Error

local PoisonError = setmetatable({}, Error)
PoisonError.__index = PoisonError
setmetatable(PoisonError, { __index = Error })

function PoisonError.new<T>(message: string,value: T?): PoisonError<T>
    warn(`new PoisonError `)
    local self = Error.new("PoisonError", message) :: PoisonError<T>
    self.lockedValue = value
    
    setmetatable(self, Error)

    self:printStackTrace()

    return self
end

return PoisonError