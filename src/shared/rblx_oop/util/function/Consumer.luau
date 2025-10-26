
export type Consumer<T> = {
    accept: (
        self: Consumer<T>,
        value: T
    ) -> (),
    
    andThen: (
        self: Consumer<T>,
        next: Consumer<T>
    ) -> Consumer<T>
}

local function newConsumer<T>(f: (T) -> ()): Consumer<T>
    local self = {
        accept = function(_,v: T)
            f(v)
        end,

        andThen = function(_,next: Consumer<T>): Consumer<T>
            return newConsumer(function(v: T)
                f(v)
                next:accept(v)
            end)
        end
    }

    return self
end

return newConsumer