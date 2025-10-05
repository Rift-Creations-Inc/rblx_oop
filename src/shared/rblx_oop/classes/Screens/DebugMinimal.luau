
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService('RunService')
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local screenShared = require(script.Parent.screenShared)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()

print(`waiting on SharedVars...`)
SharedVars.waitForLoad()

local sharedv = {}
print(`binding local table: 'sharedv' to SharedVars`)
SharedVars.bind(sharedv)

export type DebugMinimal = {
    enabled: boolean,
    
    drawables: { Text.Text },
    drawablesRight: { Text.Text },

    graphics: Graphics2D.Graphics2D,
    updateConn: RBXScriptConnection?,
    toggleKey: Enum.KeyCode,

    containerWrapper: Frame?,
    containerLeft: Frame,
    containerRight: Frame?,

    restoreOriginal: (
        self: DebugMinimal
    ) -> (),

    setupDrawables: (
        self: DebugMinimal
    ) -> (),

    setupRightDrawables: (
        self: DebugMinimal,
        fontColor: Color3
    ) -> (),

    setupLeftDrawables: (
        self: DebugMinimal,
        fontColor: Color3
    ) -> (),


    bindToggle: (
        self: DebugMinimal
    ) -> (),

    update: (
        self: DebugMinimal
    ) -> (),

    show: (
        self: DebugMinimal
    ) -> (),

    hide: (
        self: DebugMinimal
    ) -> (),

    toggle: (
        self: DebugMinimal
    ) -> ()
}

local DebugMinimal = {}
DebugMinimal.__index = DebugMinimal

local SCREEN_LABEL = `Debug screen: Minimal {screenShared.HELP}`

function DebugMinimal.new(): DebugMinimal
    local self: DebugMinimal = setmetatable({}, DebugMinimal)
    self.enabled = false
    self.drawables = {}
    self.drawablesRight = {}
    self.graphics = Graphics2D.new("DebugHUD:DebugMinimal")
    self.updateConn = nil
    self.toggleKey = Enum.KeyCode.F2

    --self:bindToggle()
    self:hide()
    
    return self
end

function DebugMinimal.setupLeftDrawables(self: DebugMinimal,fontColor: Color3)
    local labels = {1,2,3,4,5,6,7}

    for i, _ in ipairs(labels) do
        local drawable = Text.new({
            pos = Vector2.new(0,0),
            color = fontColor,
            text = `<pending>`,
            font = Enum.Font.Code
        })

        self.graphics:addDrawable(drawable,self.containerLeft)
        table.insert(self.drawables,drawable)
    end
end

function DebugMinimal.setupRightDrawables(self: DebugMinimal, fontColor: Color3)
    local labels = {1,2}

    for i, _ in ipairs(labels) do
        local drawable = Text.new({
            pos = Vector2.new(0,0),
            color = fontColor,
            text = `<pending>`,
            font = Enum.Font.Code
        })

        self.graphics:addDrawable(drawable,self.containerRight)
        table.insert(self.drawablesRight,drawable)
    end
end

function DebugMinimal.setupDrawables(self: DebugMinimal)
    local fontColor = Color3.fromRGB(255, 255, 255)

    local wrapper = Instance.new('Frame')
    wrapper.Name = 'DebugWrapper'
    wrapper.BackgroundTransparency = 1
    wrapper.AnchorPoint = Vector2.new(0,0)
    wrapper.Position = UDim2.fromScale(0, 0.01)
    wrapper.Size = UDim2.fromScale(0.98,0.01)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.Parent = self.graphics._gui

    local horizontalLayout = Instance.new('UIListLayout')
    horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    horizontalLayout.Parent = wrapper

    local containerLeft = Instance.new('Frame')
    containerLeft.Name = "DebugFrameLeft"
    containerLeft.BackgroundTransparency = 1
    containerLeft.Size = UDim2.fromScale(0.05, 1)
    containerLeft.Position = UDim2.fromScale(0, 1)
    containerLeft.AutomaticSize = Enum.AutomaticSize.Y
    containerLeft.Parent = wrapper

    local layoutLeft = Instance.new('UIListLayout')
    layoutLeft.FillDirection = Enum.FillDirection.Vertical
    layoutLeft.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layoutLeft.Padding = UDim.new(0,1)
    layoutLeft.Parent = containerLeft

    self.containerLeft = containerLeft
    self.containerWrapper = wrapper

    local containerRight = Instance.new('Frame')
    containerRight.Name = "DebugRightFrame"
    containerRight.BackgroundTransparency = 1
    containerRight.Size = UDim2.fromScale(0.5, 1)
    containerRight.AutomaticSize = Enum.AutomaticSize.Y
    containerRight.Parent = wrapper
    
    local layoutRight = Instance.new("UIListLayout")
    layoutRight.FillDirection = Enum.FillDirection.Vertical
    layoutRight.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layoutRight.Padding = UDim.new(0, 1)
    layoutRight.Parent = containerRight

    local bottomLabel = Text.new({
        pos = Vector2.new(0,1),
        color = Color3.fromRGB(66, 255, 97),
        text = SCREEN_LABEL,
        font = Enum.Font.Code
    })

    self.graphics:addDrawable(bottomLabel)
    self.screenModeLabel = bottomLabel

    self.containerRight = containerRight

    self:setupLeftDrawables(fontColor)
    --self:setupRightDrawables(fontColor)
