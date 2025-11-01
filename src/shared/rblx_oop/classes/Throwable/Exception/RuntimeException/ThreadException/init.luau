local RuntimeException = require(script.Parent)

export type ThreadException =  RuntimeException.RuntimeException

local ThreadException = setmetatable({},RuntimeException)
ThreadException.__index = ThreadException
setmetatable(ThreadException, { __index = RuntimeException })


function ThreadException.new(message: string) : ThreadException
    local self: ThreadException = RuntimeException.new(message) :: any
    self.name = "ThreadException"

    setmetatable(self, ThreadException)

    self:printStackTrace()
    
    return self
end

return ThreadException