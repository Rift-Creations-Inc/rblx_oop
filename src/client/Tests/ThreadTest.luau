local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Thread = require(ReplicatedStorage.Shared.rblx_oop.lang.Thread.Thread)


local function myCoolFunction()
    print(`hi`)
end


return function()
    local t1 = Thread.spawn(myCoolFunction)

    t1:join()
end