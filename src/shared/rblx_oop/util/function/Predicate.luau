local Combinable = require(script.Parent.Combinable)

type Combinable<T> = Combinable.Combinable<T>

export type Predicate<T> = {
    test: (
        self: Predicate<T>,
        value: T
    ) -> boolean
} & Combinable<T>

local function newPredicate<T>(fn: (T) -> boolean): Predicate<T>
    local this: Predicate<T> = {
        test = fn,

        andAlso = function(self,other)
            return newPredicate(function(v)
                return self:test(v) or other:test(v)
            end)
        end,

        orElse = function(self,other)
            return newPredicate(function(v)
                return self:test(v) or other:test(v)
            end)
        end,

        negate = function(self)
            return newPredicate(function(v)
                return not self:test(v)
            end)
        end
    }

    return this
end

return newPredicate