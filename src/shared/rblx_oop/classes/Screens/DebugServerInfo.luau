
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService('RunService')
local UserInputService = game:GetService("UserInputService")
local screenShared = require(script.Parent.screenShared)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)

SharedVars.waitForLoad()

local sharedv = {}
SharedVars.bind(sharedv)

export type DebugServerInfo = {
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
        self: DebugServerInfo
    ) -> (),

    setupDrawables: (
        self: DebugServerInfo
    ) -> (),

    setupRightDrawables: (
        self: DebugServerInfo,
        fontColor: Color3
    ) -> (),

    setupLeftDrawables: (
        self: DebugServerInfo,
        fontColor: Color3
    ) -> (),


    bindToggle: (
        self: DebugServerInfo
    ) -> (),

    update: (
        self: DebugServerInfo
    ) -> (),

    show: (
        self: DebugServerInfo
    ) -> (),

    hide: (
        self: DebugServerInfo
    ) -> (),

    toggle: (
        self: DebugServerInfo
    ) -> ()
}

local DebugServerInfo = {}
DebugServerInfo.__index = DebugServerInfo

local SCREEN_LABEL = `Debug screen: Server {screenShared.HELP}`

function DebugServerInfo.new(): DebugServerInfo
    local self: DebugServerInfo = setmetatable({}, DebugServerInfo)
    self.enabled = false
    self.drawables = {}
    self.drawablesRight = {}
    self.graphics = Graphics2D.new("DebugHUD:DebugServerInfo")
    self.updateConn = nil
    if RunService:IsStudio() then
        self.toggleKey = Enum.KeyCode.F6
    else
        self.toggleKey = Enum.KeyCode.F4
    end

    --self:bindToggle()
    self:hide()
    
    return self
end

function DebugServerInfo.setupLeftDrawables(self: DebugServerInfo,fontColor: Color3)
    local labels = {1,2,3,4,5,6,7,8,9}

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

function DebugServerInfo.setupRightDrawables(self: DebugServerInfo, fontColor: Color3)
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

function DebugServerInfo.setupDrawables(self: DebugServerInfo)
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

function DebugServerInfo.bindToggle(self: DebugServerInfo)
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end

        if inp.KeyCode == self.toggleKey then
            self:toggle()
        end
    end)
end

function DebugServerInfo.update(self: DebugServerInfo)

    --[[
        :set('server/ip',info.ip)
        :set('server/location',info.location)
        :set('server/hostname',info.hostname)
        :set('server/isp',info.isp)
        :set('server/city',info.city)
        :set('server/country',info.country)
        :set('server/countryCode',info.countryCode)
        :set('server/type',getServerType())
    --]]

    local ip = sharedv['server/ip']
    local location = sharedv['server/location']
    local hostname = sharedv['server/hostname']
    local isp = sharedv['server/isp']
    local city = sharedv['server/city']
    local country = sharedv['server/country']
    local countryCode = sharedv['server/countryCode']
    local serverType = sharedv['server/type']

    self.drawables[1]:setText(`Server information from SharedVars:`)
    self.drawables[2]:setText(`     server/ip: {ip}`)
    self.drawables[3]:setText(`     server/location: {location}`)
    self.drawables[4]:setText(`     server/hostname: {hostname}`)
    self.drawables[5]:setText(`     server/isp: {isp}`)
    self.drawables[6]:setText(`     server/city: {city}`)
    self.drawables[7]:setText(`     server/country: {country}`)
    self.drawables[8]:setText(`     server/countryCode: {countryCode}`)
    self.drawables[9]:setText(`     server/type: {serverType}`)

    --left side updates
        -- selene: allow(undefined_variable)
end

function DebugServerInfo.show(self: DebugServerInfo)
    if self.enabled then return end
    screenShared.generalEnabled = true
    self.enabled = true

    self:setupDrawables()
    self.graphics:show()
    
    self.updateConn = RunService.RenderStepped:Connect(function()
        self:update()
    end)
end

function DebugServerInfo.hide(self: DebugServerInfo)
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

function DebugServerInfo.toggle(self: DebugServerInfo)
    if self.enabled then
        self:hide()
    else
        self:show()
    end
end

return DebugServerInfo