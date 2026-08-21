local Constants = require(script.Parent.Shared.Constants)

local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local RANDOM_RANGE = 20
local WAIT_TIME = 0.2
local FADE_IN_TIME = 0.1
local FADE_OUT_TIME = 0.3

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local BeamAsset = CharacterAssets.Eclipse.Solar.Awaken.Helioclysm:FindFirstChild("Beam")
	if not BeamAsset then
		return
	end

	local RandomZ = math.random(-RANDOM_RANGE, RANDOM_RANGE)
	local RandomX = math.random(-RANDOM_RANGE, RANDOM_RANGE)

	local Clone = BeamAsset:Clone()
	Clone.Parent = workspace
	Clone.CFrame = (HumRP.CFrame + Vector3.new(RandomX, 70, RandomZ)) * CFrame.Angles(math.rad(90), 0, 0)

	FadeOut.In(Clone, FADE_IN_TIME, function()
		ParticlesModule.Emit(Clone)
	end)

	task.delay(WAIT_TIME, function()
		if Clone and Clone.Parent then
			FadeOut.OutAndDestroy(Clone, FADE_OUT_TIME)
		end
	end)
end
