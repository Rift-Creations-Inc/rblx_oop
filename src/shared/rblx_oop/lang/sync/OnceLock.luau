local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Result = require(ReplicatedStorage.Shared.rblx_oop.lang.base.Result)
local OnceLock = {}
OnceLock.__index = OnceLock

local Ok = Result.Ok
local Err = Result.Err

local Error = {
    notInitialized = 0,
    poisoned = 1
}

type Result<T,E> = Result.Result<T,E>

export type OnceLock<T, E> = {
    _value: T?,
    _initialized: boolean,
    _poisoned: boolean,
    _waiting: { thread },

    get: (
        self: OnceLock<T, E>
    ) -> Result<T,E>,

    getOrInit: (
        self: OnceLock<T, E>,
        initFn: () -> T
    ) -> Result<T, E>,   
}

function OnceLock.getErrors()
    return Error
end

function OnceLock.new<T, E>(): OnceLock<T, E>
    return setmetatable({
        value = nil,
        _initialized = false,
        _poisoned = false,
        _poisonedString = nil,
        _waiting = {}
    }, OnceLock)
end

function OnceLock.get<T,E>(self: OnceLock<T,E>): Result<T, E | number>
    if self._initialized then
        return Ok(self._value)
    end
    if self._poisoned then
        return Err(Error.poisoned)
    end

    return Err(Error.notInitialized)
end


function OnceLock.getOrInit<T,E>(self: OnceLock<T,E>, initFn: () -> T): Result<T,E>
    if self._initialized then
        return Ok(self._value)
    end

    if self._poisoned then
        return Err(Error.poisoned)
    end

    while not self._initialized and not self._poisoned do
        local co = coroutine.running()
        if co then
            table.insert(self._waiting,co)
            coroutine.yield()
        else
            break
        end
    end

    if self._initialized then
        return Ok(self._value)
    end
    if self._poisoned then
        return Err(Error.poisoned)
    end

    local ok, err = pcall(initFn)
    if not ok then
        self._poisoned = true
        for _, co in ipairs(self._waiting) do
            task.spawn(co)
        end
        self._waiting = {}
        return Err(err)
    end

    self._value = err
    self._initialized = true

    for _, co in ipairs(self._waiting) do
        task.spawn(co)
    end
    self._waiting = {}

    return Ok(err)
end

return OnceLock