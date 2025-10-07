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
local GFlagSzConfigurationProfile = GFLAGS.GetValue("GFlagSzConfigurationProfile")
return require(script.profiles:FindFirstChild(GFlagSzConfigurationProfile))