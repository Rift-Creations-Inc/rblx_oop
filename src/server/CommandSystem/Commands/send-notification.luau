local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()

return function(plr: Player,args: {string})
    local level = args[2]
    local message = args[3]
    local time = tonumber(args[4])

    if level ~= "URGENT" and level ~= "LOW" and level ~= "DEBUG" and level ~= "IMPORTANT" then
	    return {
	    	success = false,
	    	message = `Invalid level "{level}". Expected one of: "URGENT", "LOW", "DEBUG", "IMPORTANT"`
	    }
    end

    if time == nil then
        return {
            success = false,
            message = "Time is invalid, expected a number."
        }
    end

    Core:dispatchEvent("sendGlobalNotification",level,message,time)

    return {
        success = true,
        message = "Notification sent to all players."
    }
end