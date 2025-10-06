--[[
    @StaticClasss[
        Client
        Server
        Configuration
    ]

--]]

local Client = {
    debugClientMainRunner = true,
    debugGraphics = true,
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