--[[
    @StaticClasss[
        Client
        Server
        Configuration
    ]

--]]

local Client = {
    askToContinue = true,
    debugClientMainRunner = true,
    debugGraphics = false,
    debugNotifications = true,
}

local Server = {
    debugServerMainRunner = true,
}

local Global = {
    debugCoreClass = true,
}

local Config = {
    ['client'] = Client,
    ['server'] = Server,
    ['global'] = Global,
}

return Config