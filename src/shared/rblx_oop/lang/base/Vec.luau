local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RIterator = require(script.Parent.RIterator)
local Safe = require(script.Parent.Safe)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)

type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type RIterator<T> = RIterator.RIterator<T>

export type Vec<T> = {
    items: {T},

    push: (
        self: Vec<T>,
        item: T
    ) -> (),
    
    pop: (
        self: Vec<T>
    ) -> T?,

    get: (
        self: Vec<T>,
        index: number
    ) -> T?,

    size: (
        self: Vec<T>
    ) -> number,

    clear: (
        self: Vec<T>
    ) -> (),

    iterator: (
        self: Vec<T>
    ) -> RIterator<T>,

    remove: (
        self: Vec<T>,
        index: number
    ) -> string,
} & IBaseFeature<"Vec">

local Vec = {}
Vec.__index = Vec

function Vec.new<T>(): Vec<T>
    local self = setmetatable({
        items = {} :: {T}
    }, Vec)

    return self
end

function Vec.push<T>(self: Vec<T>, item: T)
    self._length = (self._length or #self.items) + 1
    self.items[self._length] = item
end

function Vec.pop<T>(self: Vec<T>)
    return table.remove(self.items)
end

function Vec.get<T>(self: Vec<T>, index: number): T?
    return self.items[index]
end

function Vec.size<T>(self: Vec<T>): number
    return self._length or #self.items
end

function Vec.clear<T>(self: Vec<T>): number
    self.items = {}
end

function Vec.iterator<T>(self: Vec<T>): RIterator<T>
    return RIterator.new(self.items)
end

function Vec.remove<T>(self: Vec<T>, index: number): T?
    local removed = table.remove(self.items, index)
    if removed ~= nil then
        self._length = (self._length or #self.items) - 1
    end
    return removed
end

function Vec.withCapacity(capacity: number)
    local items = {}
    for i = 1, capacity do
        items[i] = nil
    end
    return setmetatable({ items = items, _capacity = capacity, _length = 0}, Vec)
end

Safe(Vec)

return Vec