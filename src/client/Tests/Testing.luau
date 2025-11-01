
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local ResourceT = require(ReplicatedStorage.Shared.rblx_oop.lang.ResourceT)
    local CountedResouce = ResourceT.CountedResource
    
local SimpleList = require(ReplicatedStorage.Shared.rblx_oop.lang.SimpleList)
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

    local str = String.from("Foo")

    print(str + "Bar")

    local exclamation = String.from("!")

    print(str + exclamation)

    local isUppercase = Predicate(function(c: string)
        if c:upper() == c then return true end

        return false
    end)
    local isLowercase = isUppercase.negate

    local str1: String = str + "Bar"

    print(str1)

    warn(`done test 3`)
end