local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local CutsceneManager = {}
local sessions = {} -- [Player] = { [id] = boolean (ended?) }

local function newId()
	return string.format("%d-%d", math.floor(os.clock() * 1000), math.random(1, 1e9))
end

function CutsceneManager:PlayCutscene(Player, name, Params)
	local id = newId()
	sessions[Player] = sessions[Player] or {}
	sessions[Player][id] = false

	local mergedParams = Params or {}
	mergedParams.CutsceneId = id

	RemoteManager.FireClient(Player, "Cutscenes", name, "Start", mergedParams)

	local Session = {}

	function Session:WaitTilEnd(timeout)
		local startTime = os.clock()
		while Player and Player.Parent and sessions[Player] and sessions[Player][id] == false do
			if timeout and (os.clock() - startTime) >= timeout then
				return false
			end
			task.wait()
		end
		return true
	end

	function Session:IsEnded()
		return not sessions[Player] or sessions[Player][id] ~= false
	end

	function Session:ForceEnd(action, params)
		if sessions[Player] then
			sessions[Player][id] = true
		end
		if Player and Player.Parent then
			RemoteManager.FireClient(Player, "Cutscenes", name, action or "End", params or {})
		end
	end

	return Session
end

function CutsceneManager:MarkEnded(Player, id)
	if sessions[Player] then
		sessions[Player][id] = true
	end
end

Players.PlayerRemoving:Connect(function(Player)
	sessions[Player] = nil
end)

return CutsceneManager
