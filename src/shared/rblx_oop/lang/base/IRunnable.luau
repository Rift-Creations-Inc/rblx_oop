local lang = game.ReplicatedStorage.Shared.rblx_oop.lang
local IBaseFeature = require(lang.Interfaces.IBaseFeature)
local IFeature = require(lang.Interfaces.IFeature)

type IFeature<N> = IFeature.IFeature<N>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>

export type IRunnable<R> = {

    run: (
        ...any
    ) -> R,

    start: (
        self: IRunnable<R>,
        ...any
    ) -> never
} & IBaseFeature<"IRunnable">

return function<R>(run: (...any) -> never): IRunnable<R>
    
    local this: IRunnable<R> = {
        start = function(self: IRunnable<R>,...: any)
            self.run(...)
        end,

        run = run
    }

    return this
end