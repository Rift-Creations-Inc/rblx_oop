
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService('RunService')
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local screenShared = require(script.Parent.screenShared)
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)

local _TAG = Enum.DeveloperMemoryTag 
local memoryTags: { Enum.DeveloperMemoryTag } = {
    _TAG.Internal,
    _TAG.HttpCache,
    _TAG.Instances,
    _TAG.Signals,
    _TAG.LuaHeap,
    _TAG.Script,
    _TAG.PhysicsCollision,
    _TAG.BaseParts,
    _TAG.GraphicsSolidModels,
    _TAG.GraphicsMeshParts,
    _TAG.GraphicsParticles,
    _TAG.GraphicsParts,
    _TAG.GraphicsSpatialHash,
    _TAG.GraphicsTerrain,
    _TAG.GraphicsTexture,
    _TAG.GraphicsTextureCharacter,
    _TAG.Sounds,
    _TAG.StreamingSounds,
    _TAG.TerrainVoxels,
    _TAG.Gui,
    _TAG.Animation,
    _TAG.Navigation,
    _TAG.GeometryCSG,
    _TAG.GraphicsSlimModels
}

SharedVars.waitForLoad()

local sharedv = {}
SharedVars.bind(sharedv)

export type MemoryScreen = {
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
        self: MemoryScreen
    ) -> (),

    setupDrawables: (
        self: MemoryScreen
    ) -> (),

    setupRightDrawables: (
        self: MemoryScreen,
        fontColor: Color3
    ) -> (),

    setupLeftDrawables: (
        self: MemoryScreen,
        fontColor: Color3
    ) -> (),

    bindToggle: (
        self: MemoryScreen
    ) -> (),

    update: (
        self: MemoryScreen
    ) -> (),

    show: (
        self: MemoryScreen
    ) -> (),

    hide: (
        self: MemoryScreen
    ) -> (),

    toggle: (
        self: MemoryScreen
    ) -> ()
}

local MemoryScreen = {}
MemoryScreen.__index = MemoryScreen

local SCREEN_LABEL = `Debug screen: Memory {screenShared.HELP}`

function MemoryScreen.new(): MemoryScreen
    local self: MemoryScreen = setmetatable({}, MemoryScreen)
    self.enabled = false
    self.drawables = {}
    self.drawablesRight = {}
    self.graphics = Graphics2D.new("DebugHUD:MemoryScreen")
    self.updateConn = nil
    if RunService:IsStudio() then
        self.toggleKey = Enum.KeyCode.F4
    else
        self.toggleKey = Enum.KeyCode.F3
    end

    --self:bindToggle()
    self:hide()
    
    return self
end

function MemoryScreen.setupDrawables(self: MemoryScreen)

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
        font = config.client.defaultFont
    })

    self.graphics:addDrawable(bottomLabel)
    self.screenModeLabel = bottomLabel

    self.containerRight = containerRight

    --self:setupRightDrawables(fontColor)
end

function MemoryScreen.bindToggle(self: MemoryScreen)
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end

        if inp.KeyCode == self.toggleKey then
            self:toggle()
        end
    end)
end

function MemoryScreen.update(self: MemoryScreen)
    if not self.containerLeft then return end

    local totalMem = Stats:GetTotalMemoryUsageMb()
    local perLine = 2
    local lines = {}

    table.insert(lines,string.format("Total memory: %.2f MB", totalMem))

    -- Group memory tags into lines
    for i = 1, #memoryTags, perLine do
        local lineTags = {}
        for j = 0, perLine - 1 do
            local idx = i + j
            if memoryTags[idx] then
                local tag = memoryTags[idx]
                local memMb = Stats:GetMemoryUsageMbForTag(tag)
                local percent = totalMem > 0 and (memMb / totalMem * 100) or 0

                local color: Color3
                if percent > 20 then
                    color = Color3.fromRGB(233, 118, 118)
                elseif percent > 10 then
                    color = Color3.fromRGB(255, 154, 87)
                else
                    color = Color3.fromRGB(119, 255, 92)
                end
                local hexColor = color:ToHex()

                table.insert(lineTags, string.format("%-25s <font color='#%s'>%06.2f MB (%06.2f%%)</font>", tostring(tag.Name), hexColor, memMb,percent))
            end
        end

        table.insert(lines, table.concat(lineTags, " | ")) -- separate with |
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

function MemoryScreen.show(self: MemoryScreen)
    if self.enabled then return end
    self.enabled = true
    screenShared.memoryEnabled = true

    self:setupDrawables()
    self.graphics:show()
    
    self.updateConn = RunService.RenderStepped:Connect(function()
        self:update()
    end)
end

function MemoryScreen.hide(self: MemoryScreen)
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

function MemoryScreen.toggle(self: MemoryScreen)
    if self.enabled then
        self:hide()
    else
        self:show()
    end
end

return MemoryScreen