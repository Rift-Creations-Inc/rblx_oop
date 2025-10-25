local RuntimeException = require(game.ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException)

export type MemoryTrackingDisabledException = RuntimeException.RuntimeException

local MemoryTrackingDisabledException = setmetatable({},RuntimeException)
MemoryTrackingDisabledException.__index = MemoryTrackingDisabledException
setmetatable(MemoryTrackingDisabledException, { __index = RuntimeException })

function MemoryTrackingDisabledException.new(message: string) : MemoryTrackingDisabledException
    local self: MemoryTrackingDisabledException = RuntimeException.new(message) :: any
    self.name = "MemoryTrackingDisabledException"

    setmetatable(self, MemoryTrackingDisabledException)

    self:printStackTrace()
    
    return self
end

return MemoryTrackingDisabledException