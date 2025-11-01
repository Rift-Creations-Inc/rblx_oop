
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local ResourceT = require(ReplicatedStorage.Shared.rblx_oop.lang.ResourceT)
    local CountedResouce = ResourceT.CountedResource
    
local SimpleList = require(ReplicatedStorage.Shared.rblx_oop.lang.SimpleList)
local RIterator = require(ReplicatedStorage.Shared.rblx_oop.lang.base.RIterator)
local String = require(ReplicatedStorage.Shared.rblx_oop.lang.base.String)
local OnceLock = require(ReplicatedStorage.Shared.rblx_oop.lang.sync.OnceLock)
local RwLock = require(ReplicatedStorage.Shared.rblx_oop.lang.sync.RwLock)
local RandomGeneratorFactory = require(ReplicatedStorage.Shared.rblx_oop.util.RandomGeneratorFactory)
local Predicate = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Predicate)
type SimpleList<E> = SimpleList.SimpleList<E>

type String = String.String

local Function = require(ReplicatedStorage.Shared.rblx_oop.util["function"].THIS)
local Consumer = Function.Consumer

local myWordRes: ResourceT.CountedResource<SimpleList.SimpleList<string>> = nil

local function printer()
    local ref = myWordRes:clone()
    local list = ref:get()

    if list:empty() then return end

    list:forEach(Consumer(function(x: string)
        print(`list:forEach: {x}`)
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

    warn('done test 1')

    local function generate(x: RandomGeneratorFactory.RNGName)
        local gen = RandomGeneratorFactory.new():of(x)
    
        print(`[generate] generating with {x}`)
        print(`[generate]       int:   {gen:nextInt()}`)
        print(`[generate]       int:   {gen:nextInt()}`)
        print(`[generate]     float:   {gen:nextFloat()}`)
        print(`[generate]     float:   {gen:nextFloat()}`)
        print(`[generate]   boolean:   {gen:nextBool()}`)
        print(`[generate]   boolean:   {gen:nextBool()}`)
    end

    generate("SimpleRng")
    generate("SimpleRng")
    generate("SimpleRng")

    generate("Xoshiro256PlusPlus")
    generate("Xoshiro256PlusPlus")
    generate("Xoshiro256PlusPlus")

    warn(`done test 2`)

    local cool = {1,2,3,4,5,7,2,10}
    local iter = RIterator.new(cool)
    local evens = iter:filter(function(x: number)
        print(`{x} % 2`)
        if x % 2 == 0 then
            print(` yes`)
            return true 
        end

        print(` no`)
        return false
    end):collect()

    print(evens)

    warn(`done test 3`)

    local testValue: String = String.from("test_value")

    print(
        testValue:iterator():filter(function(s) 
            return s == '_'
    end):collect())

    warn(`done test 4`)

    require(script.Parent.ThreadTest)()
end