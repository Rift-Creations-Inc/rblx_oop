
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:FindFirstChild("Shared") or Instance.new("Folder")
shared.Name = "Shared"
shared.Parent = ReplicatedStorage

local rblx_oop = shared:FindFirstChild("rblx_oop") or Instance.new("Folder")
rblx_oop.Name = "rblx_oop"
rblx_oop.Parent = shared

local runtime = rblx_oop:FindFirstChild("runtime") or Instance.new("Folder")
runtime.Name = "runtime"
runtime.Parent = rblx_oop

if not runtime:FindFirstChild("SharedVarsEvent") then
	local event = Instance.new("RemoteEvent")
	event.Name = "SharedVarsEvent"
	event.Parent = runtime
	print("[InitRuntime] Created SharedVarsEvent")
else
	print("[InitRuntime] SharedVarsEvent already exists")
end