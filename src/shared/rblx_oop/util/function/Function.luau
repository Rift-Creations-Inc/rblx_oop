
export type FunctionShape<T,R> = {
    apply: (self: FunctionShape<T, R>, value: T) -> R
}

export type Function<T, R> = FunctionShape<T, R> & {
	andThen: <V>(
        self: FunctionShape<T, R>, 
        next: FunctionShape<R, V>
    ) -> FunctionShape<T, V>,

	compose: <A>(
        self: FunctionShape<T, R>, 
        before: FunctionShape<A, T>
    ) -> FunctionShape<A, R>,
}

local function newFunction<T,R>(f: (T) -> R): Function<T,R>
    local self = {
        apply = function(_, v: T): R
            return f(v)
        end,

        andThen = function<V>(_, next: FunctionShape<R,V>): FunctionShape<T,V>
            return newFunction(function(x: T): V
                return next:apply(f(x))
            end)
        end,
        compose = function<A>(_,before: FunctionShape<A,T>): FunctionShape<A,R>
            return newFunction(function(x: A)
                return f(before:apply(x))
            end)
        end
    }

    return self
end

return newFunction