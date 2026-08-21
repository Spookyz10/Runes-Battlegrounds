local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Assets = ServerStorage.Assets

local AnimationsTable = {}
for _, Animation in Assets.Animations:GetDescendants() do
	if Animation:IsA("Animation") then
		table.insert(AnimationsTable, Animation.AnimationId)
	end
end

local Remote = {}

function Remote:Activate(Player: Player)
	RemoteManager.FireClient(Player, "ReplicateTask", "preloadanims", AnimationsTable)
end

return Remote
