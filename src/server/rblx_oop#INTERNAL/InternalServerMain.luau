
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)
local rCore = require(ReplicatedStorage.Shared.rblx_oop.classes.Core)
local config = require(ReplicatedStorage.Shared.rblx_oop.config)
local Core = rCore.get()

local function dbg(txt: string)
    if config.server.debugServerMainRunner then
        print(`[InternalServerMain] {txt}`)
    end
end

dbg(`waiting for sharedvars...`)
SharedVars.waitForLoad()
dbg(`done`)


local InternalServerMain = {}
InternalServerMain.__index = InternalServerMain

local function getServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "vip"
		else
			return "reserved"
		end
	else
		return "standard"
	end
end

function InternalServerMain:Main()

    -- print some server info
    local info = Core.info().getServerInfo()
    dbg(`=============================================================`)
    dbg(`our hostname is {info.hostname}`)
    dbg(`our isp is {info.isp}`)
    dbg(`our ip is {info.ip}`)
    dbg(`out location is {info.location}`)
    dbg(`=============================================================`)

    dbg(`creating server/* sharedvars...`)
    SharedVars
        :set('server/ip',info.ip)
        :set('server/location',info.location)
        :set('server/hostname',info.hostname)
        :set('server/isp',info.isp)
        :set('server/city',info.city)
        :set('server/country',info.country)
        :set('server/countryCode',info.countryCode)
        :set('server/type',getServerType())

    dbg(`dispatching sharedVarsReady...`)
    Core:dispatchEvent(`sharedVarsReady`)
end

return InternalServerMain