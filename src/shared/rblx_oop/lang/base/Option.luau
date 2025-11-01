
-- Option module
local Option = {}
Option.__index = Option

export type Option<T> = {
    isSome: boolean,
    isNone: boolean,
    
    unwrap: (
        self: Option<T>
    ) -> T,

    unwrapOr: (
        self: Option<T>, 
        default: T
    ) -> T,

    map: <U>(
        self: Option<T>,
        fn: (T) -> U
    ) -> Option<U>
}

function Option.Some(value)
    return setmetatable({
        isSome = true,
        isNone = false,
        value = value,
    }, Option)
end

Option.None = setmetatable({
    isSome = false,
    isNone = true,
}, Option)

function Option:unwrap()
    if self.isSome then
        return self.value
    else
        error("called unwrap on None")
    end
end

function Option:unwrapOr(default)
    if self.isSome then
        return self.value
    else
        return default
    end
end

function Option:map(fn)
    if self.isSome then
        return Option.Some(fn(self.value))
    else
        return self
    end
end

return Option
