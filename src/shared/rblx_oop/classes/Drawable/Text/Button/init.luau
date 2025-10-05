local config = require(game:GetService('ReplicatedStorage').Shared.rblx_oop.config)

local function dbg(txt: string)
    if not config.client.debugGraphics then return end
    print(`[Drawable.Text.Button] {txt}`)
end

local Drawable = require(script.Parent.Parent)
local Text = require(script.Parent)

type Text = Text.Text
type TextOptions = Text.TextOptions
type DrawableInstance = Drawable.DrawableInstance

export type ButtonOptions = TextOptions & {
    size: Vector2?,
    backgroundColor: Color3?,
    onClick: (
        (self: any) -> ()
    )
}

export type Button = Text & { 
    size: Vector2,
    backgroundColor: Color3,

    onClick: (
        (self: Button) -> ()
    ) -> ()?,

    _buttonInstance: TextButton?
}

local Button = {}
Button.__index = Button
setmetatable(Button, {__index = Text})

function Button.new(options: ButtonOptions?): Button
    local self = Text.new(options) :: any
    setmetatable(self, Button)

    self.size = options and options.size or Vector2.new(0.15,0.08)
    self.backgroundColor = options and options.backgroundColor or Color3.fromRGB(0, 0, 0)
    self.onClick = options and options.onClick or nil

    self._buttonInstance = nil

    dbg(`new Button, text="{options.text}" (id={self.id})`)

    return self
end

function Button.render(self: Button, parent: Instance): TextButton
    dbg(`rendering Button (id={self.id})`)

    local button = Instance.new("TextButton")
    button.Text = self.text
    button.Size = UDim2.fromScale(self.size.X, self.size.Y)
    button.Position = UDim2.fromScale(self.position.X, self.position.Y)
    button.AnchorPoint = self.anchor
    button.BackgroundColor3 = self.backgroundColor
    button.Font = self.font
    button.TextColor3 = self.color
    button.TextScaled = true
    button.Parent = parent

    if self.onClick then
        button.MouseButton1Click:Connect(function()
            self.onClick(self)
        end)
    end

    self._buttonInstance = button
    self._instance = button -- also set the inherited _instance
    return button
end

function Button.destroy(self: Button)
    dbg(`destroying Button... (id={self.id})`)
    if self._buttonInstance then
        self._buttonInstance:Destroy()
        self._instance:Destroy()
        self._buttonInstance = nil
        self._instance = nil
    end
end

return Button