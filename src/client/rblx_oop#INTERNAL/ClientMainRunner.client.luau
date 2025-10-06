local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local Players = game:GetService("Players")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()
local DebugMaster = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugMaster)
local DebugMinimal = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugMinimal)
local DebugScreen = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugScreen)
local DebugServerInfo = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugServerInfo)
local DebugSharedVars = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugSharedVars)
local MemoryScreen = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.MemoryScreen)


local function write(txt: string)
    if config.client.debugClientMainRunner then
        print(`[ClientMainRunner] {txt}`)
    end
end

write(`waiting for core to be loaded...`)
repeat 
    task.wait() 
until Core.initialized
write(`done`)

-- put it down here so Core can do it's stuff first
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)

SharedVars.waitForLoad()

-- Wait for player to exist
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerScripts = player.PlayerScripts
local ClientMainScript = playerScripts.Client.ClientMain

local function _PRINT_CONFIGURATION()
    write(`Printing configuration as json...`)
    print(`[CONFIGURATION] {HttpService:JSONEncode(config)}`)
end

-- Wait for SharedVars before running ClientMain
SharedVars.onReady(function()
    SharedVars.onChanged(function(k,v)
        print(`{k}={tostring(v)}`)
    end)
    print(SharedVars.getAll())
    
    -- Register debug screens
    DebugMaster.registerScreen(DebugMinimal.new())
    DebugMaster.registerScreen(DebugScreen.new())
    DebugMaster.registerScreen(MemoryScreen.new())
    DebugMaster.registerScreen(DebugServerInfo.new())
    DebugMaster.registerScreen(DebugSharedVars.new())
    DebugMaster.start()
    
    -- Listen to updates
    Core:addEventListener("sharedVarsUpdate", function(k,v)
        write(`set {k}={tostring(v)}`)
    end)

    _PRINT_CONFIGURATION()

    write(`spawnning a task to run client main so we don't halt the runner...`)
    task.spawn(function()
        local ClientMain = require(ClientMainScript)
        ClientMain:Main()
    end)
    
end)
