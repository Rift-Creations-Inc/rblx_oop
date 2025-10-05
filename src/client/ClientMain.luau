
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Button = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.Button)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)

local ClientMain = {
    GFX = Graphics2D.new()
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

function ClientMain:SayHi()
   local helloText = Text.new({text = "hello!", pos = Vector2.new(.5,.2)})
   
   ClientMain.GFX:addDrawable(helloText)
end

local function _createFunnyText()
    local text = Text.new({text = "funny!", pos = Vector2.new(.5,.5)})

    ClientMain.GFX:addDrawable(text)
end

local function _clicked()
    _createFunnyText()
end

local function _clear()
    ClientMain.GFX:clear()
end

function ClientMain:FunnyButtonStuff()

    local clearButton = Button.new({
        text = "clear screen",
        pos = Vector2.new(0.009,0.0875),
        size = Vector2.new(.15,.15),
        onClick = _clear
    })

    local button = Button.new({
        text = "click me!",
        pos = Vector2.new(.5,.4),
        size = Vector2.new(.2,.2),
        onClick = _clicked,
    })

    ClientMain.GFX:addDrawable(clearButton)
    ClientMain.GFX:addDrawable(button)
end

function ClientMain.pie()

end

function ClientMain:Main()
    Core:addEventListener('sharedVarsUpdate', function(k,v)
        print(k,v)
    end)
    
    Core:addEventListener("clientGameSettings", ClientMain.gameSettingChanged)

    return
end

return ClientMain