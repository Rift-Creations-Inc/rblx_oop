
local _GFLAGS: { [string]: string }= {
    ["GFlagSzConfigurationProfile"] = "QUIET",
    ["GFlagBlInternalDebug"] = "true",
    ["GFlagBlUseBloxstrapRPC"] = "false"
}
table.freeze(_GFLAGS)












-------- API CODE --------


local GFLAGS = {
    FLAGS = _GFLAGS
}

local function __GetValueAsBoolean(value: string): boolean
    if value == "true" then
        return true
        elseif value == "false" then
            return false
        else
            error(`GFLag: {value} cannot be converted to boolean. Is not "true" or "false"`)
        end
    end
    
local function DEBUG(txt: string)
    if not __GetValueAsBoolean("GFlagBlInternalDebug") then return end
    print(`[!] [GFlags] {txt}`)
end

function GFLAGS.GetValue(value: string): string
    DEBUG(`Getting {value}...`)
    return GFLAGS.FLAGS[value] or nil
end

function GFLAGS.TranslateStringToBoolean(str: string): boolean
    DEBUG(`Translating {str} to a boolean.`)
    return __GetValueAsBoolean(str)
end

function GFLAGS.GetValueAsBoolean(value: string): boolean
    return GFLAGS.TranslateStringToBoolean(GFLAGS.GetValue(value))
end

return GFLAGS