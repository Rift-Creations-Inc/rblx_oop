
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)
local rCore = require(ReplicatedStorage.Shared.rblx_oop.classes.Core)
local Core = rCore.get()

SharedVars.waitForLoad()

local ServerMain = {}
ServerMain.__index = ServerMain

function ServerMain.onPlayerAdded(plr: Player)
    -- local core = require(game.ReplicatedStorage.Shared.rblx_oop.classes.Core).init() core.get():dispatchEvent("sendGlobalNotification","LOW","hi",20,true)
    Core:dispatchEvent("sendGlobalNotification","INFO",`{plr.Name} joined!`,6)
    print(`[ServerMain.onPlayerAdded] {plr.Name} has joined!`)
end

function ServerMain.onPlayerRemoving(plr: Player)
    print(`[ServerMain.onPlayerRemoving] {plr.Name} is leaving!`)
end

function ServerMain.onServerClosing()
    print(`[ServerMain.onServerClosing] the server is now closing, goodbye!`)
end

function ServerMain:Main()
    Core:registerBridge("sendGlobalNotification")

    Core
        :addEventListener("playerAdded",    ServerMain.onPlayerAdded)
        :addEventListener("playerRemoving", ServerMain.onPlayerRemoving)
        :addEventListener("serverClosing",  ServerMain.onServerClosing)
    
end

return ServerMain