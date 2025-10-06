local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(script.Parent.Core).get()
local Graphics2D = require(script.Parent.Graphics2D)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

repeat
    task.wait()
until Core.initialized

local function dbg(txt: string)
    if not config.client.debugNotifications then return end
    print(`[Notification] {txt}`)
end

--[[
    @StaticClass
--]]
    
local Notification = {}
Notification.__index = Notification

local activeNotifs: { {text: Text.Text, height: number, id: string} } = {}
local notifSpacing = 0.015

local function respositionNotifications()
    dbg(`attempting to resposition Notifications...`)

    if #activeNotifs == 0 then
        dbg(`   no notification to reposition... bailing out`)
        return
    end

    local baseY = 0.85
    for i, data in ipairs(activeNotifs) do
        local totalOffset = 0
        for j = 1, i - 1 do
            local prev = activeNotifs[j]
            local pixHeight = prev.height + (notifSpacing * workspace.CurrentCamera.ViewportSize.Y)
            totalOffset += pixHeight
        end
        local yPos = baseY - (totalOffset / workspace.CurrentCamera.ViewportSize.Y)
        data.text:setPosition(Vector2.new(1,yPos))
        dbg(`   repositioned  {data.id}`)
        --tweenTo(data.text, yPos)
    end
end


function Notification.createRawNotification(label: string, color: Color3,TEXT: string, timeR: number,server: boolean?)
    server = server or false

    local NOTIFICATION_NAME = `notification_{HttpService:GenerateGUID()}`
    dbg(`new Notification: name={NOTIFICATION_NAME}, label={label}, color=#{color:ToHex()}, text={TEXT}, timeR={tostring(timeR)}, server={tostring(server)}`)

    if server then
        local originalLabel = label
        label = `SERVER {originalLabel}`
    end

    task.spawn(function()
        local notifGFX = Graphics2D.new(NOTIFICATION_NAME)

        local index = #activeNotifs + 1
        local yOffset = 0.85 - ((index -1) * notifSpacing)

        local notifText = Text.new({
            text = `[{label}] ({timeR}s)\n{TEXT}`,
            pos = Vector2.new(1,yOffset),
            size = 20,
            textXalign = Enum.TextXAlignment.Right,
            color = color
        })
        notifGFX:addDrawable(notifText)

        task.wait()
        local ilabel = notifText._instance
        local height = ilabel and ilabel.AbsoluteSize.Y or 20

        table.insert(activeNotifs, 1, {text = notifText, height = height, id = NOTIFICATION_NAME})

        respositionNotifications()

        while timeR > 0 do
            task.wait(1)
            timeR -= 1
            notifText:setText(`[{label}] ({timeR}s)\n{TEXT}`)
        end

        local indexToRemove = table.find(activeNotifs, notifText)
        if indexToRemove then
            table.remove(activeNotifs,indexToRemove)
        end

        for i, notif in ipairs(activeNotifs) do
            if notif.text == notifText then
                table.remove(activeNotifs,i)
                break
            end
        end

        notifText:destroy()
        notifGFX:destroy()
        respositionNotifications()
    end)
end


function Notification.new(ntype: "URGENT" | "LOW" | "IMPORTANT" | "DEBUG",text: string,timeR: number?,server: boolean?)
    timeR = timeR or 5

    if ntype == "URGENT" then
        Notification.createRawNotification("URGENT", Color3.fromRGB(255, 106, 106), text, timeR,server)
    elseif ntype == "IMPORTANT" then
        Notification.createRawNotification("IMPORTANT", Color3.fromRGB(255, 157, 66), text, timeR,server)
    elseif ntype == "LOW" then
        Notification.createRawNotification("LOW", Color3.fromRGB(14, 187, 255), text, timeR,server)
    elseif ntype == "DEBUG" then
        if not config.client.debugNotifications then return end

        Notification.createRawNotification("DEBUG", Color3.fromRGB(255, 255, 255), text, timeR,server)
    end
end

-- if the server wants to send a notification
Core
    :registerBridge("sendGlobalNotification")
    :addEventListener("sendGlobalNotification", function(ntype: string, txt: string, timeR: number)
        Notification.new(ntype, txt, timeR,true)
    end)

return Notification