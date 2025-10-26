
export type Combinable<T> = {
    andAlso: (
        self: Combinable<T>,
        other: Combinable<T>
    ) -> Combinable<T>,

    orElse: (
        self: Combinable<T>,
        other: Combinable<T>
    ) -> Combinable<T>,

    negate: (
        self: Combinable<T>
    ) -> Combinable<T>
}

return nil