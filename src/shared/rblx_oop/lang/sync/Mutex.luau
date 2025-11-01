local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PoisonError = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Error.PoisonError)

local Mutex = {}
Mutex.__index = Mutex

export type MutexGuard<T> = {
    _value: T,
    _mutex: Mutex<T>,
    get: (
        self: MutexGuard<T>
    ) -> T,

    set: (
        self: MutexGuard<T>,
        newValue: T
    ) -> never,

    relase: (
        self: MutexGuard<T>
    ) -> never
}

export type Mutex<T> = {
    _locked: boolean,
    _value: T,
    _poisoned: boolean,

    lock: (
        self: Mutex<T>
    ) -> MutexGuard<T>,

    tryLock: (
        self: Mutex<T>
    ) -> MutexGuard<T>?,

    withLock: <R>(
        self: Mutex<T>,
        fn: (T) -> R
    ) -> R,
}

local function MakeMutexGuard<T>(mutex: Mutex<T>): MutexGuard<T>
    local relased = false
    local guard: MutexGuard<T>

    guard = {
        get = function(_)
            return mutex._value
        end,

        set = function(_,new)
            mutex._value = new
        end,

        release = function(_)
            if not relased then
                mutex._locked = false
                relased = true
            end
        end,
    }
    return guard
end

local function PoisonCheck<T>(self: Mutex<T>)
    if self._poisoned then
        PoisonError.new("Mutex is poisoned", self._value)
    end
end

function Mutex.new<T>(v: T): Mutex<T>
    local self = setmetatable({
        _value = v,
        _locked = false
    }, Mutex)
    return self
end

local function waitForUnlock(mutex: Mutex<any>)
    PoisonCheck(mutex)

    while mutex._locked do
        task.wait()
    end
end


function Mutex.lock<T>(self: Mutex<T>): MutexGuard<T>
    PoisonCheck(self)

    waitForUnlock(self)
    self._locked = true

    return MakeMutexGuard(self)
end

function Mutex.tryLock<T>(self: Mutex<T>): MutexGuard<T>?
    PoisonCheck(self)

    if self._locked then
        return nil
    end
    self._locked = true
    return MakeMutexGuard(self)
end

function Mutex.withLock<T,R>(self: Mutex<T>,fn: (T) -> R): R
    PoisonCheck(self)

    local guard = self:lock()
    local ok, result = pcall(fn,guard._value)
    guard:relase()
    if not ok then
        self._poisoned = true
        
        error(result,2)
    end
    return result
end

return Mutex