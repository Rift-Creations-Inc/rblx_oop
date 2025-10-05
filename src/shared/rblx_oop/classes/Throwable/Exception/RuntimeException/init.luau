
local Exception = require(script.Parent)

local function _debug(str: string)
    print(`[DEBUG] [Throwable.Exception.RuntimeException] {str}`)
end

export type RuntimeException = Exception.Exception & {
    -- nothing special about RuntimeException
}

local RuntimeException = {}
RuntimeException.__index = RuntimeException
setmetatable(RuntimeException, { __index = Exception })

function RuntimeException.new(message: string) : RuntimeException
    local self: RuntimeException = Exception.new(message) :: any
    self.name = "RuntimeException"
    self.isChecked = false

    return setmetatable(self, RuntimeException)
end

return RuntimeException