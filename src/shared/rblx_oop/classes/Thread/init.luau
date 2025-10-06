
export type Thread = {
    start: (
        self: Thread
    ) -> Thread,

    --[[ @OverrideMe ]]
    run: (
        self: Thread
    ) -> Thread,

    exit: (
        self: Thread
    ) -> Thread,

    name: string,

    tid: number
}

local Thread = {}
Thread.__index = Thread

function Thread.start(self: Thread)
    task.desynchronize()

    Thread.start(self)
end

function Thread.exit(self: Thread)
    task.synchronize()

    return
end

--[[ @OverrideMe ]]
function Thread.run(self: Thread)
    error(`Thread.run() is ment to be overrided!`)
end

function Thread.new(name: string): Thread
    local self: Thread = setmetatable({}, Thread)
    self.name = name
    self.tid = math.random(1,1024)

    return self
end

return Thread