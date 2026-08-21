local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Interface = {}
Interface.__index = Interface

function Interface.new()
	local metatable = setmetatable({}, Interface)
	return metatable
end

function Interface:Start()
	while true do
		if game:IsLoaded() then
			break
		end
		task.wait()
	end

	local ResetBindable = Instance.new("BindableEvent")
	ResetBindable.Event:Connect(function()
		RemoteManager.FireServer("ResetCharacter")
	end)

	task.spawn(function()
		while task.wait(0.2) do
			local Status = pcall(function()
				game.StarterGui:SetCore("ResetButtonCallback", ResetBindable)
			end)
			if Status then
				break
			end
		end
	end)

	RemoteManager.FireServer("ReplicationLoaded")
end

return Interface
