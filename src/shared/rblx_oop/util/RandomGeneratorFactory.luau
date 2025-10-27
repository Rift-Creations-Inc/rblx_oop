local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SimpleRng = require(script.Parent.SimpleRng)
local Xoshiro256PlusPlus = require(script.Parent.Xoshiro256PlusPlus)
local IRngBase = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IRngBase)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)

type IRngBase<S> = IRngBase.IRngBase<S>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<N> = IFeature.IFeature<N>

export type RNGName = "SimpleRng" | "Xoshiro256PlusPlus"
local RNGConstructors: {[string]: (number?) -> any} = {
    SimpleRng = SimpleRng.new,
    Xoshiro256PlusPlus = Xoshiro256PlusPlus.new
}

export type RandomGeneratorFactory<S> = {
    of: (
        self: RandomGeneratorFactory<S>,
        name: RNGName,
        seed: number?
    ) -> IRngBase<S>
} & IBaseFeature<"RandomGeneratorFactory">

local RandomGeneratorFactory = {}
RandomGeneratorFactory.__index = RandomGeneratorFactory

function RandomGeneratorFactory.new(): RandomGeneratorFactory<any>
    local self = setmetatable({}, RandomGeneratorFactory)
    return self
end



function RandomGeneratorFactory.of(_: RandomGeneratorFactory<any>,name: RNGName, seed: number?): IRngBase<any>
    return RNGConstructors[name](seed)
end

return RandomGeneratorFactory