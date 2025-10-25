local RuntimeException = require(script.Parent)

export type AlreadInitializedException = RuntimeException.RuntimeException

local AlreadInitializedException = setmetatable({},RuntimeException)
AlreadInitializedException.__index = AlreadInitializedException
setmetatable(AlreadInitializedException, { __index = RuntimeException })

function AlreadInitializedException.new(message: string) : AlreadInitializedException
    local self: AlreadInitializedException = RuntimeException.new(message) :: any
    self.name = "AlreadyInitializedException"

    setmetatable(self, AlreadInitializedException)

    self:printStackTrace()
    
    return self
end

return AlreadInitializedException