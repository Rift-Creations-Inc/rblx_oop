
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()
local Testing = require(StarterPlayer.StarterPlayerScripts.Client.Tests.Testing)
local CommandClient = require(script.Parent.CommandClient)
local BloxstrapRPC = require(ReplicatedStorage.Shared.external.BloxstrapRPC)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Button = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.Button)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local Notification = require(ReplicatedStorage.Shared.rblx_oop.classes.Notification)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
    
local SimpleList = require(ReplicatedStorage.Shared.rblx_oop.lang.SimpleList)
type SimpleList<E> = SimpleList.SimpleList<E>

local Function = require(ReplicatedStorage.Shared.rblx_oop.util["function"].THIS)
local Consumer = Function.Consumer

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
        size = 15,
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
        pos = Vector2.new(.5,.90),
        size = 25,
        textXalign = Enum.TextXAlignment.Left
    })

    ClientMain.GFX:addDrawable(helloText)
    task.wait(2)
    helloText:setText(`idk what to show so here is the current configuration...`)
    task.wait(2)

    local function table_to_string(tbl, indent, seen, depth_limit)
        indent = indent or 0
        seen = seen or {}
        depth_limit = depth_limit or 5

        if type(tbl) ~= "table" then
            return string.rep("  ", indent) .. tostring(tbl)
        end

        if seen[tbl] then
            return string.rep("  ", indent) .. "*recursive*"
        end
        seen[tbl] = true

        if indent >= depth_limit then
            return string.rep("  ", indent) .. "... (depth limit reached)"
        end

        local lines = {}
        for k, v in pairs(tbl) do
            local key_str = tostring(k)
            if type(v) == "table" then
                table.insert(lines, string.rep("  ", indent) .. key_str .. " = {")
                table.insert(lines, table_to_string(v, indent + 1, seen, depth_limit))
                table.insert(lines, string.rep("  ", indent) .. "}")
            else
                table.insert(lines, string.rep("  ", indent) .. key_str .. " = " .. tostring(v))
            end
        end
        return table.concat(lines, "\n")
    end

    helloText:setText(table_to_string(config))
    task.wait(5)
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
        :addEventListener("clientGameSettings", ClientMain.gameSettingChanged)


    --AssemblyChat:start()
    
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    task.wait(3)

    CommandClient:Main()
    ClientMain.debugButtons()
    ClientMain.CreateTitle()
    ClientMain.Time()
    --ClientMain.SayHi()

    local myList: SimpleList.SimpleList<string> = SimpleList.new()
    myList:add("string")
    myList:add("hey!")
    
    myList:forEach(Consumer(function(x: string)
        print(`forEach: {x}`)
    end))

    Testing()
    
    --print(`[CONFIGURATION] config.client.textSizeMultiplier={config.client.textSizeMultiplier}`)
    return
end

return ClientMain