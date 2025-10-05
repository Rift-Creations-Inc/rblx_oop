local RuntimeException = require(script.Parent)

export type InfiniteYieldPossibleException = RuntimeException.RuntimeException & {}

local InfiniteYieldPossibleException = setmetatable({},RuntimeException)
InfiniteYieldPossibleException.__index = InfiniteYieldPossibleException
setmetatable(InfiniteYieldPossibleException, { __index = RuntimeException })


function InfiniteYieldPossibleException.new(message: string) : InfiniteYieldPossibleException
    local self: InfiniteYieldPossibleException = RuntimeException.new(message) :: any
    self.name = "InfiniteYieldPossibleException"

    setmetatable(self, InfiniteYieldPossibleException)

    self:printStackTrace()
    
    return self
end

return InfiniteYieldPossibleException