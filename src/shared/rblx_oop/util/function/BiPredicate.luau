
export type BiPredicate<T, U> = {
	test: (
        self: BiPredicate<T, U>,
        a: T, 
        b: U
    ) -> boolean
}

local function newBiPredicate<T, U>(f: (T, U) -> boolean): BiPredicate<T, U>
	local self: any = {}
	self.test = function(_, a: T, b: U)
		return f(a, b)
	end
	return self
end

return newBiPredicate