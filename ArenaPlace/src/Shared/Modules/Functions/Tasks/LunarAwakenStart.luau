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

	State.lunarNightCount += 1
	if State.lunarNightCount == 1 then
		State:tweenToNight()
	end

	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken

	local MoonFog = LunarAwaken.MoonFog:Clone()
	MoonFog.Position = Torso.Position + Vector3.new(0, -3, 0)
	MoonFog.Anchored = true
	MoonFog.Parent = workspace

	State.lunarData[Character] = { moonFog = MoonFog }
end
