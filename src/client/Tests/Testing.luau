
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourceT = require(ReplicatedStorage.Shared.rblx_oop.lang.ResourceT)
    local CountedResouce = ResourceT.CountedResource
    
local SimpleList = require(ReplicatedStorage.Shared.rblx_oop.lang.SimpleList)
type SimpleList<E> = SimpleList.SimpleList<E>

local Function = require(ReplicatedStorage.Shared.rblx_oop.util["function"].THIS)
local Consumer = Function.Consumer



local myWordRes: ResourceT.CountedResource<SimpleList.SimpleList<string>> = nil

local function printer()
    local ref = myWordRes:clone()
    local list = ref:get()

    if list:empty() then return end

    list:forEach(Consumer(function(x: string)
        print(`{x}`)
    end))

    ref:release()
end

return function()
    
    local myWord: SimpleList<string> = SimpleList.new()
        :add("my")
        :add("cool")
        :add("word")
        :add("!")

    myWordRes = CountedResouce.new(myWord)

    printer()
    myWordRes
        :release()
        :getRefrenceCount() -- should fail

    warn(`done`)
end