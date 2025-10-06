
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
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

local function DUMP_CORE_BEFORE_SHUTDOWN()
    print(`[DUMP_CORE_BEFORE_SHUTDOWN] telling core to generate a dump...`)
    local DUMP = Core:generateDump()
    print(`[DUMP_CORE_BEFORE_SHUTDOWN] dump generated, guid is {DUMP.dumpGuid}`)
    print(`[DUMP_CORE_BEFORE_SHUTDOWN] as JSON: {HttpService:JSONEncode(DUMP)}`)
    print(`[DUMP_CORE_BEFORE_SHUTDOWN] as table: `,DUMP)
end

function ServerMain.onServerClosing()
    print(`[ServerMain.onServerClosing] begin server shutdown proceedure at {DateTime.now():ToIsoDate()}`)

    -- dump core before we close...
    print(`[ServerMain.onServerClosing] generated a dump before we leave cus why not :)`)
    DUMP_CORE_BEFORE_SHUTDOWN()

    print(`[ServerMain.onServerClosing] ***** SERVER GOING DOWN NOW *****`)
end


function ServerMain:Main()
    Core:registerPipe("sendGlobalNotification")

    Core
        :addEventListener("playerAdded",    ServerMain.onPlayerAdded)
        :addEventListener("playerRemoving", ServerMain.onPlayerRemoving)
        :addEventListener("serverClosing",  ServerMain.onServerClosing)
    
    print('dumping...')
    task.wait(2)
end

return ServerMain