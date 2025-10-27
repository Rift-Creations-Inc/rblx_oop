local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IRngBase = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IRngBase)
local IBaseFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IBaseFeature)
local IFeature = require(ReplicatedStorage.Shared.rblx_oop.lang.Interfaces.IFeature)

local function band(a: number, b: number): number
    return bit32.band(a, b)
end

local function bor(a: number, b: number): number
    return bit32.bor(a, b)
end

local function bxor(a: number, b: number): number
    return bit32.bxor(a, b)
end

local function lshift(a: number, n: number): number
    return bit32.lshift(a, n)
end

local function rshift(a: number, n: number): number
    return bit32.rshift(a, n)
end

local function rotl(x: number, k: number): number
    return bor(lshift(x, k), rshift(x, 32 - k))
end

type IRngBase<S> = IRngBase.IRngBase<S>
type IBaseFeature<N> = IBaseFeature.IBaseFeature<N>
type IFeature<N> = IFeature.IFeature<N>

export type Xoshiro256PlusPlus = IRngBase<Xoshiro256PlusPlus> & {
    jump: (
        self: Xoshiro256PlusPlus
    ) -> Xoshiro256PlusPlus,

    longJump: (
        self: Xoshiro256PlusPlus
    ) -> Xoshiro256PlusPlus,

    next: (
        self: Xoshiro256PlusPlus
    ) -> number

} & IFeature<"Xoshiro256PlusPlus">

local Xoshiro256PlusPlus = {}
Xoshiro256PlusPlus.__index = Xoshiro256PlusPlus

local BIGNUMBER = 0xFFFFFFFF

local function generateSeed(): number
    local t = os.clock() * 1e9
    local pid = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.UserId or math.random(1, 1e6)
    local r = Random.new():NextInteger(0, 2^31 - 1)
    return bit32.bxor(math.floor(t), pid, r)
end

function Xoshiro256PlusPlus.new(seed: number?): Xoshiro256PlusPlus
    seed = seed or generateSeed()
    local state = {
        band(seed, BIGNUMBER),
        band(seed + 0x9E3779B9, BIGNUMBER),
        band(seed + 0xBF58476D, BIGNUMBER),
        band(seed + 0x94D049BB, BIGNUMBER)
    } :: {number}
    local self: Xoshiro256PlusPlus = setmetatable({state = state}, Xoshiro256PlusPlus)
    return self
end

function Xoshiro256PlusPlus.next(self: Xoshiro256PlusPlus)
    local s = self.state
    local result = band(rotl(s[1] + s[4], 23), BIGNUMBER)
    local t = lshift(s[2], 17)

    s[3] = bxor(s[3], s[1])
    s[4] = bxor(s[4], s[2])
    s[2] = bxor(s[2], s[3])
    s[1] = bxor(s[1], s[4])

    s[3] = bxor(s[3], t)
    s[4] = rotl(s[4], 45 % 32)

    return result
end

function Xoshiro256PlusPlus.nextInt(self: Xoshiro256PlusPlus, min: number?,max: number?): number
    min = min or 0
    max = max or 2^31-1
    local r = self:next()
    return math.floor(min + (r / BIGNUMBER) * (max - min + 1))
end

function Xoshiro256PlusPlus.nextFloat(self: Xoshiro256PlusPlus): number
    return self:next() / BIGNUMBER
end

function Xoshiro256PlusPlus.nextBool(self: Xoshiro256PlusPlus): boolean
    return band(self:next(), 1) == 1
end

return Xoshiro256PlusPlus