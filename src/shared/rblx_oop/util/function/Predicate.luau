
export type Predicate<T> = {
    test: (
        self: Predicate<T>,
        value: T
    ) -> boolean,

    andAlso: (
        self: Predicate<T>,
        other: T
    ) -> Predicate<T>,

    orElse: (
        self: Predicate<T>,
        other: T
    ) -> Predicate<T>,

    negate: (
        self: Predicate<T>
    ) -> Predicate<T>
}

local function newPredicate<T>(fn: (T) -> boolean): Predicate<T>
    local this: Predicate<T>

    this = {
        test = function(_,value)
            return fn(value) 
        end,

        andAlso = function(self: Predicate<T>, other: Predicate<T>)
            return newPredicate(function(v: T)
                return self:test(v) and other:test(v)
            end)
        end,

        orElse = function(self: Predicate<T>, other: Predicate<T>)
            return newPredicate(function(v: T)
                return self:test(v) or other:test(v)
            end)
        end,

        negate = function(self: Predicate<T>)
            return newPredicate(function(v: T)
                return not self:test(v)
            end)
        end
    }

    return this
end

return newPredicate