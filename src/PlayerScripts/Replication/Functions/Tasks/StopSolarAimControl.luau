local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer

return function(Params)
	shared._solarAimActive = false

	if shared._solarAimConn then
		shared._solarAimConn:Disconnect()
		shared._solarAimConn = nil
	end

	local LocalChar = LocalPlayer.Character
	local LocalHumanoid = LocalChar and LocalChar:FindFirstChild("Humanoid")
	if LocalHumanoid then
		LocalHumanoid.AutoRotate = true
	end
end
