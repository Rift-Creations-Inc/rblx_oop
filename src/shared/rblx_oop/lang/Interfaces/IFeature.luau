local IBaseFeature = require(script.Parent.IBaseFeature)

type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

export type IFeature<N> = {
    _featureName: N
}

return {}