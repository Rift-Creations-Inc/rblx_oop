local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FailedToFindMethodException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.FailedToFindMethodException)
local InfiniteYieldPossibleException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.InfiniteYieldPossibleException)


local function RaiseFailedToFindMehodException(script: string,line: number,method: string)
    FailedToFindMethodException.new(`unable to find method '{method}' at {script}:{line}`)
end

local function RaiseInfiniteYieldPossibleException(cause: string)
    InfiniteYieldPossibleException.new(`result of {cause}`)
end

LogService.MessageOut:Connect(function(msg: string, type: Enum.MessageType)
    if type ~= Enum.MessageType.MessageError then return end

    local scriptName, line = string.match(
        msg,
        "^([^:]+):(%d+):"
    )
    print(`[DEBUG/{script.Name}] msg<string>={msg}; type<Enum.MessageType>={type.Name}`)
    local cause = string.match(msg, "Infinite yield possible on ['\"](.+)['\"]")
    local method = string.match(msg, `attempt to call missing method '([%w_]+)'`)

    if method then
        RaiseFailedToFindMehodException(scriptName,line,method)
        return
    end

    if cause then
        RaiseInfiniteYieldPossibleException(cause)
    end
end)