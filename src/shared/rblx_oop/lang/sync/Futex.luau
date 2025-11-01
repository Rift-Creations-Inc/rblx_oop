local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Option = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Option)
local Safe = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Safe)

local Some = Option.Some
local None = Option.None

type Option<T> = Option.Option<T>

export type Futex<K, V> = {
    wait: (
        key: K,
        expected: V
    ) -> Option<boolean>,

    wake: (
        key: K,
        n: number?
    ) -> number,

    store: (
        key: K,
        value: V
    ) -> (),

    load: (
        key: K
    ) -> Option<V>
}

type Waiter<K, V> = {
    thread: thread,
    expected: V
}

local Futex = {
    _typePath = "lang::sync::Futex"
}
Futex.__index = Futex


local waiters: { [any]: { Waiter<any,any> } } = {}
local state: { [any]: any } = {}

function Futex.wait<K,V>(key: K, expected: V): Option<boolean>
    local current = state[key]
    if current ~= expected then
        return Some(false)
    end

    local thread = coroutine.running()
    if not thread then
        error(`Futex.wait() must be called from a coroutine!`,2)
    end

    waiters[key] = waiters[key] or {}
    table.insert(waiters[key], { thread = thread, expected = expected} :: Waiter<K,V>)

    coroutine.yield()
    return Some(true)
end


function Futex.wake<K>(key: K, n: number?): number
    local queue = waiters[key]
    if not queue or #queue == 0 then
        return 0
    end

    local count = n or 1
    local woken = 0

    while woken < count and #queue > 0 do
        local waiter = table.remove(queue,1)
        task.defer(coroutine.resume,waiter.thread)
        woken += 1
    end

    if #queue == 0 then
        waiters[key] = nil
    end

    return woken
end

function Futex.store<K, V>(key: K, value: V)
    state[key] = value
end

function Futex.load<K, V>(key: K): Option<V>
    local value = state[key]
    if value == nil then
        return None
    end
    return Some(value)
end

function Futex.clear<K>(key: K)
    state[key] = nil
    waiters[key] = nil
end

Safe(Futex)

return (Futex :: any) :: Futex<any,any>