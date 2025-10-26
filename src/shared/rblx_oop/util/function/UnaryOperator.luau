local Function = require(script.Parent.Function)
type Function<T,R> = Function.Function<T,R>

export type UnaryOperator<T> = Function<T,T>

local function newUnaryOperator<T>(f: (T) -> T): UnaryOperator<T>
    return Function(f)
end

return newUnaryOperator