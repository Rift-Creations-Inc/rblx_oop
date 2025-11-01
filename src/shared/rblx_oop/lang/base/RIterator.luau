local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Option = require(script.Parent.Option)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)

local None = Option.None
local Some = Option.Some

type Option<T> = Option.Option<T>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<N> = IFeature.IFeature<N>

local RIterator = {
    _typePath = "lang::base::RIterator"
}
RIterator.__index = RIterator

export type RIterator<T> = {
    next: (
        self: RIterator<T>
    ) -> Option<T>,

    sizeHint: (
        self: RIterator<T>
    ) -> number,

    count: (
        self: RIterator<T>
    ) -> number,

    nth: (
        self: RIterator<T>, 
        n: number
    ) -> Option<T>,
    
    map: <U>(
        self: RIterator<T>, 
        fn: (T) -> U
    ) -> any,

    filter: (
        self: RIterator<T>, 
        fn: (T) -> boolean
    ) -> RIterator<T>,

    find: (
        self: RIterator<T>, 
        fn: (T) -> boolean
    ) -> Option<T>,

    fold: <U>(
        self: RIterator<T>, 
        init: U, 
        fn: (U, T) -> U
    ) -> U,

    collect: (
        self: RIterator<T>
    ) -> {T},
}

function RIterator.new<T>(items: {T}): RIterator<T>
    local self = setmetatable({
        _index = 0
    }, RIterator)
    self.items = {}

    for _, v in ipairs(items) do
        table.insert(self.items,v)
    end

    return self
end

function RIterator.next<T>(self: RIterator<T>): Option<T>
    self._index += 1
    local value = self.items[self._index]
    if value == nil then
        return None
    else
        return Some(value)
    end
end

function RIterator.sizeHint<T>(self: RIterator<T>): number
    return #self.items - self._index
end

function RIterator.count<T>(self: RIterator<T>): number
    local count = 0
    while true do
        local val = self:next()
        if val == None then break end
        count += 1
    end
    return count
end

function RIterator.nth<T>(self: RIterator<T>, n: number): Option<T>
    self._index += n
    local val = self.items[self._index]
    if val == nil then
        return None
    else
        return Some(val)
    end
end

function RIterator.map<T,U>(self: RIterator<T>, fn: (T) -> U): RIterator<U>
    local mapped = {}
    local startIdx = self._index + 1
    for i = startIdx, #self.items do
        local item = self.items[i]
        local mappedItem = fn(item)
        table.insert(mapped,mappedItem)
    end
    return RIterator.new(mapped)
end

function RIterator.filter<T>(self: RIterator<T>, fn: (T) -> boolean): RIterator<T>
    local filtered = {}
    for i = self._index + 1, #self.items do
        local v = self.items[i]
        if fn(v) then
            table.insert(filtered,v)
        end
    end

    print(`filtered`, filtered)

    return RIterator.new(filtered)
end

function RIterator.find<T>(self: RIterator<T>,fn: (T) -> boolean): Option<T>
    for i = self._index + 1, #self.items do
        local v = self.items[i]
        if fn(v) then
            self._index = i
            return Some(v)
        end
    end
    return None
end

function RIterator.fold<T,U>(self: RIterator<T>, init: U, fn: (U, T) -> U): U
    local acc = init
    for i = self._index + 1, #self.items do
        acc = fn(acc, self.items[i])
    end

    return acc
end

function RIterator.collect<T>(self: RIterator<T>): { T }
    local collected = {}
    for i = self._index + 1, #self.items do
        table.insert(collected,self.items[i])
    end
    self._index = #self.items
    return collected
end

return RIterator