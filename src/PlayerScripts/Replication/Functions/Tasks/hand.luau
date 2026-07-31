local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)
local Particles = require(ReplicatedStorage.Shared.Modules.Utility.Particles)

local DEFAULT_START_DIST = 3
local DEFAULT_END_DIST = 30
local FADE_DURATION = 0.35

local function animateToCFrame(instance, startCFrame, endCFrame, tweenInfo)
	if instance:IsA("Model") then
		instance:PivotTo(startCFrame)

		local driver = Instance.new("CFrameValue")
		driver.Value = startCFrame
		driver.Parent = instance

		local conn
		conn = driver:GetPropertyChangedSignal("Value"):Connect(function()
			instance:PivotTo(driver.Value)
		end)

		local tween = TweenService:Create(driver, tweenInfo, { Value = endCFrame })
		tween.Completed:Once(function()
			conn:Disconnect()
			if driver and driver.Parent then
				driver:Destroy()
			end
		end)
		tween:Play()

		return tween
	else
		instance.CFrame = startCFrame

		local tween = TweenService:Create(instance, tweenInfo, { CFrame = endCFrame })
		tween:Play()

		return tween
	end
end

return function(Params)
	local Position = Params.position
	local Direction = Params.direction
	if not Position or not Direction then
		return
	end

	local EndDist = Params.endDist or DEFAULT_END_DIST

	local Assets = CharacterAssets.Eclipse.Lunar
	local HandAsset = Assets:FindFirstChild("Hand")
	local VFXAsset = Assets:FindFirstChild("HandVFX")

	local StartCFrame = (Params.char.HumanoidRootPart.CFrame + Vector3.new(0, -2, -12))
		* CFrame.Angles(0, math.rad(180), 0)
	local ModelEndDist = EndDist * 2
	local ModelEndCFrame = CFrame.new(
		Position + Direction * ModelEndDist,
		Position + Direction * ModelEndDist + Direction
	) * CFrame.Angles(0, math.rad(180), 0)

	local Clone = HandAsset:Clone()
	Clone.Parent = workspace

	local VFXClone = VFXAsset:Clone()
	VFXClone.Parent = workspace
	VFXClone.CFrame = Params.char.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)

	Particles.Emit(VFXClone)

	local TweenInf = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local tween = animateToCFrame(Clone, StartCFrame, ModelEndCFrame, TweenInf)
	tween.Completed:Wait()
	FadeOut.OutAndDestroy(Clone, FADE_DURATION)
	Debris:AddItem(VFXClone, 1)
end
