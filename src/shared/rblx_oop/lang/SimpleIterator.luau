
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iterator = require(ReplicatedStorage.Shared.rblx_oop.util.Interator)

type Iterator<E> = Iterator.Iterator<E>

export type SimpleIterator<E> = {

} & Iterator<E>

return {}