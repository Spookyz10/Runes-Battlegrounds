local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer

local ClientState = require(script.Parent.Shared.ClientState)

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
