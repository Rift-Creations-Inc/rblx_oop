local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Thread = require(ReplicatedStorage.Shared.rblx_oop.lang.Thread.Thread)


local function myCoolFunction()
    print(`hi`)
end

local function what(x: number)
    if x == 67 then
        error(`don't pass in 67!`)
    end

    return
end

return function()
    local t1 = Thread.spawn(myCoolFunction)
    local t2 = Thread.spawn(what(67), 'what')

    t1:join()
    t2:join()
end