local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end
	local Torso = Character:FindFirstChild("Torso")
	if not Torso then
		return
	end

	require(script.Parent.LunarAwakenEnd)({ char = Character })
	State:beginNight("Lunar", Character)

	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken

	local MoonFog = LunarAwaken.MoonFog:Clone()
	MoonFog.Position = Torso.Position + Vector3.new(0, -3, 0)
	MoonFog.Anchored = true
	MoonFog.Parent = workspace

	State.lunarData[Character] = { moonFog = MoonFog }
	local data = State.lunarData[Character]
	data.removingConnection = Character.AncestryChanged:Connect(function()
		if not Character:IsDescendantOf(workspace) and State.lunarData[Character] == data then
			require(script.Parent.LunarAwakenEnd)({ char = Character })
		end
	end)
	task.delay(60, function()
		if State.lunarData[Character] == data then
			require(script.Parent.LunarAwakenEnd)({ char = Character })
		end
	end)
end
