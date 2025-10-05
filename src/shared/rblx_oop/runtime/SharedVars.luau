local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ServerOnlyException = require(ReplicatedStorage.Shared.rblx_oop.classes.Throwable.Exception.RuntimeException.ServerOnlyException)
local Core = require(ReplicatedStorage.Shared.rblx_oop.classes.Core).get()

--// Wait for Core
repeat
	task.wait()
until Core.initialized

print(`*** creating ***`)
if Core and Core.initialized then
	if not Core._events["sharedVarsUpdate"] then
		local ev = Instance.new("BindableEvent")
		Core:registerEvent("sharedVarsUpdate", ev.Event)
	end

	if not Core._events["sharedVarsReady"] then
		local ev = Instance.new('BindableEvent')
		Core:registerEvent(`sharedVarsReady`, ev.Event)
	end
end

--// Types
type SharedVarsTable = { [string]: any }

--// Internal state
local SharedVars = {
	_ready = false,
}
SharedVars.__index = SharedVars

local _vars: SharedVarsTable = {}
local _isLoaded = false
local _readyFired = false
local SharedVarsEvent: RemoteEvent?
local queuedUpdates = {}

--// Wait for runtime folder
local function waitForRuntime()
	local shared = ReplicatedStorage:WaitForChild("Shared")
	local rblx_oop = shared:WaitForChild("rblx_oop")
	local runtime = rblx_oop:FindFirstChild("runtime")

	if RunService:IsServer() then
		if not runtime then
			runtime = Instance.new("Folder")
			runtime.Name = "runtime"
			runtime.Parent = rblx_oop
		end
	else
		runtime = rblx_oop:WaitForChild("runtime")
	end

	return runtime
end

local runtime = waitForRuntime()

--// RemoteEvent setup
if RunService:IsServer() then
	SharedVarsEvent = runtime:FindFirstChild("SharedVarsEvent") :: RemoteEvent?
	if not SharedVarsEvent then
		SharedVarsEvent = Instance.new("RemoteEvent")
		SharedVarsEvent.Name = "SharedVarsEvent"
		SharedVarsEvent.Parent = runtime
	end
else
	-- Wait for server creation
	repeat
		SharedVarsEvent = runtime:FindFirstChild("SharedVarsEvent") :: RemoteEvent?
		task.wait(0.05)
	until SharedVarsEvent
end

--// Safe event registration
local function ensureCoreEvent(name: string)
	if not Core._events[name] then
		local ev = Instance.new("BindableEvent")
		Core:registerEvent(name, ev.Event)
	end
end

ensureCoreEvent("sharedVarsUpdate")
ensureCoreEvent("sharedVarsReady")

--// Internal queue flush
local function flushQueue()

	ensureCoreEvent("sharedVarsUpdate")

	for _, item in ipairs(queuedUpdates) do
		Core:dispatchEvent("sharedVarsUpdate", item.key, item.value)
	end
	table.clear(queuedUpdates)
end

--// Client listener
if RunService:IsClient() then
	SharedVarsEvent.OnClientEvent:Connect(function(data: SharedVarsTable)
		for k, v in pairs(data) do
			_vars[k] = v
			table.insert(queuedUpdates, { key = k, value = v })
		end

		if Core.initialized then
			flushQueue()
		else
			Core:addEventListener("coreInitialized", flushQueue, { once = true })
		end

		if not _readyFired then
			_readyFired = true
			_isLoaded = true
			SharedVars._ready = true
			ensureCoreEvent("sharedVarsReady")
			Core:dispatchEvent("sharedVarsReady")
		end
	end)
end

--// Server methods
function SharedVars:set(key: string, value: any)
	if not RunService:IsServer() then
		ServerOnlyException.new("Clients cannot modify SharedVars!")
		return self
	end

	_vars[key] = value
	SharedVarsEvent:FireAllClients({ [key] = value })
	Core:dispatchEvent("sharedVarsUpdate", key, value)
	return self
end

--// Accessors
function SharedVars.get(key: string): any
	return _vars[key]
end

function SharedVars.getAll(): SharedVarsTable
	return table.clone(_vars)
end

function SharedVars.onChanged(listener: (key: string, value: any) -> ())
	ensureCoreEvent("sharedVarsUpdate")
	Core:addEventListener("sharedVarsUpdate", listener)
end

--// Mark loaded (server-side)
local function markLoaded()
	if _isLoaded then return end
	_isLoaded = true
	SharedVars._ready = true
	ensureCoreEvent("sharedVarsReady")
	Core:dispatchEvent("sharedVarsReady")
end

if RunService:IsServer() then
	task.defer(markLoaded)

	local Players = game:GetService('Players')
	Players.PlayerAdded:Connect(function(plr)
		SharedVars:set(`game/playerCount`,#Players:GetChildren())
		SharedVarsEvent:FireClient(plr,_vars)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		SharedVars:set(`game/playerCount`,#Players:GetChildren())
	end)
end

--// Wait for load (safe)
function SharedVars.waitForLoad(timeout: number?)
	timeout = timeout or 10
	if _isLoaded then return true end

	local done = false
	local start = tick()

	Core:addEventListener("sharedVarsReady", function()
		done = true
	end, { once = true })

	while not done and tick() - start < timeout do
		task.wait(0.05)
	end

	if not done then
		warn(`[SharedVars] waitForLoad() timed out after {timeout}s`)
	end

	return done
end

--// Bind table
function SharedVars.bind(targetTable: { [string]: any })
	assert(typeof(targetTable) == "table", "SharedVars.bind expects a table")

	for k, v in pairs(_vars) do
		targetTable[k] = v
	end

	SharedVars.onChanged(function(key, value)
		targetTable[key] = value
	end)

	return { unbind = function() end }
end

--// onReady
function SharedVars.onReady(callback: () -> ())
	if _isLoaded then
		task.defer(callback)
	else
		Core:addEventListener("sharedVarsReady", callback, { once = true })
	end
end

return SharedVars