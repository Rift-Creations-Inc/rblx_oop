local BiCombinable = require(script.Parent.BiCombinable)
local Predicate = require(script.Parent.Predicate)

type Predicate<T> = Predicate.Predicate<T>
type BiCombinable<T,U> = BiCombinable.BiCombinable<T,U>

export type BiPredicate<T, U> = {
	test: (
        self: BiPredicate<T, U>,
        a: T, 
        b: U
    ) -> boolean,

	asPredicate: (
		self: BiPredicate<T, U>
	) -> Predicate<{first: T, second: U}>
} & BiCombinable<T, U>

local function newBiPredicate<T, U>(f: (T, U) -> boolean): BiPredicate<T, U>
	local self = {
		test = function(_,a: T, b: U)
			return f(a,b)
		end,

		asPredicate = function(_): Predicate<{first: T,second: U}>
			return Predicate(function(pair)
				return f(pair.first,pair.second)
			end)
		end,

		andAlso = function(_, other: BiPredicate<T, U>): BiPredicate<T, U>
			return newBiPredicate(function(a: T, b: U)
				return f(a, b) and other:test(a, b)
			end)
		end,

		orElse = function(_,other: BiPredicate<T,U>): BiPredicate<T,U>
			return newBiPredicate(function(a: T, b: U)
				return f(a,b) or other:test(a, b)
			end)
		end,

		negate = function(_): BiPredicate<T,U>
			return newBiPredicate(function(a: T, b: U)
				return not f(a,b)
			end)
		end
	}
	return self
end

return newBiPredicate