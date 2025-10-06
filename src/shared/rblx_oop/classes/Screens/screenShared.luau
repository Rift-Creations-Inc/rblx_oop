local RunService = game:GetService("RunService")

local style = "std"
local helpStr = "( F1: Minimal | F2: General | F3: Memory | F4: Server | F5: SharedVars )"
if RunService:IsStudio() then
    style = "studio"
    helpStr = "( F2: Minimal | F3: General | F4: Memory | F6: Server | F8: SharedVars ) [STUDIO VERSION]"
end

return {
    HELP = helpStr,

    memoryEnabled = false,
    generalEnabled = false,

    keyStyle = style
}