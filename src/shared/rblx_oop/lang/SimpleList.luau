local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotImplementedException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.NotImplementedException)
local SimpleIterator = require(script.Parent.SimpleIterator)
local Interable = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.Interable)
local Predicate = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Predicate)
local Consumer = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Consumer)

type Consumer<T> = Consumer.Consumer<T>
type Interable<T> = Interable.Iterable<T>
type SimpleIterator<E> = SimpleIterator.SimpleIterator<E>
type Predicate<T> = Predicate.Predicate<T>

export type SimpleList<E> = {
    items: {E},

    add: (
        self: SimpleList<E>, 
        item: E
    ) -> SimpleList<E>,

    get: (
        self: SimpleList<E>, 
        index: number
    ) -> E,

    size: (
        self: SimpleList<E>
    ) -> number,

    empty: (
        self: SimpleList<E>
    ) -> boolean

} & Interable<E>

local SimpleList = {}
SimpleList.__index = SimpleList

function SimpleList.new<E>(): SimpleList<E>
    local self: SimpleList<E> = setmetatable({
        items = {} :: {E}
    }, SimpleList)

    return self
end


function SimpleList.add<E>(self: SimpleList<E>,item: E)
    table.insert(self.items,item)
    return self
end

function SimpleList.get<E>(self: SimpleList<E>,index: number): E
    return self.items[index]
end

function SimpleList.size<E>(self: SimpleList<E>): number
    return #self.items
end

function SimpleList.empty<E>(self: SimpleList<E>): boolean
    return self:size() == 0
end

function SimpleList.forEach<E>(self: SimpleList<E>,action: Consumer<E>)
    for i = 1, self:size() do
        action:accept(self.items[i])
    end
end

function SimpleList.ifForEach<E>(self: SimpleList<E>,predicate: Predicate<E>, action: Consumer<E>)
    for i = 1, self:size() do
        local item = self.items[i]
        if predicate.test(predicate, item) then
            action:accept(item)
        end
    end
end

function SimpleList.iterator<E>(self: SimpleList<E>): SimpleIterator<E>
    local index = 0
    local items = self.items

    local iter: SimpleIterator<E> = {
        hasNext = function(): boolean
            return index < #items
        end,

        next = function(): E
            index += 1
            return items[index]
        end,

        remove = function(): never
            NotImplementedException.new("remove is not implemented")
            return
        end,

        forEachRemaining = function(action: Consumer<E>): never
            while index < #items do
                index += 1
                action:accept(items[index])
            end
        end
    }

    return iter
end

return SimpleList