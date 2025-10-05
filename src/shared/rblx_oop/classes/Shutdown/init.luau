
export type Shutdown = {
    bindToClose: (
        ...any
    ) -> ...any,

    closeEvent: RBXScriptSignal
}

local Shutdown = {}
Shutdown.__index = Shutdown

function bindToClose(func: (...any) -> (...any))
    game:BindToClose(func)
end

function Shutdown.new(): Shutdown
    local self: Shutdown = {}
    self.bindToClose = bindToClose
    self.closeEvent = game.Close

    return self
end

return Shutdown