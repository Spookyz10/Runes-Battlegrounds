local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteManager = {}

local RemoteEvents = {
	Replicate = "Client",
}

local RemoteFunctions = {
	Replicate = "Server",
}

local RemoteCache: { [string]: Instance } = {}

local function getRemote(remoteName: string, folder: string): Instance?
	local CacheKey = folder .. ":" .. remoteName
	local Cached = RemoteCache[CacheKey]
	if Cached and Cached.Parent then
		return Cached
	end

	local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	local TargetFolder = RemotesFolder and RemotesFolder:FindFirstChild(folder)
	if not TargetFolder then
		return nil
	end

	local Remote = TargetFolder:FindFirstChild(remoteName)
	if Remote then
		RemoteCache[CacheKey] = Remote
	end

	return Remote
end

function RemoteManager.FireAllClients(remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Client")
	if not remote then
		return
	end

	remote:FireAllClients(...)
end

function RemoteManager.FireClient(Player: Player, remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Client")
	if not remote then
		return
	end

	remote:FireClient(Player, ...)
end

function RemoteManager.FireServer(remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return
	end

	remote:FireServer(...)
end

function RemoteManager.InvokeServer(remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return nil
	end

	return remote:InvokeServer(...)
end

function RemoteManager.GetRemote(remoteName: string, folder: string): Instance?
	return getRemote(remoteName, folder)
end

function RemoteManager.ListenClient(remoteName: string, Listener: { [string]: any })
	local remote = getRemote(remoteName, "Client")
	if not remote then
		return
	end

	remote.OnClientEvent:Connect(function(Task, ...)
		local ListenerModule = Listener[Task]
		if not ListenerModule then
			return
		end

		ListenerModule:Activate(...)
	end)
end

function RemoteManager.ListenServer(remoteName: string, Listener: { [string]: any })
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return
	end

	remote.OnServerEvent:Connect(function(Player, Task, ...)
		local ListenerModule = Listener[Task]
		if not ListenerModule then
			return
		end

		ListenerModule:Activate(Player, ...)
	end)
end

if RunService:IsServer() then
	for remoteName: string, folder: string in RemoteEvents do
		local NewRemote = Instance.new("RemoteEvent")
		NewRemote.Name = remoteName
		NewRemote.Parent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder)
	end

	for remoteName: string, folder: string in RemoteFunctions do
		local NewRemoteFunction = Instance.new("RemoteFunction")
		NewRemoteFunction.Name = remoteName
		NewRemoteFunction.Parent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder)
	end
end

return RemoteManager
