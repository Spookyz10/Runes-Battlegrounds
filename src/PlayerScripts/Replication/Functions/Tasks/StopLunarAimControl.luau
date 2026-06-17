local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer

return function(Params)
	shared._lunarAimActive = false

	if shared._lunarAimConn then
		shared._lunarAimConn:Disconnect()
		shared._lunarAimConn = nil
	end

	local LocalChar = LocalPlayer.Character
	local LocalHumanoid = LocalChar and LocalChar:FindFirstChild("Humanoid")
	if LocalHumanoid then
		LocalHumanoid.AutoRotate = true
	end
end
