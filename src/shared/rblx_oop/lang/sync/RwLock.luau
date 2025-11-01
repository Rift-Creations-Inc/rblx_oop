local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PoisonError = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Error.PoisonError)
local debugNatives = require(ReplicatedStorage.Shared.rblx_oop.lang.debugNatives)

local function _dbg(x: string)
    if debugNatives then
        print(`[nativeTypeDebug::{script.Name}] {x}`)
    end
end

local function _wrn(x: string)
    if debugNatives then
        warn(`[nativeTypeDebug::{script.Name}] {x}`)
    end
end

export type RwLock<T> = {
    read: (self: RwLock<T>) -> (T, (success: boolean) -> ()),
    write: (self: RwLock<T>) -> (T, (success: boolean) -> ())
}

local RwLock = {}
RwLock.__index = RwLock

function RwLock.new<T>(value: T): RwLock<T>
    _dbg(`creating new RwLock<{typeof(value)}>`)

    local self = {
        _value = value,
        _readers = 0,
        _writer = false,
        _waiting = {} :: { thread }
    }
    return setmetatable(self, RwLock)
end

local function PoisonCheck<T>(x: RwLock<T>)
    if x._poisoned then
        PoisonError.new("RwLock is poisoned")
    end
end

local function wakeNext<T>(self: RwLock<T>)
    if #self._waiting == 0 then return end
    local nextCo = table.remove(self._waiting,1)
    task.spawn(nextCo)
end

function RwLock.read<T>(self: RwLock<T>)
    PoisonCheck(self)

    while self._writer do
        local co = coroutine.running()
        table.insert(self._waiting,co)
        coroutine.yield()
    end
    self._readers += 1

    return self._value, function(success: boolean) 
        self._readers -= 1
        if not success then
            self._poisoned = true
        end
        if self._readers == 0 then
            wakeNext(self)
        end
    end
end

function RwLock.write<T>(self: RwLock<T>)
    PoisonCheck(self)

    while self._writer or self._readers > 0 do
        local co = coroutine.running()
        table.insert(self._waiting,co)
        coroutine.yield()
    end
    self._writer = true

    return self._value, function(success: boolean)
        self._writer = false
        if not success then
            self._poisoned = true
        end
        wakeNext(self)
    end
end

return RwLock