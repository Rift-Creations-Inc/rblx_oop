local RuntimeException = require(script.Parent)

export type TaskException =  RuntimeException.RuntimeException

local TaskException = setmetatable({},RuntimeException)
TaskException.__index = TaskException
setmetatable(TaskException, { __index = RuntimeException })


function TaskException.new(message: string) : TaskException
    local self: TaskException = RuntimeException.new(message) :: any
    self.name = "TaskException"

    setmetatable(self, TaskException)

    self:printStackTrace()
    
    return self
end

return TaskException