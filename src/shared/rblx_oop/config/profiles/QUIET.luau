--[[
    @StaticClasss[
        Client
        Server
        Configuration
    ]

--]]

local Client = {
    askToContinue = false,
    debugClientMainRunner = false,
    debugGraphics = false,
    debugNotifications = false,
    memoryWatcher = {
        checkInterval = 15,
        threshold = 2500,
        debugCmw = false
    }
}

local Server = {
    debugServerMainRunner = false,
}

local Global = {
    doCoreDumps = true,
    debugCoreClass = false,
}

local Config = {
    ['client'] = Client,
    ['server'] = Server,
    ['global'] = Global,
}

return Config