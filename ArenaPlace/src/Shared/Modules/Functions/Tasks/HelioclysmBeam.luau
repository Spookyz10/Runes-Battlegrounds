local Constants = require(script.Parent.Shared.Constants)

local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local RANDOM_RANGE = 20
local WAIT_TIME = 0.7
local GROW_TIME = 0.3
local FADE_OUT_TIME = 0.3

local START_SIZE = Vector3.new(22.415, 27.247, 10)
local GOAL_SIZE = Vector3.new(22.415, 27.247, 111.924)

local BASE_HEIGHT = 70 + (GOAL_SIZE.Z / 2)

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

	local BaseX = HumRP.Position.X + RandomX
	local BaseZ = HumRP.Position.Z + RandomZ

	local function CFrameForHeight(SizeZ)
		return CFrame.new(BaseX, BASE_HEIGHT + (SizeZ / 2), BaseZ) * CFrame.Angles(math.rad(90), 0, 0)
	end

	local Clone = BeamAsset:Clone()
	Clone.Size = START_SIZE
	Clone.CFrame = CFrameForHeight(START_SIZE.Z)
	Clone.Transparency = 0
	Clone.Parent = workspace

	local Connection
	Connection = Clone:GetPropertyChangedSignal("Size"):Connect(function()
		Clone.CFrame = CFrameForHeight(Clone.Size.Z)
	end)

	local GrowTween = TweenService:Create(
		Clone,
		TweenInfo.new(GROW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = GOAL_SIZE }
	)

	GrowTween.Completed:Connect(function()
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
	end)

	GrowTween:Play()
	ParticlesModule.Emit(Clone)

	task.delay(WAIT_TIME, function()
		if Clone and Clone.Parent then
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			FadeOut.OutAndDestroy(Clone, FADE_OUT_TIME)
		end
	end)
end
