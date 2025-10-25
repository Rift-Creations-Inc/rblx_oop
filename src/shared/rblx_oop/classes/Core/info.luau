local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService('Stats')
local MemoryTrackingDisabledException = require(script.Parent.MemoryTrackingDisabledException)
local ServerOnlyException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.ServerOnlyException)

--[[
    @Subclass

    @NoInherit
--]]

export type NetworkInfo = {
    rx: number,
    tx: number,
}
export type NetworkPhysInfo = NetworkInfo

export type NetworkInfoFull = NetworkInfo & { phys: NetworkPhysInfo }

export type MemoryInfo = {
    totalMb: () -> number,

    getMbFromTag: (
        tag: Enum.DeveloperMemoryTag
    ) -> number,
}

export type DrawcallAndTriangleCount = {
    drawcallCount: number,
    triangleCount: number
}

export type RenderInfo = {
    
    contactsCount: number,
    instanceCount: number,
    
    movingPrimitivesCount: number,
    primitivesCount: number,
    
    physStepTime: number,
    
    frameTime: number,
    renderCpuFrameTime: number,
    renderGpuFrameTime: number,
    
    scene: DrawcallAndTriangleCount,
    shadows: DrawcallAndTriangleCount,
    
    UI2D: DrawcallAndTriangleCount,
    UI3D: DrawcallAndTriangleCount,

    renderFps: number,
    physicsFps: number,

    qualityLevel: Enum.SavedQualitySetting,
}

--[[
    Formatted according to the json response from myip.wtf
--]]
type RawServerInfo = {
    YourFuckingIPAddress: string,
    YourFuckingLocation: string,
    YourFuckingHostname: string,
    YourFuckingISP: string,
    YourFuckingTorExist: boolean,
    YourFuckingCity: string,
    YourFuckingCountry: string,
    YourFuckingCountryCode: string
}

--[[
    Formatted according to the json response from myip.wtf
--]]
export type ServerInfo = {
    ip: string,
    location: string,
    hostname: string,
    isp: string,
    city: string,
    country: string,
    countryCode: string,

    _raw_get_data: RawServerInfo
}

export type FullInfo = {
    network: NetworkInfoFull,

    memory: MemoryInfo,

    render: RenderInfo,

    server: ServerInfo
}

export type Info = {
    getNetworkInfo: () -> NetworkInfo,
    getNetworkPhysInfo: () -> NetworkPhysInfo,
    getNetworkInfoFull: () -> NetworkInfoFull,

    getMemoryInfo: () -> MemoryInfo,

    getRenderInfo: () -> RenderInfo,

    getServerInfo: () -> ServerInfo,

    getFullInfo: () -> FullInfo,
}

local Info = {}
Info.__index = Info

function Info.getNetworkInfo(): NetworkInfo
    local self: NetworkInfo = {
        rx = Stats.DataReceiveKbps,
        tx = Stats.DataSendKbps,
    }

    return self
end

function Info.getNetworkPhysInfo(): NetworkPhysInfo
    local self: NetworkPhysInfo = {
        rx = Stats.PhysicsReceiveKbps,
        tx = Stats.PhysicsReceiveKbps,
    }

    return self
end

function Info.getNetworkInfoFull(): NetworkInfoFull
    local info = Info.getNetworkInfo()
    local phys = Info.getNetworkPhysInfo()

    local self: NetworkInfoFull = {
        rx = info.rx,
        tx = info.tx,

        phys = phys
    }

    return self
end

local function _impl_getMbFromTag(tag: Enum.DeveloperMemoryTag): number
    if not Stats.MemoryTrackingEnabled then
        --MemoryTrackingDisabledException.new("Attempted to call getMbFromTag() while memory tracking is disabled - returning 0...")
        return 0
    end

    return Stats:GetMemoryUsageMbForTag(tag)
end

local function _impl_totalMb(): number
    if not Stats.MemoryTrackingEnabled then
        --MemoryTrackingDisabledException.new("Attempted to call getMemoryInfo() while memory tracking is disabled - returning 0...")
        return 0
    end

    return Stats:GetTotalMemoryUsageMb()
end

function Info.getMemoryInfo(): MemoryInfo
    if not Stats.MemoryTrackingEnabled then
        MemoryTrackingDisabledException.new("Memory tracking is disabled, functions will return 0.")
    end

    local self: MemoryInfo = {
        getMbFromTag = function(tag: Enum.DeveloperMemoryTag): number
            return _impl_getMbFromTag(tag)
        end,

        totalMb = function(): number
            return _impl_totalMb()
        end
    }

    return self
end

function Info.getRenderInfo(): RenderInfo
    local self: RenderInfo = {

        contactsCount = Stats.ContactsCount,
        instanceCount = Stats.InstanceCount,

        movingPrimitivesCount = Stats.MovingPrimitivesCount,
        primitivesCount = Stats.PrimitivesCount,

        physStepTime = Stats.PhysicsStepTime,

        frameTime = Stats.FrameTime,
        renderCpuFrameTime = Stats.RenderCPUFrameTime,
        renderGpuFrameTime = Stats.RenderGPUFrameTime,

        scene = {
            drawcallCount = Stats.SceneDrawcallCount,
            triangleCount = Stats.SceneTriangleCount,
        },

        shadows = {
            drawcallCount = Stats.ShadowsDrawcallCount,
            triangleCount = Stats.ShadowsTriangleCount,
        },

        UI2D = {
            drawcallCount = Stats.UI2DDrawcallCount,
            triangleCount = Stats.UI2DTriangleCount,
        },

        UI3D = {
            drawcallCount = Stats.UI3DDrawcallCount,
            triangleCount = Stats.UI3DTriangleCount
        },

        physicsFps = workspace:GetRealPhysicsFPS(),
        renderFps = 0,
        qualityLevel = UserSettings().GameSettings.SavedQualityLevel
    }
    self.renderFps = 1/self.frameTime

    return self
end

function Info.getServerInfo(): ServerInfo

	if game:GetService('RunService'):IsClient() then 
		ServerOnlyException.new("Info.getServerInfo() can only run on the server!")
		return {}
	end

    local success, response = pcall(function()
        return HttpService:GetAsync(`https://myip.wtf/json`)
    end)
    if not success then
        error(`something went wrong :d ({response})`)
    end

    local fuckingInfo: RawServerInfo = HttpService:JSONDecode(response)

    local self: ServerInfo = {
        ip = fuckingInfo.YourFuckingIPAddress,
        location = fuckingInfo.YourFuckingLocation,
        hostname = fuckingInfo.YourFuckingHostname,
        isp = fuckingInfo.YourFuckingISP,
        city = fuckingInfo.YourFuckingCity,
        country = fuckingInfo.YourFuckingCountry,
        countryCode = fuckingInfo.YourFuckingCountryCode,

        _raw_get_data = fuckingInfo,
    }

    return self
end

function Info.getFullInfo(): FullInfo
    local self: FullInfo = {}
    self.memory = Info.getMemoryInfo()
    self.network = Info.getNetworkInfoFull()
    self.render = Info.getRenderInfo()
    self.server = Info.getServerInfo()

    return self
end

function Info.new(): Info
    local self: Info = setmetatable({}, Info)
    
    return self
end

return Info