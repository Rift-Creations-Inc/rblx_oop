local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Text = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text)
local InputBar = require(ReplicatedStorage.Shared.rblx_oop.classes.Drawable.Text.InputBar)
local Graphics2D = require(ReplicatedStorage.Shared.rblx_oop.classes.Graphics2D)
local CommandExecutive = ReplicatedStorage.Shared.rblx_oop.runtime.CommandExecutive

local COLOR_ERR = Color3.fromRGB(255, 85, 85)
local COLOR_SUCCESS = Color3.fromRGB(151, 255, 120)

local CommandClient = {}

function CommandClient:Main()
    local showing = false
    local commandBarGFX = Graphics2D.new("commandBarGFX")

    
    local bar = InputBar.new({
        pos = Vector2.new(0,.75),
        size = 18,
        --uiSize = UDim2.fromScale(1, .05),
        backgroundColor = Color3.fromRGB(0,0,0),
        color = Color3.fromRGB(255,255,255),
        backgroundTransparency = 0,
        placeholder = "hi",
        clearOnFocus = true
    })
    
    local commandRet = Text.new({
        pos = Vector2.new(bar.position.X, bar.position.Y - 0.05),
        size = 18,
        --uiSize = UDim2.fromScale(1, .05),
        backgroundColor = Color3.fromRGB(0,0,0),
        color = Color3.fromRGB(255,255,255),
        backgroundTransparency = 0,
        richText = true,
        text = "Results of commands will be displayed here."
    })

    local function _pressed()
        local cmd = bar.text
        if cmd == "" then return end

        local ok, result = pcall(function()
            return CommandExecutive:InvokeServer(cmd)
        end)

        if ok and typeof(result) == "table" then
            if result.success then
                --<font color="#{color}">[AssemblyChat] {msg}</font>
                commandRet._instance.TextColor3 = COLOR_SUCCESS
                commandRet:setText(`SUCCESS: {result.message or "Done."}`)
            else
                commandRet._instance.TextColor3 = COLOR_ERR
                commandRet:setText(`FAILED: {result.message or "Unknown error"}`)
            end
        else
            commandRet._instance.TextColor3 = COLOR_ERR
            commandRet:setText(`<font color="#{COLOR_ERR}>"FAILED: Failed to invoke server: {result}</font>`)
        end
    end

    bar.events.onEnterPressed = _pressed

    commandBarGFX:addDrawable(commandRet)
    commandBarGFX:addDrawable(bar)
    commandBarGFX:hide()

    game:GetService('UserInputService').InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if not inp.KeyCode then return end

        if inp.KeyCode == Enum.KeyCode.Backquote then
            showing = not showing
            if showing then
                commandBarGFX:show()
                bar:getFocus()
            else
                commandBarGFX:hide()
            end
        end
    end)
end

return CommandClient