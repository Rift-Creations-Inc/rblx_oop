
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

export type DebugSharedVars = {
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
        self: DebugSharedVars
    ) -> (),

    setupDrawables: (
        self: DebugSharedVars
    ) -> (),

    setupRightDrawables: (
        self: DebugSharedVars,
        fontColor: Color3
    ) -> (),

    setupLeftDrawables: (
        self: DebugSharedVars,
        fontColor: Color3
    ) -> (),

    bindToggle: (
        self: DebugSharedVars
    ) -> (),

    update: (
        self: DebugSharedVars
    ) -> (),

    show: (
        self: DebugSharedVars
    ) -> (),

    hide: (
        self: DebugSharedVars
    ) -> (),

    toggle: (
        self: DebugSharedVars
    ) -> ()
}

local DebugSharedVars = {}
DebugSharedVars.__index = DebugSharedVars

local SCREEN_LABEL = `Debug screen: SharedVars {screenShared.HELP}`

function DebugSharedVars.new(): DebugSharedVars
    local self: DebugSharedVars = setmetatable({}, DebugSharedVars)
    self.enabled = false
    self.drawables = {}
    self.drawablesRight = {}
    self.graphics = Graphics2D.new("DebugHUD:DebugSharedVars")
    self.updateConn = nil
    self.toggleKey = Enum.KeyCode.F8

    --self:bindToggle()
    self:hide()
    
    return self
end

function DebugSharedVars.setupDrawables(self: DebugSharedVars)

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

    --self:setupRightDrawables(fontColor)
end

function DebugSharedVars.bindToggle(self: DebugSharedVars)
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end

        if inp.KeyCode == self.toggleKey then
            self:toggle()
        end
    end)
end

function DebugSharedVars.update(self: DebugSharedVars)
    if not self.containerLeft then return end

    local lines = {}
    table.insert(lines,"===== SharedVars =====")

    local lineGroup = {}
    local count = 0

    for k,v in pairs(sharedv) do
        local valueStr
        if type(v) == "string" then
            valueStr = `"{v}"`
        else
            valueStr = tostring(v)
        end

        table.insert(lineGroup, `({type(v)}) {k}={valueStr}`)
        count += 1

        if count % 3 == 0 then
            table.insert(lines, table.concat(lineGroup, " | "))
            lineGroup = {}
        end
    end

    -- Insert any remaining items
    if #lineGroup > 0 then
        table.insert(lines, table.concat(lineGroup, " | "))
    end

    for i, lineText in ipairs(lines) do
        local drawable = self.drawables[i]
        if not drawable then
            drawable = Text.new({
                text = "",
                color = Color3.fromRGB(255,255,255),
                richText = true
            })
            self.graphics:addDrawable(drawable,self.containerLeft)
            table.insert(self.drawables,drawable)
        end
        drawable:setText(lineText)
    end
end

function DebugSharedVars.show(self: DebugSharedVars)
    if self.enabled then return end
    self.enabled = true
    screenShared.memoryEnabled = true

    self:setupDrawables()
    self.graphics:show()
    
    self.updateConn = RunService.RenderStepped:Connect(function()
        self:update()
    end)
end

function DebugSharedVars.hide(self: DebugSharedVars)
    if not self.enabled then return end
    self.enabled = false
    screenShared.memoryEnabled = false

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

function DebugSharedVars.toggle(self: DebugSharedVars)
    if self.enabled then
        self:hide()
    else
        self:show()
    end
end

return DebugSharedVars