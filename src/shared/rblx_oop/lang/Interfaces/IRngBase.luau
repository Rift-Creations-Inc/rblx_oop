local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)

type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<N> = IFeature.IFeature<N>

export type IRngBase<S> = {
    nextInt: (
        self: S,
        min: number?,
        max: number?
    ) -> number,

    nextFloat: (
        self: S
    ) -> number,

    nextBool: (
        self: S
    ) -> boolean
} & IBaseFeature<"IRngBase">

return {}