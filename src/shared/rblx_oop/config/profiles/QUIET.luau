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
        threshold = 3000,
        debugCmw = false,
        enabled = true,
    },
    defaultFont = Enum.Font.RobotoMono,
    textSizeMultiplier = 1,
}

local Server = {
    debugServerMainRunner = false,
}

local Global = {
    doCoreDumps = true,
    debugCoreClass = false,
    traceStyle = "java",
    useFullTrace = false,
    debugThreads = false
}

local Config = {
    ['client'] = Client,
    ['server'] = Server,
    ['global'] = Global,

    ['profileName'] = script.Name
}

return Config