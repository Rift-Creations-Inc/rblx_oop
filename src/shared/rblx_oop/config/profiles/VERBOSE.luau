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
        threshold = 3000,
        debugCmw = true,
        enabled = true,
    },
    defaultFont = Enum.Font.Code,
    textSizeMultiplier = 0.85,
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

    ['profileName'] = script.Name
}

return Config