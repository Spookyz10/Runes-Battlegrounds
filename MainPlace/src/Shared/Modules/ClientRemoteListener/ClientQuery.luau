local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientContext = require(ReplicatedStorage.Shared.Modules.ClientContext)
local IndicatorService = require(ReplicatedStorage.Shared.Modules.Functions.Tasks.Shared.IndicatorService)

local Remote = {}

function Remote:Invoke(Params)
	local Func = Params.Func

	if Func == "GetCF" then
		if Params.Object == "Camera" then
			return workspace.CurrentCamera.CFrame
		elseif Params.Object == "Attachment" then
			return Params.Attachment.WorldCFrame
		elseif Params.Object == "MousePos" then
			return LocalPlayer:GetMouse().Hit.Position
		else
			return Params.Object.CFrame
		end
	elseif Func == "GetIndicatorPosition" then
		return IndicatorService:GetPosition(Params.id)
	elseif Func == "IsPartDestroyed" then
		return table.find(ClientContext.DestroyedParts, Params.Part) ~= nil
	end

	return nil
end

return Remote
