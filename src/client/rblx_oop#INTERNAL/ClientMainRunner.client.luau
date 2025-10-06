local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Button = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.Button)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).init()
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

local function NOTIFICATION_IMPORTANT(TEXT,timeR)
    task.spawn(function()
        local notifGFX = Graphics2D.new(`temp:notif`)

        local notifText = Text.new({
            text = `[Important] ({timeR}s)\n{TEXT}`,
            pos = Vector2.new(1,.85),
            size = 20,
            textXalign = Enum.TextXAlignment.Right,
            color = Color3.fromRGB(255, 147, 5),
        })
        notifGFX:addDrawable(notifText)

        while timeR > 0 do
            task.wait(1)
            timeR -= 1
            notifText:setText(`[Important] ({timeR}s)\n{TEXT}`)
        end

        notifText:destroy()
        notifGFX:destroy()
    end)
end

local function NOTIFICATION_STD(TEXT,timeR)
    task.spawn(function()
        local notifGFX = Graphics2D.new(`temp:notif`)

        local notifText = Text.new({
            text = `[Standard] ({timeR}s)\n{TEXT}`,
            pos = Vector2.new(1,.85),
            size = 20,
            textXalign = Enum.TextXAlignment.Right,
            color = Color3.fromRGB(2, 183, 255),
        })
        notifGFX:addDrawable(notifText)

        while timeR > 0 do
            task.wait(1)
            timeR -= 1
            notifText:setText(`[Standard] ({timeR}s)\n{TEXT}`)
        end

        notifText:destroy()
        notifGFX:destroy()
    end)
end

-- Wait for SharedVars before running ClientMain
SharedVars.onReady(function()

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
            text = "click me or press [E]\nto continue loading (config.client.askToContinue)",
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
    DebugMaster.registerScreen(DebugMinimal.new())
    DebugMaster.registerScreen(DebugScreen.new())
    DebugMaster.registerScreen(MemoryScreen.new())
    DebugMaster.registerScreen(DebugServerInfo.new())
    DebugMaster.registerScreen(DebugSharedVars.new())
    DebugMaster.start()

    if screenShared.keyStyle == "studio" then
        NOTIFICATION_IMPORTANT(`Your debug key map is set to "studio"\nDebug keys may be different - press F2 to view keys.`, 6)
    else
        NOTIFICATION_STD(`Your debug key map is set to "std."\nUsable keys: F1-F5.`, 5)
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
