local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Shared.Constants)

local ParticlesModule = Constants.ParticlesModule

local ShadestepAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Lunar.Shadestep

local activeData = {}

local Handlers = {}

function Handlers.Startup(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local HumRP = char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local key = tostring(char)

	if activeData[key] and activeData[key].startup and activeData[key].startup.Parent then
		activeData[key].startup:Destroy()
	end

	if not activeData[key] then
		activeData[key] = {}
	end

	local startupClone = ShadestepAssets.Startup:Clone()
	startupClone.Parent = workspace
	startupClone:PivotTo(HumRP.CFrame * CFrame.Angles(0, math.rad(180), 0))

	activeData[key].startup = startupClone
end

function Handlers.DestroyStartup(params)
	local char = params.char
	if not char then
		return
	end

	local key = tostring(char)
	local data = activeData[key]
	if not data then
		return
	end

	if data.startup and data.startup.Parent then
		data.startup:Destroy()
		data.startup = nil
	end
end

function Handlers.ChargeEffect(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local HumRP = char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local key = tostring(char)
	if not activeData[key] then
		activeData[key] = {}
	end

	local chargePart = ShadestepAssets.ChargePart:Clone()
	chargePart.Parent = workspace
	chargePart.CFrame = HumRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), 0, 0)
	ParticlesModule.Emit(chargePart)

	activeData[key].chargePart = chargePart
end

function Handlers.FireBeam(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local HumRP = char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local key = tostring(char)
	if not activeData[key] then
		activeData[key] = {}
	end

	local beamModel = ShadestepAssets.Beam:Clone()
	beamModel.Parent = workspace
	beamModel:PivotTo(HumRP.CFrame * CFrame.new(0, 0, -6))

	local START_Z = -6
	local END_Z = -90
	local DURATION = 0.2
	local startTime = os.clock()

	local conn = RunService.Heartbeat:Connect(function()
		if not beamModel or not beamModel.Parent then
			return
		end
		if not HumRP or not HumRP.Parent then
			return
		end
		local t = math.clamp((os.clock() - startTime) / DURATION, 0, 1)
		beamModel:PivotTo(HumRP.CFrame * CFrame.new(0, 0, START_Z + (END_Z - START_Z) * t))
	end)

	task.delay(DURATION, function()
		conn:Disconnect()
	end)

	task.delay(0.4, function()
		if beamModel and beamModel.Parent then
			beamModel:Destroy()
		end
		local data = activeData[key]
		if data then
			if data.chargePart and data.chargePart.Parent then
				data.chargePart:Destroy()
				data.chargePart = nil
			end
			activeData[key] = nil
		end
	end)
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
