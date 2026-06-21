local Constants = require(script.Parent.Shared.Constants)
local IndicatorService = require(script.Parent.Shared.IndicatorService)
local LocalPlayer = Constants.LocalPlayer

return function(Params)
	local character = Params.char
	local id = Params.id
	local asset = Params.asset
	local ownerId = Params.ownerId
	local originOffset = Params.originOffset or Vector3.new(0, 70, 0)

	if not character or not character.Parent then
		return
	end
	if not asset then
		warn("[Indicator] Params.asset não fornecido para id:", tostring(id))
		return
	end
	if not id then
		warn("[Indicator] Params.id não fornecido")
		return
	end

	local HumRP = character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local isOwner = LocalPlayer and LocalPlayer.UserId == ownerId

	IndicatorService:Create({
		id = id,
		asset = asset,
		character = character,
		ownerId = ownerId,
		getRayOrigin = function()
			return HumRP and HumRP.Parent and (HumRP.Position + originOffset)
		end,
		getDirection = function()
			if isOwner then
				return workspace.CurrentCamera.CFrame.LookVector
			end
			return HumRP and HumRP.Parent and HumRP.CFrame.LookVector or Vector3.new(0, 0, -1)
		end,
	})
end
