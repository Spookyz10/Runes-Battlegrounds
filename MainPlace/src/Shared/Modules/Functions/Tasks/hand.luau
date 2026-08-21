local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)
local Particles = require(ReplicatedStorage.Shared.Modules.Utility.Particles)

local DEFAULT_START_DIST = 12
local DEFAULT_END_DIST = 30
local CIRCLE_FORWARD_OFFSET = 3
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

	local StartDist = Params.startDist or DEFAULT_START_DIST
	local EndDist = Params.endDist or DEFAULT_END_DIST

	local Assets = CharacterAssets.Eclipse.Lunar
	local HandAsset = Assets:FindFirstChild("Hand")
	local VFXAsset = Assets:FindFirstChild("HandVFX")

	local FlatDirection = Vector3.new(Direction.X, 0, Direction.Z)
	if FlatDirection.Magnitude < 0.001 then
		FlatDirection = Vector3.new(0, 0, -1)
	else
		FlatDirection = FlatDirection.Unit
	end

	local ModelStartDist = StartDist * 2
	local ModelEndDist = EndDist * 2

	local StartPos = Position - FlatDirection * ModelStartDist
	local EndPos = Position + FlatDirection * ModelEndDist

	local StartCFrame = CFrame.lookAt(StartPos, StartPos + FlatDirection) * CFrame.Angles(0, math.rad(180), 0)
	local ModelEndCFrame = CFrame.lookAt(EndPos, EndPos + FlatDirection) * CFrame.Angles(0, math.rad(180), 0)

	local Clone = HandAsset:Clone()
	Clone.Parent = workspace

	local VFXClone = VFXAsset:Clone()
	VFXClone.Parent = workspace
	VFXClone.CFrame = CFrame.lookAt(Position, Position + FlatDirection) * CFrame.new(0, 0, -CIRCLE_FORWARD_OFFSET)

	Particles.Emit(VFXClone)

	local TweenInf = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local tween = animateToCFrame(Clone, StartCFrame, ModelEndCFrame, TweenInf)
	tween.Completed:Wait()
	FadeOut.OutAndDestroy(Clone, FADE_DURATION)
	Debris:AddItem(VFXClone, 1)
end
