
export type StackTraceElement = {
    func: string,
    file: string,
    line: number?,

    toString: (
        self: StackTraceElement
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

function StackTraceElement.toString(self: StackTraceElement): string
    return `{self.func}({self.file}:{self.line or "?"})`
end

return StackTraceElement