end

function DebugMinimal.bindToggle(self: DebugMinimal)
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end

        if inp.KeyCode == self.toggleKey then
            self:toggle()
        end
    end)
end

local currentGame = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or game.Name
local currentVersion = game.PlaceVersion
local latestVersion = game:GetService("InsertService"):GetLatestAssetVersionAsync(game.PlaceId)

local function getPlayerPosString(): string
    local plr = game:GetService('Players').LocalPlayer
    local rootPart = plr.Character.HumanoidRootPart or plr.CharacterAdded:Wait().HumandoidRootPart

    local pos = rootPart.Position

    return string.format("XYZ: %.4f, %.4f, %.4f",pos.X,pos.Y,pos.Z)
end

local function getPlayerFacingDirectionString(): string
    local plr = game:GetService('Players').LocalPlayer
    local rootPart = plr.Character.HumanoidRootPart or plr.CharacterAdded:Wait().HumandoidRootPart

    local lookV = rootPart.CFrame.LookVector
    local flatLook = Vector3.new(lookV.X,0,lookV.Z).Unit

    local directionTxt = "Unknown direction (maybe facing Y?)"

    if math.abs(flatLook.X) > math.abs(flatLook.Z) then
        if flatLook.X > 0 then
            directionTxt = "east (Towards positive X)"
        else
            directionTxt = "west (Towards negative X)"
        end
    else
        if flatLook.Z > 0 then
            directionTxt = "south (Towards positive Z)"
        else
            directionTxt = "north (Towards negative Z)"
        end
    end

    return string.format(`Facing: {directionTxt} (%.4f / %.4f)`,flatLook.X,flatLook.Z)
end

function DebugMinimal.update(self: DebugMinimal)
    local _info = Core.info()

    local info = {
        render = _info.getRenderInfo(),
        memory = _info.getMemoryInfo(),
        network = _info.getNetworkInfoFull()
    }

    local fps = math.floor(info.render.renderFps)
    local ipAddr = sharedv['server/ip']
    local location = sharedv['server/location']
    local tx, rx = math.floor(info.network.tx), math.floor(info.network.rx)

    local qualityLvl = UserSettings():GetService('UserGameSettings').SavedQualityLevel
    local gpuFt = string.format("%.4f",info.render.renderGpuFrameTime)
    local cpuFt = string.format("%.4f",info.render.renderCpuFrameTime)

    local serverT = sharedv['server/type']
    local playerCount = sharedv['game/playerCount']
    local jobId = game.JobId

    local plr = game:GetService('Players').LocalPlayer
    local ping = math.floor((game:GetService('Players').LocalPlayer:GetNetworkPing() * 1000))

    --left side updates
        -- selene: allow(undefined_variable)
    self.drawables[1]:setText(`{currentGame} J: {jobId} V: {currentVersion} L: {latestVersion} I: {_VERSION} R: Roblox {version()}`)
    self.drawables[2]:setText(`{fps} fps, T: {qualityLvl.Name} gpuFT: {gpuFt} cpuFT {cpuFt}`)
    self.drawables[3]:setText(`"{serverT}" server ({ipAddr} @ {location}) @ {ping} ms ping, {tx} tx, {rx} rx, {playerCount} player(s)`)
    self.drawables[4]:setText(` `)

    --client
    self.drawables[5]:setText(`Client: {plr.DisplayName} (@{plr.Name}) UserId={plr.UserId}`)
    self.drawables[6]:setText(getPlayerPosString())
    self.drawables[7]:setText(getPlayerFacingDirectionString())
end

function DebugMinimal.show(self: DebugMinimal)
    if self.enabled then return end
    screenShared.generalEnabled = true
    self.enabled = true

    self:setupDrawables()
    self.graphics:show()
    
    self.updateConn = RunService.RenderStepped:Connect(function()
        self:update()
    end)
end

function DebugMinimal.hide(self: DebugMinimal)
    if not self.enabled then return end
    screenShared.generalEnabled = false
    self.enabled = false
    self.graphics:clear()
    
    if self.updateConn then
        self.updateConn:Disconnect()
        self.updateConn = nil
    end

    if self.containerWrapper then
        self.containerWrapper:Destroy()
        self.containerWrapper = nil
    end
    
    self.drawables = {}
    self.drawablesRight = {}
end

function DebugMinimal.toggle(self: DebugMinimal)
    if self.enabled then
        self:hide()
    else
        self:show()
    end
end

return DebugMinimal