local Drawable = require(script.Parent)

local config = require(game:GetService('ReplicatedStorage').Shared.rblx_oop.config)

local function dbg(txt: string)
    if not config.client.debugGraphics then return end
    print(`[Drawable.Text] {txt}`)
end

type Drawable = Drawable.Drawable
type DrawableOptions = Drawable.DrawableOptions
type DrawableInstance = Drawable.DrawableInstance

export type TextOptions = DrawableOptions & {
    text: string?,
    color: Color3?,
    backgroundColor: Color3?,
    backgroundTransparency: number?,
    size: number?,
    font: Enum.Font?
}

export type Text = Drawable & {
    text: string,
    color: Color3,
    backgroundColor: Color3,
    backgroundTransparency: number,
    size: number,
    font: Enum.Font,

    setText: (
        self: Text,
        text: string
    ) -> Text
}

local function updateInternalText(self: Text, newText: string)
    if self.text ~= newText then
        dbg(`TextUpdate: "{self.text}" ==> "{newText}"`)
    end
    self.text = newText 
    
    if self._instance then
        self._instance.Text = newText
    end
end

local Text = {}
Text.__index = Text
setmetatable(Text, { __index = Drawable })

function Text.setText(self: Text,txt: string)
    dbg(`changing Text, text="{txt}" (id={self.id})`)
    self.text = txt
    
    if self._instance then
        self._instance.Text = txt
    end
end

function Text.new(options: TextOptions?): Text
    local self: Text = Drawable.new(options) :: Text
    setmetatable(self, Text)
    
    self.text = options and options.text or ""
    self.color = options and options.color or Color3.new(1,1,1)
    self.backgroundColor = options and options.backgroundColor or Color3.new(0.286275, 0.286275, 0.286275)
    self.backgroundTransparency = options and options.backgroundTransparency or 0.5
    self.size = options and options.size or 18
    self.font = options and options.font or Enum.Font.Code

    dbg(`new Text, text="{options.text}" (id={self.id})`)

    return self
end

function Text.render(self: Text,parent: Instance): TextLabel
    dbg(`rendering Text (id={self.id})`)

    local label = Instance.new('TextLabel')
    label.Text = self.text
    label.TextColor3 = self.color
    label.Font = self.font
    label.TextSize = self.size
    label.RichText = true
    label.BackgroundColor3 = self.backgroundColor
    label.BackgroundTransparency = self.backgroundTransparency
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundColor3 = Color3.new(0,0,0)
    label.Position = UDim2.fromScale(self.position.X, self.position.Y)
    label.AnchorPoint = self.anchor
    label.Parent = parent

    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.fromOffset(0,self.size + 2)
    label.TextWrapped = false

    if not (parent:FindFirstChildOfClass("UIListLayout") or parent:FindFirstChildOfClass("UIGridLayout")) then
        label.Position = UDim2.fromScale(self.position.X, self.position.Y)
        label.AnchorPoint = self.anchor
    else
        label.LayoutOrder = #parent:GetChildren() + 1
    end

    local padding = Instance.new('UIPadding')
    padding.PaddingRight = UDim.new(0,9)
    padding.Parent = label

    self._instance = label
    return label
end

return Text