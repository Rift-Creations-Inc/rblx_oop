
export type BiFunction<T, U, R> = {
    apply: (
        self: BiFunction<T, U, R>,
        a: T,
        b: T
    ) -> R
}

local function newBiFunction<T,U,R>(f: (T,U) -> R): BiFunction<T,U,R>
    local self = {
        apply = function(_,a: T, b: U): R
            return f(a,b)
        end
    }
    return self
end

return newBiFunction