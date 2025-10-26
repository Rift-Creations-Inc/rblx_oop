
export type BiConsumer<T, U> = {
	accept: (
        self: BiConsumer<T, U>, 
        a: T, 
        b: U
    ) -> (),

	andThen: (
        self: BiConsumer<T, U>, 
        next: BiConsumer<T, U>
    ) -> BiConsumer<T, U>,
}

local function newBiConsumer<T, U>(f: (T, U) -> ()): BiConsumer<T, U>
	local self: any = {}

	self.accept = function(_, a: T, b: U)
		f(a, b)
	end

	self.andThen = function(_, next: BiConsumer<T, U>): BiConsumer<T, U>
		return newBiConsumer(function(a: T, b: U)
			f(a, b)
			next:accept(a, b)
		end)
	end

	return self
end

return newBiConsumer