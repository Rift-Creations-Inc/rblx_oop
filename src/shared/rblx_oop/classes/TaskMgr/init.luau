local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.TaskException)

--[[ @Implements ]]
local _ = require(script.Parent.TaskInfo)

type _any_func = (...any) -> any

--[[ @implements TaskInfo ]]
export type TaskMgr = {
    spawn: (
        name: string,
        f: _any_func,
        ...any
    ) -> _.TaskInfo,

    defer: (
        name: string,
        f: _any_func,
        ...any
    ) -> _.TaskInfo,

    delay: (
        name: string, 
        seconds: number, 
        f: _any_func,
        ...any
    ) -> _.TaskInfo,

    wait: (
        seconds: number?
    ) -> number,

    cancel: (
        tid: number
    ) -> boolean,

    get: (
        tid: number
    ) -> _.TaskInfo?,

    list: (

    ) -> { _.TaskInfo },

    current: (

    ) -> _.TaskInfo?,

    exit: (
        
    ) -> (),

    _internal_:  {
        nextId: number,
        tasks: { [number] : _.TaskInfo },
        threadMap: { [thread] : _.TaskInfo }
    }
}

local TaskMgr: TaskMgr = {
    _internal_ = {
        nextId = 0,
        tasks = {} :: { [number] : _.TaskInfo },
        threadMap = {} :: { [thread] : _.TaskInfo }
    }
}

local function newTask(name: string, thread: thread): _.TaskInfo
    TaskMgr._internal_.nextId += 1
    local info: _.TaskInfo = {
        id = TaskMgr._internal_.nextId,
        name = name,
        thread = thread,
        created = os.clock(),
        alive = true
    }

    TaskMgr._internal_.tasks[info.id] = info
    TaskMgr._internal_.threadMap[info.thread] = info

    return info
end

function TaskMgr.current(): _.TaskInfo?
    local co = coroutine.running()
    return if co then TaskMgr._internal_.threadMap[co] else nil
end

function TaskMgr.exit()
    local co = coroutine.running()
    if not co then return end
    local info = TaskMgr._internal_.threadMap[co]
    if info then
        TaskMgr._internal_.tasks[info.id] = nil
        TaskMgr._internal_.threadMap[co] = nil
    end
    coroutine.close(co)
end

function TaskMgr.spawn(name: string, f: _any_func, ...: any): _.TaskInfo
    local rco = coroutine.create(function(...)
        f(...)
        local co = coroutine.running()
        local info = TaskMgr._internal_.threadMap[co]
        if info then
            TaskMgr._internal_.tasks[info.id] = nil
            TaskMgr._internal_.threadMap[co] = nil
        end
    end)
    task.spawn(rco, ...)
    return newTask(name, rco)
end

function TaskMgr.defer(name: string, f: _any_func, ...: any): _.TaskInfo
    local rco = coroutine.create(function(...)
        f(...)
        local co = coroutine.running()
        local info = TaskMgr._internal_.threadMap[co]
        if info then
            TaskMgr._internal_.tasks[info.id] = nil
            TaskMgr._internal_.threadMap[co] = nil
        end
    end)
    task.defer(rco, ...)
    return newTask(name, rco)
end

function TaskMgr.delay(name: string, seconds: number, f: (...any)->(), ...: any): _.TaskInfo
    local rco = coroutine.create(function(...)
        f(...)
        local co = coroutine.running()
        local info = TaskMgr._internal_.threadMap[co]
        if info then
            TaskMgr._internal_.tasks[info.id] = nil
            TaskMgr._internal_.threadMap[co] = nil
        end
    end)
    task.delay(name,seconds,f)
    return newTask(name, rco)
end

function TaskMgr.wait(seconds: number?): number
    return task.wait(seconds)
end

function TaskMgr.cancel(tid: number): boolean
    local info = TaskMgr._tasks[tid]
    if not info then 
        TaskException.new(`unable to cancel task - tid {tid} does not exist!`)
    end
    task.cancel(info.thread)
    TaskMgr._internal_.tasks[tid] = nil
    TaskMgr._internal_.threadMap[info.thread] = nil
    return true
end

function TaskMgr.get(tid: number): _.TaskInfo?
    local info = TaskMgr._internal_.tasks[tid]
    if not info then
        TaskException.new(`unable to get task info - tid {tid} does not exist!`)
        return nil
    end
    return TaskMgr._internal_.tasks[tid]
end

function TaskMgr.list(): { _.TaskInfo }
    local list = {}
    for _, info in pairs(TaskMgr._internal_.tasks) do 
        table.insert(list, info)
    end
    return list
end

return TaskMgr