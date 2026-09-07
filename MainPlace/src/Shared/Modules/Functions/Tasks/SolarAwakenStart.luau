local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	require(script.Parent.SolarAwakenEnd)({ char = Character })
	State:beginNight("Solar", Character)

	local SolarAwaken = CharacterAssets.Eclipse.Solar.Awaken

	local SolarFog = SolarAwaken.SolarFog:Clone()
	SolarFog.Position = HumRP.Position + Vector3.new(0, -3, 0)
	SolarFog.Anchored = true
	SolarFog.Parent = workspace

	State.solarData = State.solarData or {}
	State.solarData[Character] = { solarFog = SolarFog }
	local data = State.solarData[Character]
	data.removingConnection = Character.AncestryChanged:Connect(function()
		if not Character:IsDescendantOf(workspace) and State.solarData[Character] == data then
			require(script.Parent.SolarAwakenEnd)({ char = Character })
		end
	end)
	task.delay(60, function()
		if State.solarData[Character] == data then
			require(script.Parent.SolarAwakenEnd)({ char = Character })
		end
	end)
end
