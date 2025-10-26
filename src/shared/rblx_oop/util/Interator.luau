local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Consumer = require(ReplicatedStorage.Shared.rblx_oop.util['function'].Consumer)

type Consumer<T> = Consumer.Consumer<T>

export type Iterator<E> = {
    hasNext: (
        self: Iterator<E>
    ) -> boolean,

    next: (
        self: Iterator<E>
    ) -> E,

    remove: (
        self: Iterator<E>
    ) -> never,

    forEachRemaining: (
        self: Iterator<E>,
        action: Consumer<E>
    ) -> never
}

return {}