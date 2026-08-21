local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local TS = Constants.TS
local CharacterAssets = Constants.CharacterAssets
local ParticlesModule = Constants.ParticlesModule
local GroundCrater = require(script.Parent["Ground Crater"])
local IslandExplosion = require(script.Parent.IslandExplosion)

local BURY_DISTANCE = 50
local RISE_DISTANCE = 10
local RISE_TIME = 1
local FADE_TIME = 0.4
local HEIGHT_OFFSET = -10

local ACTIVE = {}

local function getKey(Character)
	return tostring(Character)
end

local function tagNoDebris(Clone)
	for _, part in Clone:GetDescendants() do
		if part:IsA("BasePart") then
			part:SetAttribute("NoDebris", true)
		end
	end
end

local function riseSpikes(Clone, startCFrame, restCFrame)
	local driver = Instance.new("CFrameValue")
	driver.Value = startCFrame
	driver.Parent = Clone

	local conn
	conn = driver:GetPropertyChangedSignal("Value"):Connect(function()
		Clone:PivotTo(driver.Value)
	end)

	local tween = TS:Create(
		driver,
		TweenInfo.new(RISE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Value = restCFrame }
	)

	tween.Completed:Once(function()
		conn:Disconnect()
		if driver and driver.Parent then
			driver:Destroy()
		end
	end)

	tween:Play()
end

local Handlers = {}

function Handlers.Start(Params)
	local Character = Params.char
	local Position = Params.position
	if not Character or not Position then
		return
	end

	local SpikesAsset = CharacterAssets.Eclipse.Lunar.Awaken:FindFirstChild("Spikes")
	if not SpikesAsset then
		return
	end

	local key = getKey(Character)

	local Old = ACTIVE[key]
	if Old and Old.Parent then
		Old:Destroy()
	end

	local Clone = SpikesAsset:Clone()
	tagNoDebris(Clone)

	local restCFrame = CFrame.new(Position + Vector3.new(0, HEIGHT_OFFSET, 0))
	local buriedCFrame = restCFrame * CFrame.new(0, -BURY_DISTANCE, 0)
	local riseStartCFrame = restCFrame * CFrame.new(0, -RISE_DISTANCE, 0)

	Clone:PivotTo(buriedCFrame)
	Clone.Parent = workspace

	ParticlesModule.Emit(Clone)

	Clone:PivotTo(riseStartCFrame)

	riseSpikes(Clone, riseStartCFrame, restCFrame)

	ACTIVE[key] = Clone
end

function Handlers.Slam(Params)
	local Character = Params.char
	local ImpactPosition = Params.position
	if not Character then
		return
	end

	local key = getKey(Character)
	local Clone = ACTIVE[key]
	ACTIVE[key] = nil

	if ImpactPosition then
		IslandExplosion({ position = ImpactPosition })

		GroundCrater({
			Seed = math.random(1, 2147483647),
			amount = 60,
			start = ImpactPosition + Vector3.new(0, 1, 0),
			["end"] = Vector3.new(0, -20, 0),
			size = 2.8,
			rings = 3,
			ringSpacing = 18,
			ringSizeGrowth = 1.8,
			ringGap = 0.22,
			outwardTilt = true,
			debrisSizeMin = 7,
			debrisSizeMax = 18,
			debrisHeightMin = 4,
			debrisHeightMax = 9,
			sizemult = 1.6,
		})
	end

	if Clone and Clone.Parent then
		local tweens = {}

		for _, part in Clone:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(
					tweens,
					TS:Create(
						part,
						TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Transparency = 1 }
					)
				)
			end
		end

		for _, tween in tweens do
			tween:Play()
		end

		Debris:AddItem(Clone, FADE_TIME + 0.1)
	end
end

function Handlers.Stop(Params)
	local Character = Params.char
	if not Character then
		return
	end

	local key = getKey(Character)
	local Clone = ACTIVE[key]
	ACTIVE[key] = nil

	if Clone and Clone.Parent then
		Clone:Destroy()
	end
end

return function(Params)
	local Handler = Handlers[Params.func or "Start"]
	if Handler then
		Handler(Params)
	end
end
