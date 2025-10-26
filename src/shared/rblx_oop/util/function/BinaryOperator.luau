
export type BinaryOperator<T> = {
    apply: (
        self: BinaryOperator<T>,
        a: T,
        b: T
    ) -> T
}

local function newBinaryOperator<T>(f: (T, T) -> T): BinaryOperator<T>
    local self = {
        apply = function(_,a: T, b: T)
            return f(a,b)
        end
    }

    return self
end

return newBinaryOperator