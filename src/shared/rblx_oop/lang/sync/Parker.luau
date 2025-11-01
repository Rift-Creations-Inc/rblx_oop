local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local Option = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Option)
local Safe = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Safe)
local Futex = require(script.Parent.Futex)

type Option<T> = Option.Option<T>
type Futex<K, V> = Futex.Futex<K, V>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

export type Parker = {
    park: (
        self: Parker
    ) -> Parker,

    unpark: (
        self: Parker
    ) -> Parker,

    reset: (
        self: Parker
    ) -> Parker,
} & IBaseFeature<"Parker">

local Parker = {
    _typePath = "lang::sync::Parker"
}
Parker.__index = Parker

local _futex: Futex<Parker, number> = Futex
local NOTIFIED = 1
local WAITING = 0

function Parker.new(): Parker
    local self = setmetatable({
        _state = WAITING
    }, Parker)

    return self
end

function Parker.park(self: Parker): Parker
    local current = self._state

    if current == NOTIFIED then
        self._state = WAITING
        return
    end

    _futex.store(self, WAITING)
    _futex.wait(self, WAITING)
    self._state = WAITING

    return self
end

function Parker.unpark(self: Parker): Parker

    self._state = NOTIFIED
    _futex.store(self, NOTIFIED)
    _futex.wake(self)

    return self
end

function Parker.reset(self: Parker): Parker
    self._state = WAITING
    _futex.store(self,WAITING)
end

Safe(Parker)

return Parker