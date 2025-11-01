
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iterator = require(ReplicatedStorage.Shared.rblx_oop.util.Iterator)

type Iterator<E> = Iterator.Iterator<E>

export type SimpleIterator<E> = {
    read v: number,
} & Iterator<E>

return {}