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