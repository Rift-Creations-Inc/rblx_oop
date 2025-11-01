
export type NonZero<T> = number

local function isNonZero<T>(n: T): boolean
    return n ~= 0
end

local function new<T>(value: T): NonZero<T>
    assert(isNonZero(value),`Value {value} is 0`)
    local ret: NonZero<T> = value
    return ret
end

return new