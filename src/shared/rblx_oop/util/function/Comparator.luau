
export type Comparator<T> = {
    compare: (
        self: Comparator<T>,
        a: T,
        b: T
    ) -> number,

    thenComparing: (
        self: Comparator<T>,
        other: Comparator<T>
    ) -> Comparator<T>,

    reversed: (
        self: Comparator<T>
    ) -> Comparator<T>
}

local function newComparator<T>(fn: (a: T, b: T) -> number): Comparator<T>
    local this: Comparator<T> = {
        compare = fn,

        thenComparing = function(self, other)
            return newComparator(function(a: T, b: T)
                local r = self:compare(a,b)
                if r ~= 0 then return r end
                return other: compare(a,b)
            end)
        end,

        reversed = function(self)
            return newComparator(function(a: T, b: T)
                return -self:compare(a,b)
            end)
        end
    }

    return this
end

return newComparator