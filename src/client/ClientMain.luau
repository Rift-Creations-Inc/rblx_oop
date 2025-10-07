
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()
local AssemblyChat = require(script.Parent.AssemblyChat)
local BloxstrapRPC = require(ReplicatedStorage.Shared.external.BloxstrapRPC)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Button = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.Button)
local InputBar = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.InputBar)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local Notification = require(ReplicatedStorage.Shared.rblx_oop.classes.Notification)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local ClientMain = {
    GFX = Graphics2D.new('ClientMain'),
    GFXTitle = Graphics2D.new('GameTitle',true)
}

local function DUMP_PLAYER_JOIN_INFO()
    local plr = game:GetService('Players').LocalPlayer
    local jd = plr:GetJoinData()
    
    print(`[DUMP_PLAYER_JOIN_INFO] join data for {plr.Name}`)
    print(`[DUMP_PLAYER_JOIN_INFO]     LaunchData={jd.LaunchData}`)
    print(`[DUMP_PLAYER_JOIN_INFO]     SourcePlaceId={jd.SourcePlaceId}`)
    print(`[DUMP_PLAYER_JOIN_INFO]     SourcePlaceId={jd.SourceGameId}`)

    Notification.new("LOW", "Player join data has been dumped\nto the console. Press F9 to view.")
end

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

function ClientMain:Time()
    local creditsUi = Text.new({
        text = `idk`,
        pos = Vector2.new(1,1),
        size = 18,
        textXalign = Enum.TextXAlignment.Right
    })

    ClientMain.GFX:addDrawable(creditsUi)

    task.spawn(function()
        while true do
            creditsUi:setText(`the current time is {DateTime.now():ToIsoDate()} (ISO 8601)`)
            task.wait(1)
        end
    end)

end

function ClientMain:CreateTitle()
    local title = Text.new({
        text = `rblx_oop testing environment :D`,
        pos = Vector2.new(.5,0),
        size = 18,
        uiSize = UDim2.fromScale(1, .035),
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

function ClientMain:SetupRPC()
    print(`setting up BloxstrapRPC...`)
    BloxstrapRPC.SetRichPresence({
        details = "rblx_oop publish",
        state = "running :D",
    })
    print(`done, RPC should now be set.`)
end


function ClientMain:commandBar()
    local showing = false
    local commandBarGFX = Graphics2D.new("commandBarGFX")
    local bar = InputBar.new({
        pos = Vector2.new(0,.85),
        size = 18,
        uiSize = UDim2.fromScale(1, .05),
        backgroundColor = Color3.fromRGB(0,0,0),
        placeholder = "hi",
        clearOnFocus = true
    })

    local function _pressed()
        print("enter pressed: "..self.text)
    end

    bar.events.onEnterPressed = _pressed

    commandBarGFX:addDrawable(bar)
    commandBarGFX:hide()

    game:GetService('UserInputService').InputBegan:Connect(function(inp,gpe)
        if gpe and inp.KeyCode ~= Enum.KeyCode.Backquote then 
            warn(`GPE: skipping...`)
            return 
        end
        if inp.KeyCode == Enum.KeyCode.Backquote then
            if showing then
                commandBarGFX:hide()
                showing = false
            else
                commandBarGFX:show()
                bar:getFocus()
                showing = true
            end
        end
    end)
end

function ClientMain:debugButtons()
    local function DUMP_CONFIGURATION()
        Notification.new("LOW", "rblx_oop configuration has been dumped\nto the console. press F9 to view.",8)
        print(`[DUMP_CONFIGURATION] as JSON: {HttpService:JSONEncode(config)}`)
        print("[DUMP_CONFIGURATION] as table: ",config)
    end

    local function DUMP_CORE()
        print(`[DUMP_CORE] telling core to generate a dump...`)
        local DUMP = Core:generateDump()
        print(`[DUMP_CORE] dump generated, guid is {DUMP.dumpGuid}`)

        Notification.new("LOW",`core dump has been generated and dumped to the console. dump guid is\n{DUMP.dumpGuid}. Press F9 to view the console.`)
        print(`[DUMP_CORE] as JSON: {HttpService:JSONEncode(DUMP)}`)
        print(`[DUMP_CORE] as table: `,DUMP)
    end

    local printConfBttn = Button.new({
        pos = Vector2.new(.85,.18),
        text = "dump rblx_oop config to console",
        backgroundColor = Color3.fromRGB(0,0,0),
        size = 18
    })
    printConfBttn.events.onMb1Click = DUMP_CONFIGURATION

    local generateCoreDumpBttn = Button.new({
        pos = Vector2.new(.85,.25),
        text = "generate core dump and write it to the console",
        backgroundColor = Color3.fromRGB(0,0,0),
        size = 18 
    })
    generateCoreDumpBttn.events.onMb1Click = DUMP_CORE

    local dumpPlayerJoinInfo = Button.new({
        pos = Vector2.new(.85,.32),
        text = "dump local player join info",
        backgroundColor = Color3.fromRGB(0,0,0),
        size = 18, 
    })
    dumpPlayerJoinInfo.events.onMb1Click = DUMP_PLAYER_JOIN_INFO

    ClientMain.GFX:addDrawable(dumpPlayerJoinInfo)
    ClientMain.GFX:addDrawable(generateCoreDumpBttn)
    ClientMain.GFX:addDrawable(printConfBttn)
end

local lastPlr
function ClientMain:Main()
    -- piped version of playerAdded
    Core
        :addEventListener("PplayerAdded", function(plr: Player)
            if lastPlr == plr then return end
            Notification.new("LOW", `{plr.Name} has joined!`)
            lastPlr = plr
        end)
        :addEventListener("PplayerRemoving", function(plr: Player)
            Notification.new("LOW", `{plr.Name} has left!`)
        end)
        :addEventListener('sharedVarsUpdate', function(k,v)
            print(k,v)
        end)
        :addEventListener("clientGameSettings", ClientMain.gameSettingChanged)


    AssemblyChat:start()
    
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    print("Backpack disabled.")

    ClientMain:commandBar()
    ClientMain:SetupRPC()
    ClientMain:debugButtons()
    ClientMain:CreateTitle()
    ClientMain:Time()

    return
end

return ClientMain