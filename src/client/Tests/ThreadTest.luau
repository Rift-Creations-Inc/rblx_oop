local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Thread = require(ReplicatedStorage.Shared.rblx_oop.lang.Thread.Thread)


local function myCoolFunction()
    return 54
end


return function()
    local t1 = Thread.spawn(myCoolFunction)

    t1:join()
end