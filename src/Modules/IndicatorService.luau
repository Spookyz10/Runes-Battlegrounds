local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set
local ComGet = Remotes.Comunicator.Get

local IndicatorService = {}

function IndicatorService:Create(params)
	assert(params.id, "[IndicatorService] params.id é obrigatório")
	assert(params.character, "[IndicatorService] params.character é obrigatório")
	assert(params.asset, "[IndicatorService] params.asset é obrigatório")

	RemoteManager.FireAllClients("ReplicateTask", "Indicator", {
		id = params.id,
		char = params.character,
		ownerId = params.ownerId,
		asset = params.asset,
		originOffset = params.originOffset,
	})
end

function IndicatorService:Destroy(id)
	RemoteManager.FireAllClients("ReplicateTask", "IndicatorEnd", { id = id })
end

function IndicatorService:GetPosition(Player, id)
	local ok, result = pcall(function()
		return ComGet:InvokeClient(Player, { Func = "GetIndicatorPosition", id = id })
	end)

	if ok and typeof(result) == "Vector3" then
		return result
	end
	return nil
end

return IndicatorService
