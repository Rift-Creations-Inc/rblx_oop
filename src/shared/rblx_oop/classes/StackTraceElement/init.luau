local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

export type StackTraceElement = {
    func: string,
    file: string,
    line: number?,

    toString: (
        self: StackTraceElement,
        depth: number?
    ) -> string
}


local StackTraceElement = {}
StackTraceElement.__index = StackTraceElement

function StackTraceElement.new(level: number): StackTraceElement
    local src = debug.info(level,'s') or "[C]"
    local line = debug.info(level,'l') or -1
    local name = debug.info(level,'n') or "<anonymous>"

    if name == "" then 
        name = "<anonymous>" 
    end

    return setmetatable({
        func = name,
        file = src,
        line = line
    }, StackTraceElement)
end

local TraceFormatters = {}

function TraceFormatters.java(self: StackTraceElement, _: number?)
    return `at {self.func}({self.file}:{self.line or "?"})`
end

function TraceFormatters.lua(self: StackTraceElement, _: number?)
    return `Script {self.file}, Line {self.line or "?"} - function {self.func}`
end

function TraceFormatters.rust(self: StackTraceElement, _: number?)
    return `at {self.func} ({self.file}:{self.line or "?"})`
end

function TraceFormatters.dotnet(self: StackTraceElement, _: number?)
    return `at {self.func}() in {self.file}:line {self.line or "?"}`
end

function TraceFormatters.tree(self: StackTraceElement,depth: number?)
    local ident = string.rep(" ",depth)
    local arrow = depth > 0 and ">" or ""
    return `{ident}{arrow} {self.func}({self.file}:{self.line or "?"})`
end

function TraceFormatters.compact(self: StackTraceElement, _: number?)
    return `{self.func}()@{self.file}:{self.line}`
end

function StackTraceElement.toString(self: StackTraceElement, depth: number?): string
    local fmtName = config.global.traceStyle or "java"
    local formatter = TraceFormatters[fmtName]

    if not formatter then
        formatter = TraceFormatters.java
    end

    return formatter(self,depth or 0)
end

return StackTraceElement