
--[[

    The following class is used by
    `TaskMgr,` as a way to organize
    task data.

--]]

--[[ @ForOtherClass TaskMgr ]]
export type TaskInfo = {
    tid: number,
    name: string,
    thread: thread,
    created: number,
    alive: boolean
}

return {}