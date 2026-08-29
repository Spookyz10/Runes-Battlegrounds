local Constants = require(script.Parent.Shared.Constants)
local TS = Constants.TS
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local RISE_HEIGHT = 100
local RISE_TIME = 0.4

local ACTIVE = {}

local function getKey(char)
	return tostring(char)
end

local Handlers = {}

function Handlers.Start(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local key = getKey(Character)

	local Old = ACTIVE[key]
	if Old then
		for _, Weld in Old.Victims do
			if Weld and Weld.Parent then
				Weld:Destroy()
			end
		end
		if Old.Island and Old.Island.Parent then
			Old.Island:Destroy()
		end
		ACTIVE[key] = nil
	end

	local IslandAsset = CharacterAssets.Shattered.Island
	local Island = IslandAsset:Clone()

	local startCFrame = CFrame.new(HumRP.Position - Vector3.new(0, 5, 0))
	Island:PivotTo(startCFrame)
	Island.Parent = workspace

	ParticlesModule.Emit(Island)

	local endCFrame = startCFrame * CFrame.new(0, RISE_HEIGHT, 0)

	local driver = Instance.new("CFrameValue")
	driver.Value = startCFrame
	driver.Parent = Island

	local conn
	conn = driver:GetPropertyChangedSignal("Value"):Connect(function()
		if Island and Island.Parent then
			Island:PivotTo(driver.Value)
		end
	end)

	local tween = TS:Create(
		driver,
		TweenInfo.new(RISE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Value = endCFrame }
	)

	tween.Completed:Once(function()
		conn:Disconnect()
		if driver and driver.Parent then
			driver:Destroy()
		end
	end)

	tween:Play()

	ACTIVE[key] = { Island = Island, Victims = {} }
end

function Handlers.AddVictim(Params)
	local Character = Params.char
	local Victim = Params.victim
	if not Character or not Victim then
		return
	end

	local key = getKey(Character)
	local Data = ACTIVE[key]
	if not Data or not Data.Island or not Data.Island.Parent then
		return
	end

	local VictimHumRP = Victim:FindFirstChild("HumanoidRootPart")
	local IslandPrimary = Data.Island.PrimaryPart
	if not VictimHumRP or not IslandPrimary then
		return
	end

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = IslandPrimary
	Weld.Part1 = VictimHumRP
	Weld.Parent = VictimHumRP

	Data.Victims[Victim] = Weld
end

function Handlers.Hit(Params)
	local Character = Params.char
	if not Character then
		return
	end

	local key = getKey(Character)
	local Data = ACTIVE[key]
	if not Data then
		return
	end

	ACTIVE[key] = nil

	for _, Weld in Data.Victims do
		if Weld and Weld.Parent then
			Weld:Destroy()
		end
	end

	if Data.Island and Data.Island.Parent then
		Data.Island:Destroy()
	end
end

return function(Params)
	local Handler = Handlers[Params.func or "Start"]
	if Handler then
		Handler(Params)
	end
end
