local config = require(game:GetService("ReplicatedStorage").Shared.rblx_oop.config)

local function dbg(txt: string)
	if not config.client.debugGraphics then return end
	print(`[Button] {txt}`)
end

local Drawable = require(script.Parent.Parent)
local Text = require(script.Parent)

type Text = Text.Text
type TextOptions = Text.TextOptions
type DrawableInstance = Drawable.DrawableInstance
type EventCallbacks<T> = Drawable.EventCallbacks<T>
export type Callback<S,T...> = Drawable.Callback<S,T...>

export type ButtonCallbacks = EventCallbacks<Button> & {
	onMb1Click: Callback<Button>,
	onMb1Up: Callback<Button,number,number>,
	onMb1Down: Callback<Button,number,number>,

	onMb2Click: Callback<Button>,
	onMb2Up: Callback<Button,number,number>,
	onMb2Down: Callback<Button,number,number>,
}

export type ButtonOptions = {
	uiSize: UDim2?,

	events: ButtonCallbacks?
} & TextOptions


export type Button = Text & {
	uiSize: UDim2?, 
	_buttonInstance: TextButton?,

	events: ButtonCallbacks?,
}

local Button = {}
Button.__index = Button
setmetatable(Button, { __index = Text })

function Button.new(options: ButtonOptions?): Button
	local self: Button = Text.new(options) :: Button
	setmetatable(self, Button)

	self.uiSize = options and options.uiSize or nil
	self._buttonInstance = nil
	self.events = options and options.events or {} :: ButtonCallbacks

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

	if self.events.onMb1Click then
		button.MouseButton1Click:Connect(function()
			self.events.onMb1Click(self)
		end)
	end

	if self.events.onMb1Down then
		button.MouseButton1Down:Connect(function(x: number, y: number)
			self.events.onMb1Down(self,x,y)
		end)
	end

	if self.events.onMb1Up then
		button.MouseButton1Up:Connect(function(x: number, y: number)
			self.events.onMb1Up(self,x,y)
		end)
	end
	

	if self.events.onMb2Click then
		button.MouseButton2Click:Connect(function()
			self.events.onMb2Click(self)
		end)
	end

	if self.events.onMb2Down then
		button.MouseButton2Down:Connect(function(x: number, y: number)
			self.events.onMb2Down(self,x,y)
		end)
	end

	if self.events.onMb2Up then
		button.MouseButton2Up:Connect(function(x: number,y: number)
			self.events.onMb1Up(self,x,y)
		end)
	end

	self._buttonInstance = button
	self._instance = button

	self:doConnectEvents()
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
