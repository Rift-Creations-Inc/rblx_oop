local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interator = require(ReplicatedStorage.Shared.rblx_oop.util.Interator)
local Predicate = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Predicate)
local Consumer = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Consumer)

type Predicate<T> = Predicate.Predicate<T>
type Consumer<T> = Consumer.Consumer<T>

--[[
    @Interface
--]]

type Interator<E> = Interator.Iterator<E>

export type Iterable<T> = {
    iterator: (
        self: Iterable<T>
    ) -> Interator<T>,

    forEach: (
        self: Iterable<T>,
        action: Consumer<T>
    ) -> never,

    ifForEach: (
        self: Iterable<T>,
        predicate: Predicate<T>,
        action: Consumer<T>
    ) -> never
}

return {}