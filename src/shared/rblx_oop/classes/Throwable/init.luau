local StackTrace = require(script.Parent.StackTrace)

type StackTrace = StackTrace.StackTrace

export type Throwable = {
    message: string,
    name: string,
    stacktrace: StackTrace,

    toString: (self: Throwable) -> string,
    printStackTrace: (self: Throwable) -> (),
}

local Throwable = {}
Throwable.__index = Throwable

function Throwable.toString(self: Throwable) : Throwable
    return `{self.name}: {self.message}`
end

function Throwable.printStackTrace(self: Throwable)
    warn(self:toString())
    for _, v in self.stacktrace:toStringArray() do
        warn(`\tat {v}`)
    end
    print(` `)
    -- do this so the user can clearly see it
    task.wait(1.2)
end

function Throwable.new(name: string, message: string) : Throwable
    local self: Throwable = setmetatable({}, Throwable)

    self.name = name
    self.message = message
    self.stacktrace = StackTrace.capture(2)
    self.stacktrace:trimFirst(5) -- remove error constructor frames

    return self
end

return Throwable