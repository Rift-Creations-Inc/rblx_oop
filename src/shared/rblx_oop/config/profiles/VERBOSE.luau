--[[
    @StaticClasss[
        Client
        Server
        Configuration
    ]

--]]

local Client = {
    askToContinue = false,
    debugClientMainRunner = true,
    debugGraphics = true,
    debugNotifications = true,
    memoryWatcher = {
        checkInterval = 15,
        threshold = 2500,
        debugCmw = true,
    },
    defaultFont = Enum.Font.RobotoMono,
}

local Server = {
    debugServerMainRunner = true,
}

local Global = {
    doCoreDumps = true,
    debugCoreClass = true,
}

local Config = {
    ['client'] = Client,
    ['server'] = Server,
    ['global'] = Global,
}

return Config