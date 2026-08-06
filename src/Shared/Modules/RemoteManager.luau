local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteManager = {}

local RemoteEvents = {
	ReplicateTask = "Client",
	ExtraCds = "Client",
	Keypress = "Server",
	ResetCharacter = "Server",
	SetMoveset = "Server",
	InputDetected = "Server",
	ReplicationLoaded = "Server",
	UseAbillity = "Server",
}

local RemoteFunctions = {}

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

function RemoteManager.ListenToAll(Listener: { [string]: any })
	for remoteName, folder in RemoteEvents do
		if folder ~= "Server" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnServerEvent:Connect(function(Player: Player, ...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return
			end

			ListenerModule:Activate(Player, ...)
		end)
	end
end

function RemoteManager.ListenToAllFunctions(Listener: { [string]: any })
	for remoteName, folder in RemoteFunctions do
		if folder ~= "Server" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnServerInvoke = function(Player: Player, ...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return nil
			end

			return ListenerModule:Invoke(Player, ...)
		end
	end
end

function RemoteManager.ListenToAllClient(Listener: { [string]: any })
	for remoteName, folder in RemoteEvents do
		if folder ~= "Client" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnClientEvent:Connect(function(...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return
			end

			ListenerModule:Activate(...)
		end)
	end
end

if RunService:IsServer() then
	for remoteName: string, folder: string in RemoteEvents do
		local ExistingFolder = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder)
		if ExistingFolder and not ExistingFolder:FindFirstChild(remoteName) then
			local NewRemote = Instance.new("RemoteEvent")
			NewRemote.Name = remoteName
			NewRemote.Parent = ExistingFolder
		end
	end

	for remoteName: string, folder: string in RemoteFunctions do
		local ExistingFolder = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder)
		if ExistingFolder and not ExistingFolder:FindFirstChild(remoteName) then
			local NewRemoteFunction = Instance.new("RemoteFunction")
			NewRemoteFunction.Name = remoteName
			NewRemoteFunction.Parent = ExistingFolder
		end
	end
end

return RemoteManager
