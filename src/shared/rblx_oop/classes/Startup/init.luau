
export type Startup = {
   isLoaded: () -> boolean,
   loadedEvent: RBXScriptSignal 
}

local Startup = {}
Startup.__index = Startup

function isLoaded(): boolean
    return game:IsLoaded()
end

function Startup.new(): Startup
    local self: Startup = {}
    self.isLoaded = isLoaded
    self.loadedEvent = game.Loaded

    return self
end

return Startup