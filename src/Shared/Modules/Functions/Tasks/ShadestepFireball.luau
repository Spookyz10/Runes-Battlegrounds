local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Shared.Constants)
local ParticlesModule = Constants.ParticlesModule
local Debris = Constants.Debris

local ShadestepAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Lunar.Shadestep

local HAND_OFFSET = CFrame.new(-1, -0.5, -1)
local TRAVEL_DISTANCE = 70
local TRAVEL_TIME = 0.5

local activeData = {}

local Handlers = {}

function Handlers.Attach(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local LeftArm = char:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end

	local key = tostring(char)

	if activeData[key] and activeData[key].fireball and activeData[key].fireball.Parent then
		activeData[key].fireball:Destroy()
	end

	local Fireball = ShadestepAssets.Fireball:Clone()
	Fireball.Anchored = false
	Fireball.CanCollide = false
	Fireball.CanTouch = false
	Fireball.CanQuery = false
	Fireball.CFrame = LeftArm.CFrame * HAND_OFFSET

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = LeftArm
	Weld.Part1 = Fireball
	Weld.Parent = Fireball

	Fireball.Parent = LeftArm

	ParticlesModule.Emit(Fireball)

	activeData[key] = { fireball = Fireball }
end

function Handlers.Launch(params)
	local char = params.char
	local direction = params.direction
	if not char or not direction then
		return
	end

	local key = tostring(char)
	local data = activeData[key]
	if not data or not data.fireball or not data.fireball.Parent then
		return
	end

	local Fireball = data.fireball
	activeData[key] = nil

	local startCFrame = Fireball.CFrame

	for _, child in Fireball:GetChildren() do
		if child:IsA("WeldConstraint") then
			child:Destroy()
		end
	end

	Fireball.Anchored = true
	Fireball.Parent = workspace.Debris
	Fireball.CFrame = startCFrame

	local startTime = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not Fireball or not Fireball.Parent then
			if conn then
				conn:Disconnect()
			end
			return
		end

		local t = math.clamp((os.clock() - startTime) / TRAVEL_TIME, 0, 1)
		Fireball.CFrame = startCFrame + direction * (TRAVEL_DISTANCE * t)

		if t >= 1 then
			conn:Disconnect()
		end
	end)

	Debris:AddItem(Fireball, TRAVEL_TIME + 0.1)
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
