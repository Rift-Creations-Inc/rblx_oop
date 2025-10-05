-- DebugMaster.lua
local UserInputService = game:GetService("UserInputService")

local DebugMaster = {}
DebugMaster.__index = DebugMaster

-- Table to store all registered debug screens
DebugMaster.screens = {}
DebugMaster.conn = nil

-- Register a new screen
-- screen must have: .toggle(), .enabled, .toggleKey
function DebugMaster.registerScreen(screen)
    assert(screen.toggle and type(screen.toggle) == "function", "Screen must have a toggle() function")
    assert(screen.toggleKey and typeof(screen.toggleKey) == "EnumItem", "Screen must have a toggleKey Enum.KeyCode")
    table.insert(DebugMaster.screens, screen)
end

-- Input handler
function DebugMaster.onInput(input, gp)
    if gp then return end -- ignore input when game processed it

    for _, screen in ipairs(DebugMaster.screens) do
        if input.KeyCode == screen.toggleKey then
            -- Hide all other screens before toggling the selected one
            for _, other in ipairs(DebugMaster.screens) do
                if other ~= screen and other.enabled then
                    other:hide()
                end
            end
            screen:toggle()
        end
    end
end

-- Start listening for input
function DebugMaster.start()
    if DebugMaster.conn then return end
    DebugMaster.conn = UserInputService.InputBegan:Connect(DebugMaster.onInput)
end

-- Stop listening for input
function DebugMaster.stop()
    if DebugMaster.conn then
        DebugMaster.conn:Disconnect()
        DebugMaster.conn = nil
    end
end

-- Optional: unregister a screen
function DebugMaster.unregisterScreen(screen)
    for i, s in ipairs(DebugMaster.screens) do
        if s == screen then
            table.remove(DebugMaster.screens, i)
            break
        end
    end
end

return DebugMaster