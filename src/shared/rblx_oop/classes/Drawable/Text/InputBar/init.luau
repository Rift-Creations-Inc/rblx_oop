local config = require(game:GetService("ReplicatedStorage").Shared.rblx_oop.config)

local function dbg(txt: string)
    if not config.client.debugGraphics then return end
    print(`[InputBar] {txt}`)
end

local Drawable = require(script.Parent.Parent)
local Text = require(script.Parent)

type Text = Text.Text
type TextOptions = Text.TextOptions
type DrawableInstance = Drawable.DrawableInstance
type EventCallbacks<T> = Drawable.EventCallbacks<T>
export type Callback<S,T...> = Drawable.Callback<S,T...>


export type InputBarCallbacks = EventCallbacks<InputBar> & {
    onTextChanged: Callback<InputBar, string>?,
    onEnterPressed: Callback<InputBar>?,
    onFocusGained: Callback<InputBar>?,
    onFocusLost: Callback<InputBar, boolean?>
}

export type InputBarOptions = TextOptions & {
    placeholder: string?,
    clearOnFocus: boolean?,
    
    events: InputBarCallbacks
}

export type InputBar = Text & {
    placeholder: string,
	clearOnFocus: boolean,
	_inputInstance: TextBox?,
	events: InputBarCallbacks?,
}

local InputBar = {}
InputBar.__index = InputBar
setmetatable(InputBar, { __index = Text } )


function InputBar.new(options: InputBarOptions?): InputBar
    local self: InputBar = Text.new(options) :: InputBar
    setmetatable(self, InputBar)

    self.placeholder = options and options.placeholder or ""
    self.clearOnFocus = options and options.clearOnFocus or false
    self._inputInstance = nil
    self.events = options and options.events or {}

    dbg(`new InputBar, placeholder={self.placeholder} (id={self.id})`)
    return self
end

function InputBar.render(self: InputBar, parent: Instance): TextBox
    dbg(`rendering InputBar (id={self.id})`)

    local box = Instance.new("TextBox")
    box.Text = self.text or ""
    box.PlaceholderText = self.placeholder
    box.TextColor3 = self.color
    box.Font = self.font
    box.TextSize = self.size
    box.RichText = self.richText
    box.BackgroundColor3 = self.backgroundColor
    box.BackgroundTransparency = self.backgroundTransparency
    box.TextXAlignment = self.textXalign
    box.TextYAlignment = self.textYalign
    box.ClearTextOnFocus = self.clearOnFocus
    box.Position = UDim2.fromScale(self.position.X, self.position.Y)
    box.AnchorPoint = self.anchor
    box.Parent = parent

    if self.uiSize then
        box.AutomaticSize = Enum.AutomaticSize.None
        box.Size = self.uiSize
    else
    	box.AutomaticSize = Enum.AutomaticSize.XY
        box.Size = UDim2.new(0,0,0,0)
    end

    box.AutomaticSize = Enum.AutomaticSize.XY
    box.TextWrapped = self.wrap

    local padding = Instance.new("UIPadding")
    if self.textXalign == Enum.TextXAlignment.Center then
		padding.PaddingLeft = UDim.new(0,9)
		padding.PaddingRight = UDim.new(0,9)
	elseif self.textXalign == Enum.TextXAlignment.Left then
		padding.PaddingRight = UDim.new(0,9)
	elseif self.textXalign == Enum.TextXAlignment.Right then
		padding.PaddingLeft = UDim.new(0,9)
	end
	padding.Parent = box

    self._instance = box
    self._inputInstance = box

    local ev = self.events
    if ev then

        box.Changed:Connect(function(prop)
            if prop == "Text" then
                self.text = box.Text
                if ev.onTextChanged then
                    ev.onTextChanged(self,box.Text)
                end
            end
        end)

        box.Focused:Connect(function()
			if ev.onFocusGained then
				ev.onFocusGained(self)
			end
		end)

		box.FocusLost:Connect(function(enterPressed)
			if ev.onFocusLost then
				ev.onFocusLost(self, enterPressed)
			end
			if enterPressed and ev.onEnterPressed then
				ev.onEnterPressed(self)
			end
		end)
        
    end

    self:doConnectEvents()

    return box
end

function InputBar.setText(self: InputBar, txt: string)
    self.text = txt
    if self._inputInstance then
        self._inputInstance.Text = txt
    end
end

function InputBar.destroy(self: InputBar)
    dbg(`destroying InputBar... (id={self.id})`)
    if self._inputInstance then
        self._inputInstance:Destroy()
    end
    self._instance = nil
    self._inputInstance = nil
end


return InputBar