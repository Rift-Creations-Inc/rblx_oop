-- prevents hanging from stuff that expects core to be initialized
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()

local HttpService = game:GetService("HttpService")

local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Button = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.Button)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local Notification = require(ReplicatedStorage.Shared.rblx_oop.classes.Notification)
local DebugMaster = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugMaster)
local DebugMinimal = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugMinimal)
local DebugScreen = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugScreen)
local DebugServerInfo = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugServerInfo)
local DebugSharedVars = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.DebugSharedVars)
local MemoryScreen = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.MemoryScreen)
local screenShared = require(ReplicatedStorage.Shared.rblx_oop.classes.Screens.screenShared)


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
    -- if it's not enabled it won't display it so we don't need an if statement :D
    Notification.new("DEBUG", "Debug notifications are enabled!")

    if config.client.askToContinue then
        write(`waiting for user to tell us to continue, config.client.askToContinue=true`)
        local canGo = false
        local askToContinueGFX = Graphics2D.new('temp:askToContinue')

        local function _CLICKED(self: Button.Button)
            self:setText(`continuing...`)
            canGo = true
            write(`canGo is now TRUE, continuing...`)
        end

        local button = Button.new({
            text = "Click me or press [E] to continue loading.\n\nYou are seeing this because config.client.askToContinue is set to true.",
            textXalign = Enum.TextXAlignment.Center,
            pos = Vector2.new(.5,.5),
            size = 18,
            onClick = _CLICKED,

            backgroundColor = Color3.fromRGB(0,0,0),
            color = Color3.fromRGB(255, 255, 255)
        })

        askToContinueGFX:addDrawable(button)

        local conn = UserInputService.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.KeyCode == Enum.KeyCode.E then
                button:setText(`continuing...`)
                canGo = true
                write(`[E] was pressed, continuing...`)
            end
        end)

        repeat 
            task.wait()
        until canGo

        conn:Disconnect()
        button:destroy()
        askToContinueGFX:destroy()
    end

    SharedVars.onChanged(function(k,v)
        print(`{k}={tostring(v)}`)
    end)
    
    -- Register debug screens
    Notification.new("DEBUG","register debug slave screens...")
    DebugMaster.registerSlaveScreen(DebugMinimal.new())
    DebugMaster.registerSlaveScreen(DebugScreen.new())
    DebugMaster.registerSlaveScreen(MemoryScreen.new())
    DebugMaster.registerSlaveScreen(DebugServerInfo.new())
    DebugMaster.registerSlaveScreen(DebugSharedVars.new())
    Notification.new("DEBUG", "All debug slave screens have been registered - starting DebugMaster")
    DebugMaster.start()

    if screenShared.keyStyle == "studio" then
        Notification.new("IMPORTANT",`Your debug key map is set to "studio"\nDebug keys may be different - press F2 to view keys.`, 6)
    else
        Notification.new("LOW",`Your debug key map is set to "std."\nUsable keys: F1-F5.`, 5)
    end
    
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
