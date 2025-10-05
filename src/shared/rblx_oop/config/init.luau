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

    configClass = "config::Client/root"
}

local Server = {
    debugServerMainRunner = true,

    configClass = "config::Server/root"
}

local Global = {
    debugCoreClass = true,

    configClass = "config::Global/root"
}

local Config = {
    ['client'] = Client,
    ['server'] = Server,
    ['global'] = Global,

    configClass = "config::root"
}

return Config