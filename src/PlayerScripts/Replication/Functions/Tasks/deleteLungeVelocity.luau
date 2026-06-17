local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer

return function(_Params)
	if shared._lungeConn then
		shared._lungeConn:Disconnect()
		shared._lungeConn = nil
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
