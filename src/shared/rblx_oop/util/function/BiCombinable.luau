
export type BiCombinable<T, U> = {
    andAlso: (
        self: BiCombinable<T,U>,
        other: BiCombinable<T,U>
    ) -> BiCombinable<T,U>,

    orElse: (
        self: BiCombinable<T,U>,
        other: BiCombinable<T,U>
    ) -> BiCombinable<T,U>,

    negate: (
        self: BiCombinable<T,U>
    ) -> BiCombinable<T,U>,
}

return function()
    return nil
end