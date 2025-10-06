local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Graphics2D = require(script.Parent.Graphics2D)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)

local function dbg(txt: string)
    print(`[Notification] {txt}`)
end

--[[
    @StaticClass
    ]]
    
local Notification = {}
Notification.__index = Notification

local activeNotifs: { {text: Text.Text, height: number} } = {}
local notifSpacing = 0.015

local function tweenTo(textObj: Text.Text, newY: number)
    --[[
        local oldPos: UDim2 = self._instance.Position
    local newPos: UDim2 = UDim2.fromScale(new.X, new.Y)
    dbg(`changing Text positon {tostring(oldPos)} ==> {tostring(newPos)} (id={self.id})`)
    self._instance.Position = newPos
    ]]
    local oldPos = textObj._instance.Position
    local newPos = UDim2.fromScale(1, newY)

    local inst = textObj._instance
    if not inst then return end
    game:GetService("TweenService"):Create(
        inst,
        TweenInfo.new(0.25,Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { Position = newPos }
    ):Play()

    textObj:setPosition(newPos)
end

local function respositionNotifications()
    dbg(`respositioning Notifications...`)

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
        --tweenTo(data.text, yPos)
    end
end


function Notification.createRawNotification(label: string, color: Color3,TEXT: string, timeR: number)
    local NOTIFICATION_NAME = `notification_{HttpService:GenerateGUID()}`
    
    dbg(`new Notification: name={NOTIFICATION_NAME}, label={label}, color={tostring(color)}, text={string}, timeR={tostring(timeR)}`)

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

        table.insert(activeNotifs, 1, {text = notifText, height = height})

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


function Notification.new(ntype: "URGENT" | "LOW" | "IMPORTANT" | "DEBUG" | "SERVER",text: string,timeR: number?)
    timeR = timeR or 5

    if ntype == "URGENT" then
        Notification.createRawNotification("URGENT", Color3.fromRGB(255, 106, 106), text, timeR)
    elseif ntype == "IMPORTANT" then
        Notification.createRawNotification("IMPORTANT", Color3.fromRGB(255, 157, 66), text, timeR)
    elseif ntype == "LOW" then
        Notification.createRawNotification("LOW", Color3.fromRGB(14, 187, 255), text, timeR)
    elseif ntype == "DEBUG" then
        if not config.client.debugNotifications then return end
        Notification.createRawNotification("DEBUG", Color3.fromRGB(255, 255, 255), text, timeR)
    elseif ntype == "SERVER" then
        Notification.createRawNotification("SERVER", Color3.fromRGB(209, 60, 255), text, timeR)
    end
end

-- if the server wants to send a notification


return Notification