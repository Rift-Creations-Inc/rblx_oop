
local lang = game.ReplicatedStorage.Shared.rblx_oop.lang
local IBaseFeature = require(lang.Interfaces.IBaseFeature)

type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

export type Result<T, E> = {
    isOk: boolean,
    isErr: boolean,
    value: T?,
    error: E?,

    unwrap: (
        self: Result<T, E>
    ) -> T,

    unwrapErr: (
        self: Result<T, E>
    ) -> E
} & IBaseFeature<"Result">

local Result = {}
Result.__index = Result

function Result.Ok<T, E>(value: T): Result<T, E>
    local this: Result<T, E> = {
        isOk = true,
        isErr = false,
        value = value,
        error = nil
    }

    function this:unwrap(): T
        return value
    end

    function this:unwrapErr(): E
        error("called unwrapErr() on an Ok value")
    end

    return this
end

function Result.Err<T, E>(value: E): Result<T, E>
    local this: Result<T, E> = {
        isOk = false,
        isErr = true,
        value = nil,
        error = value
    }

    function this:unwrap(): T
        error(`called unwrap() on an Err value`)
    end

    function this:unwrapErr(): E
        return value
    end

    return this
end

return Result