local config = require(game:GetService("ReplicatedStorage").Shared.rblx_oop.config)

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
	uiSize: UDim2?, -- ✅ new distinct field for button size
	onClick: ((self: any) -> ())?,
}

export type Button = Text & {
	uiSize: UDim2?, -- ✅ UI element size
	onClick: ((self: Button) -> ())?,
	_buttonInstance: TextButton?,
}

local Button = {}
Button.__index = Button
setmetatable(Button, { __index = Text })

function Button.new(options: ButtonOptions?): Button
	local self = Text.new(options) :: any
	setmetatable(self, Button)

	self.uiSize = options and options.uiSize or nil
	self.onClick = options and options.onClick or nil
	self._buttonInstance = nil

	dbg(`new Button, text="{options and options.text or 'nil'}" (id={self.id})`)
	return self
end

function Button.render(self: Button, parent: Instance): TextButton
	dbg(`rendering Button (id={self.id})`)

	local button = Instance.new("TextButton")
	button.Text = self.text
	button.TextColor3 = self.color
	button.Font = self.font
	button.TextSize = self.size -- ✅ from Text (number)
	button.RichText = self.richText
	button.BackgroundColor3 = self.backgroundColor
	button.BackgroundTransparency = self.backgroundTransparency
	button.TextXAlignment = self.textXalign
	button.TextYAlignment = Enum.TextYAlignment.Center
	button.BorderSizePixel = 0
	button.Parent = parent

	-- ✅ Use uiSize if defined, otherwise autosize
	if self.uiSize then
		button.AutomaticSize = Enum.AutomaticSize.None
		button.Size = self.uiSize
	else
		button.AutomaticSize = Enum.AutomaticSize.XY
	end

	-- ✅ Layout-safe positioning
	if not (parent:FindFirstChildOfClass("UIListLayout") or parent:FindFirstChildOfClass("UIGridLayout")) then
		button.Position = UDim2.fromScale(self.position.X, self.position.Y)
		button.AnchorPoint = self.anchor
	else
		button.LayoutOrder = #parent:GetChildren() + 1
	end

	-- ✅ Padding for text spacing
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 2)
	padding.Parent = button

	-- ✅ Connect click listener
	if self.onClick then
		button.MouseButton1Click:Connect(function()
			self.onClick(self)
		end)
	end

	self._buttonInstance = button
	self._instance = button
	return button
end

function Button.setText(self: Button, text: string)
	Text.setText(self, text)
end

function Button.destroy(self: Button)
	dbg(`destroying Button... (id={self.id})`)
	if self._buttonInstance then
		self._buttonInstance:Destroy()
	end
	self._instance = nil
	self._buttonInstance = nil
end

return Button
