local IBaseFeature = require(script.Parent.IBaseFeature)

type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

export type IFeature<S,N> = {
    _featureName: N
} & IBaseFeature<S>

return {}