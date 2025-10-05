local RuntimeException = require(script.Parent)

export type ServerOnlyException = RuntimeException.RuntimeException

local ServerOnlyException = {}
ServerOnlyException.__index = ServerOnlyException
setmetatable(ServerOnlyException, { __index = RuntimeException })


function ServerOnlyException.new(message: string) : ServerOnlyException
    local self: ServerOnlyException = RuntimeException.new(message) :: any
    self.name = "ServerOnlyException"

    setmetatable(self, ServerOnlyException)

    self:printStackTrace()
    
    return self
end

return ServerOnlyException