local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iterator = require(ReplicatedStorage.Shared.rblx_oop.util.Iterator)
local Predicate = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Predicate)
local Consumer = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Consumer)

type Predicate<T> = Predicate.Predicate<T>
type Consumer<T> = Consumer.Consumer<T>

--[[
    @Interface
--]]

local lang = game.ReplicatedStorage.Shared.rblx_oop.lang
local IBaseFeature = require(lang.Interfaces.IBaseFeature)
local IFeature = require(lang.Interfaces.IFeature)

type IFeature<N> = IFeature.IFeature<N>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

type Iterator<E> = Iterator.Iterator<E>

export type Iterable<T> = {
    iterator: (
        self: Iterable<T>
    ) -> Iterator<T>,

    forEach: (
        self: Iterable<T>,
        action: Consumer<T>
    ) -> never,

    ifForEach: (
        self: Iterable<T>,
        predicate: Predicate<T>,
        action: Consumer<T>
    ) -> never
} & IBaseFeature<"Iterable">

return {}