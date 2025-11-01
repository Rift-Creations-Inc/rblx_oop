local ReplicatedStorage = game:GetService("ReplicatedStorage")

local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local StackTraceElement = require(script.Parent.StackTraceElement)

type StackTraceElement = StackTraceElement.StackTraceElement

export type StackTrace = {
    elements: { StackTraceElement },

    toArray: (
        self: StackTrace
    ) -> { StackTraceElement },

    toStringArray: (
        self: StackTrace
    ) -> { string },

    print: (
        self: StackTrace
    ) -> (),

    trimFirst: (
        self: StackTrace,
        n: number
    ) -> never,
}

local StackTrace = {}
StackTrace.__index = StackTrace

function StackTrace.capture(skip: number?): StackTrace
    local elms = {}
    local level = (skip or 2)
    
    if config.global.useFullTrace then
        level = 0
    end

    while true do
        local src = debug.info(level,'s')
        if not src then break end
        table.insert(elms, StackTraceElement.new(level))
        level += 1
    end

    return setmetatable({ elements = elms}, StackTrace)
end

function StackTrace.toArray(self: StackTrace): { StackTraceElement }
    return self.elements
end

function StackTrace.toStringArray(self: StackTrace): { string }
    local arr = {}
    for i, el in ipairs(self.elements) do
        table.insert(arr,el:toString( i - 1 ))
    end
    return arr
end

function StackTrace.trimFirst(self: StackTrace, n: number?)
    for _ = 1, n do 
        table.remove(self.elements,1)
    end
end

function StackTrace.print(self: StackTrace)
    for _, el in ipairs(self.elements) do
        print(`\t{el:toString()}`)
    end
end

return StackTrace