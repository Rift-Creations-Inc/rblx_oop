local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debugNatives = require(script.Parent.debugNatives)
local DroppedResourceException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.DroppedResourceException)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)


type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<S,N> = IFeature.IFeature<S,N>

local function _wrn(txt: string,t: string)
    if not debugNatives then return end
    warn(`[nativeTypeDebug::{t}] {txt}`)
end

local function _inf(txt: string, t: string)
    if not debugNatives then return end
    print(`[nativeTypeDebug::{t}] {txt}`)
end


export type WeakResource<T> = {
    upgrade: (
        self: WeakResource<T>
    ) -> CountedResource<T>?,

    release: (
        self: WeakResource<T>
    ) -> (),

    getRefrenceCount: (
        self: WeakResource<T>
    ) -> number,

    getWeakCount: (
        self: WeakResource<T>
    ) -> number
}

export type CountedResource<T> = {
    clone: (
        self: CountedResource<T>
    ) -> CountedResource<T>,

    get: (
        self: CountedResource<T>
    ) -> T?,

    release: (
        self: CountedResource<T>
    ) -> CountedResource<T>,

    getRefrenceCount: (
        self: CountedResource<T>
    ) -> number,

    getWeakCount: (
        self: CountedResource<T>
    ) -> number,

    downgrade: (
        self: CountedResource<T>
    ) -> WeakResource<T>?

} & IBaseFeature<"CountedResource">

type Inner<T> = {
    data: T?,
    strong: number,
    weak: number,
    alive: number
}

local CountedResource = {}
CountedResource.__index = CountedResource

local WeakResource = {}
WeakResource.__index = WeakResource

function CountedResource.new<T>(value: T): CountedResource<T>
    local inner: Inner<T> = {
        data = value,
        strong = 1,
        weak = 0,
        alive = true
    }

    local function makeCountedResource(): CountedResource<T>
        _inf(`creating new CountedResource<{typeof(value)}>`, "CountedResource")
        local self: CountedResource<T>
        self = {
            clone = function(_)
                if not inner.alive then
                    DroppedResourceException.new("cannot clone a dropped resource")
                    return
                end

                _wrn("cloning", "CountedResource")
                inner.strong += 1
                return makeCountedResource()
            end,

            get = function(_)
                return inner.alive and inner.data or nil
            end,

            release = function(_)
                _inf(`releasing counted resource...`,"CountedResource")
                if not inner.alive then return end
                inner.strong -= 1
                if inner.strong == 0 then
                    inner.data = nil
                    inner.alive = false
                    if inner.weak == 0 then
                        setmetatable(self,{
                            __index = function(_,k)
                                DroppedResourceException.new(`attempt to call {k}() on fully dropped CountedResource`)
                                return function() end
                            end
                        })
                        _wrn("all refrences have been dropped - dropping this CountedResource", "CountedResource")
                    end
                end
            end,

            getRefrenceCount = function(_)
                return inner.strong
            end,

            getWeakCount = function(_)
                return inner.weak
            end,

            downgrade = function(_)
                inner.weak += 1
                return WeakResource.new(inner,makeCountedResource)
            end
        }

        _inf("  done","CountedResource")
        return self
    end

    return makeCountedResource()
end

--[[
=========================================================================
--]]


function WeakResource.new<T>(inner: Inner<T>, makeCounted: () -> CountedResource<T>): WeakResource<T>
    _inf(`creating new WeakResource<{typeof(inner.data)}>`,"WeakResource")
    local self: WeakResource<T> 
    self = {
        upgrade = function(_)
            if inner.alive then
                inner.strong += 1
                return makeCounted()
            end

            return setmetatable({}, {
                __index = function(_,k)
                    DroppedResourceException.new(`attempt to call {k}() on dropped resource`)
                    return function() end
                end
            })
        end,

        release = function(_)
            inner.weak -= 1
            if inner.weak == 0 and not inner.alive then
                setmetatable(self, {
                    __index = function(_,k)
                        DroppedResourceException.new(`attempt to call {k}() on fully dropped WeakResource`)
                        return function() end
                    end
                })
                _wrn("cleaned up after last weak refrence - fully dropped","WeakResource")
            end
        end,

        getRefrenceCount = function(_)
            return inner.strong
        end,

        getWeakCount = function(_)
            return inner.weak
        end
    }
    _inf(`  done`,"WeakResource")

    return self
end

return {
    CountedResource = CountedResource,
    WeakResource = WeakResource
}