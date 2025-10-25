local RuntimeException = require(game.ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException)

export type CoreDumpsDisabledException = RuntimeException.RuntimeException

local CoreDumpsDisabledException = setmetatable({},RuntimeException)
CoreDumpsDisabledException.__index = CoreDumpsDisabledException
setmetatable(CoreDumpsDisabledException, { __index = RuntimeException })

function CoreDumpsDisabledException.new(message: string) : CoreDumpsDisabledException
    local self: CoreDumpsDisabledException = RuntimeException.new(message) :: any
    self.name = "CoreDumpsDisabledException"

    setmetatable(self, CoreDumpsDisabledException)

    self:printStackTrace()
    
    return self
end

return CoreDumpsDisabledException