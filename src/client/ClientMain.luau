
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)

local ClientMain = {
    GFX = Graphics2D.new('ClientMain'),
    GFXTitle = Graphics2D.new('GameTitle',true)
}

local gameSettings = UserSettings().GameSettings
function ClientMain.gameSettingChanged(name)
    local canGet, setting = pcall(function()
        return gameSettings[name]
    end)

    if canGet then
        print(`[ClientMain.gameSettingChanged] {name} ==> {tostring(setting)}`)
    else
        print(`[ClientMain.gameSettingChanged] {name} ==> ?`)
    end
end

function ClientMain:CreditsUi()
    local creditsUi = Text.new({
        text = `created by 4visetAir1 :D`,
        pos = Vector2.new(1,1),
        size = 18,
        textXalign = Enum.TextXAlignment.Right
    })

    ClientMain.GFX:addDrawable(creditsUi)
end

function ClientMain:CreateTitle()
    local title = Text.new({
        text = `rblx_oop testing environment :D`,
        pos = Vector2.new(.5,0),
        size = 25,
        textXalign = Enum.TextXAlignment.Center,
        backgroundColor = Color3.new(0,0,0),
        backgroundTransparency = 0
    })
    ClientMain.GFXTitle:addDrawable(title)
end


function ClientMain:SayHi()
    local plr = game:GetService("Players").LocalPlayer
    local helloText = Text.new({
        text = `Hello, {plr.DisplayName}!`,
        pos = Vector2.new(.5,.95),
        size = 25,
        textXalign = Enum.TextXAlignment.Center
    })

    ClientMain.GFX:addDrawable(helloText)
    task.wait(2)
    helloText:setText(`This game serves as a test of rblx_oop,`)
    task.wait(2)
    helloText:setText("rblx_oop is inspired by Java but it's for Luau and Roblox! (The text you're seeing right now is created by rblx_oop!)")
    task.wait(3)
    helloText:setText(`That's all I have to say.`)
    task.wait(1.5)
    helloText:setText(`Enjoy this demo!`)
    task.wait(1)
    helloText:destroy()
end

function ClientMain:Main()
    Core:addEventListener('sharedVarsUpdate', function(k,v)
        print(k,v)
    end)
    
    Core:addEventListener("clientGameSettings", ClientMain.gameSettingChanged)

    ClientMain:CreateTitle()
    ClientMain:CreditsUi()
    ClientMain:SayHi()
    return
end

return ClientMain