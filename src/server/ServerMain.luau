
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedVars = require(ReplicatedStorage.Shared.rblx_oop.runtime.SharedVars)
local rCore = require(ReplicatedStorage.Shared.rblx_oop.classes.Core)
local Core = rCore.get()

print(`waiting for sharedvars...`)
SharedVars.waitForLoad()
print(`done`)

local ServerMain = {}
ServerMain.__index = ServerMain

function ServerMain.onPlayerAdded(plr: Player)
    print(`[ServerMain.onPlayerAdded] {plr.Name} has joined!`)
end

function ServerMain.onPlayerRemoving(plr: Player)
    print(`[ServerMain.onPlayerRemoving] {plr.Name} is leaving!`)
end

function ServerMain.onServerClosing()
    print(`[ServerMain.onServerClosing] the server is now closing, goodbye!`)
end

--[[
    ip: string,
    location: string,
    hostname: string,
    isp: string,
    city: string,
    country: string,
    countryCode: string,
]]

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

function ServerMain:Main()
    Core
        :addEventListener("playerAdded",    ServerMain.onPlayerAdded)
        :addEventListener("playerRemoving", ServerMain.onPlayerRemoving)
        :addEventListener("serverClosing",  ServerMain.onServerClosing)
    
    SharedVars.onChanged(function(k: string,v: any)
        print(`[SharedVars.onChanged] {k} == {tostring(v)}`)
    end)

    -- print some server info
    local info = Core.info().getServerInfo()
    print(`=============================================================`)
    print(`our hostname is {info.hostname}`)
    print(`out ip is {info.ip}`)
    print(`out location is {info.location}`)
    print(`our isp is {info.isp}`)
    print(`=============================================================`)

    print(`waiting before dispatching...`)
    SharedVars
        :set('server/ip',info.ip)
        :set('server/location',info.location)
        :set('server/hostname',info.hostname)
        :set('server/isp',info.isp)
        :set('server/city',info.city)
        :set('server/country',info.country)
        :set('server/countryCode',info.countryCode)
        :set('server/type',getServerType())

    
    Core:dispatchEvent(`sharedVarsReady`)
end

return ServerMain