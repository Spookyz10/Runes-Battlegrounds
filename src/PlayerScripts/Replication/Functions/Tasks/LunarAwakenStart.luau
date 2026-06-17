local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets
local RunService = Constants.RunService

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	State.lunarNightCount += 1
	if State.lunarNightCount == 1 then
		State:tweenToNight()
	end

	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken

	local MoonFog = LunarAwaken.MoonFog:Clone()
	MoonFog.Position = HumRP.Position + Vector3.new(0, -3, 0)
	MoonFog.Anchored = true
	MoonFog.Parent = workspace

	local Moon = LunarAwaken.Moon:Clone()
	Moon.Anchored = true
	Moon.CFrame = CFrame.new(HumRP.Position + Vector3.new(0, 70, 0))
	Moon.Parent = workspace

	local moonConn = RunService.RenderStepped:Connect(function()
		if not HumRP or not HumRP.Parent then
			return
		end
		Moon.CFrame = CFrame.new(HumRP.Position + Vector3.new(0, 70, 0))
	end)

	State.lunarData[Character] = { moon = Moon, moonFog = MoonFog, moonConn = moonConn }
end
