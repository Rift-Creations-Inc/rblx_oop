local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IRngBase = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IRngBase)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)

type IRngBase<S> = IRngBase.IRngBase<S>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<N> = IFeature.IFeature<N>

export type SimpleRng = IRngBase<SimpleRng> & {
    seed: number,
} & IFeature<"SimpleRng">

local SimpleRng = {}
SimpleRng.__index = SimpleRng

local MAGIC_VALUE1 = 1664525
local MAGIC_VALUE2 = 1013904223

local function generateSeed(): number
    local t = os.clock() * 1e9
    local pid = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.UserId or math.random(1, 1e6)
    local r = Random.new():NextInteger(0, 2^31 - 1)
    return bit32.bxor(math.floor(t), pid, r)
end

function SimpleRng.new(seed: number?): SimpleRng
    local self: SimpleRng = setmetatable({
        seed = seed or generateSeed()
    }, SimpleRng)
    return self
end

function SimpleRng.nextInt(self: SimpleRng,min: number?,max: number?): number
    min = min or 0
    max = max or 2^31-1
    self.seed = (MAGIC_VALUE1 * self.seed + MAGIC_VALUE2) % 2^32
    local r = self.seed / 2^32
    return math.floor(min + r * (max - min + 1))
end

function SimpleRng.nextFloat(self: SimpleRng): number
    return self:nextInt(0,2^32-1) / 2^32
end

function SimpleRng.nextBool(self: SimpleRng)
    return self:nextInt(0,1) == 1
end

return SimpleRng