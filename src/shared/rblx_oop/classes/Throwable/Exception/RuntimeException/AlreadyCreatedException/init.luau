local RuntimeException = require(script.Parent)

export type AlreadyCreatedException = RuntimeException.RuntimeException

local AlreadyCreatedException = setmetatable({},RuntimeException)
AlreadyCreatedException.__index = AlreadyCreatedException
setmetatable(AlreadyCreatedException, { __index = RuntimeException })

function AlreadyCreatedException.new(message: string) : AlreadyCreatedException
    local self: AlreadyCreatedException = RuntimeException.new(message) :: any
    self.name = "AlreadyCreatedException"

    setmetatable(self, AlreadyCreatedException)

    self:printStackTrace()
    
    return self
end

return AlreadyCreatedException