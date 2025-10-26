
export type Supplier<T> = {
    get: (
        self: Supplier<T>
    ) -> T
}

local function newSupplier<T>(f: () -> T): Supplier<T>
    local self = {
        get = function(_): T
            return f()
        end
    }
    return self
end

return newSupplier