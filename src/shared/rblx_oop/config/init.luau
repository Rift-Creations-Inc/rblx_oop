local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GFLAGS = require(ReplicatedStorage.Shared.rblx_oop.gflags.GFLAGS)
--[[
    @StaticClasss[
        Client
        Server
        Configuration
    ]

--]]


--[[
    profiles r now supported :D
--]]
local GFlagConfigurationProfile = GFLAGS.GetValue("GFlagConfigurationProfile")
return require(script.profiles:FindFirstChild(GFlagConfigurationProfile))