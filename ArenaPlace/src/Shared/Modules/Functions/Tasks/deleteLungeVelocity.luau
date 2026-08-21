local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer

local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)

return function(_Params)
	if ClientState.LungeConnection then
		ClientState.LungeConnection:Disconnect()
		ClientState.LungeConnection = nil
	end

	local Character = LocalPlayer.Character
	if not Character then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local bv = HumRP:FindFirstChild("LungeVelocity")
	if bv then
		bv:Destroy()
	end
end
