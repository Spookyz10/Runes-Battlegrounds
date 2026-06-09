--// SERVICES
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// MODULES
local Shared = ReplicatedStorage.Shared.Modules.Shared

local Rocks = require(Shared.Rocks)
local Utility = require(Shared.Utility)
local PartCache = require(Shared.PartCache)
local CameraShaker = require(Shared.CameraShaker)
local LightningBolt = require(Shared.LightningBolt)
local LightningSparks = require(Shared.LightningBolt.LightningSparks)
local AnimationController = require(Shared.AnimationController)

--// ASSETS
local Signal = ReplicatedStorage.Remotes.Signal

local AssetsFolder = ReplicatedStorage.Assets
local Visuals = AssetsFolder.Visuals.Madara
local Animations = AssetsFolder.Animations

local IgnoreFolder = workspace.Ignore.Visuals
local AliveFolder = workspace.World.Alive
local Map = workspace.World.Map:WaitForChild("Floor") -- :sob:

local Controls = require(Players.LocalPlayer.PlayerScripts.PlayerModule):GetControls()

local Parameters = RaycastParams.new()
Parameters.FilterType = Enum.RaycastFilterType.Include
Parameters.FilterDescendantsInstances = {Map}

local Madara = {}

local function ColorCorrection()
	local ColorCorrection = Instance.new('ColorCorrectionEffect')
	ColorCorrection.Saturation = -1
	ColorCorrection.Contrast = -3
	ColorCorrection.Parent = game:GetService('Lighting')

	task.delay(0.04, function()
		ColorCorrection.Saturation = -1
		ColorCorrection.Contrast = 3

		task.wait(0.02)
		ColorCorrection:Destroy()
	end)
end

local function AlignToGround(CF)
	local X, Y, Z = CF:ToOrientation()
	return CFrame.new(CF.Position) * CFrame.Angles(0, Y, 0) 
end

--// SKILL 1
function Madara.Tornado(Player)
	local Character: Model = Player.Character
	local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then return end

	Controls:Disable()

	local TornadoVisuals = Visuals.Tornado:Clone()
	TornadoVisuals.Parent = IgnoreFolder
	TornadoVisuals.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 3, -5)

	Utility.EnableEmitting(TornadoVisuals)
	
	Signal:FireServer("Madara", "Tornado", Player, TornadoVisuals.CFrame)
	
	local TornadoShaker = CameraShaker.new(14, 19, .4, .25)
	TornadoShaker:Once("Tornado")

	local function DisappearTween()
		local Tween = TweenService:Create(TornadoVisuals, TweenInfo.new(.5), {Transparency = 1})
		Tween:Play()
		Tween.Completed:Connect(function()
			Tween:Destroy()
			TornadoVisuals:Destroy()
		end)
	end

	local RotationSpeed = math.random(-5,5)
	local MoveSpeed = 15 
	local TimeAlive = 0
	local Duration = 3 

	local HeartbeatConnection 

	local function OnHeartbeat(DeltaTime)
		TimeAlive = TimeAlive + DeltaTime

		TornadoVisuals.CFrame = TornadoVisuals.CFrame * CFrame.Angles(0, math.rad(RotationSpeed * DeltaTime), 0)
		TornadoVisuals.CFrame = TornadoVisuals.CFrame * CFrame.new(0, 0, -MoveSpeed * DeltaTime)

		if TimeAlive >= Duration then
			DisappearTween()

			Utility.DisableEmitting(TornadoVisuals)
			HeartbeatConnection:Disconnect() 

			Controls:Enable()
		end
	end

	HeartbeatConnection = RunService.Heartbeat:Connect(OnHeartbeat) 
end

--// SKILL 2
function Madara.Breath(Player)
	local Character: Model = Player.Character
	local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
	local Humanoid: Humanoid = Character and Character:FindFirstChild("Humanoid")

	if not HumanoidRootPart or not Humanoid then return end

	Controls:Disable()
	Humanoid.AutoRotate = false

	local function EnableVisuals(Visual, Parent, CFrame)
		local ClonedVisuals = Visual:Clone()
		ClonedVisuals.Parent = Parent
		ClonedVisuals.CFrame = CFrame
		Utility.EnableEmitting(ClonedVisuals)
		return ClonedVisuals
	end

	local FireVisuals = EnableVisuals(Visuals.FireBreath, IgnoreFolder, HumanoidRootPart.CFrame * CFrame.new(0, 3, -6))

	local GroundCFrame = AlignToGround(HumanoidRootPart.CFrame * CFrame.new(0, -2.9, -35))
	local GroundVisuals = EnableVisuals(Visuals.Ground, IgnoreFolder, GroundCFrame)
	
	local BreathShaker = CameraShaker.new(14, 19, .4, .25)
	BreathShaker:Once("Breath")

	task.delay(2, function()
		Utility.Emit(GroundVisuals)

		task.wait(2)  
		Utility.DisableEmitting(FireVisuals)

		Controls:Enable()
		Humanoid.AutoRotate = true
	end)
end

--// SKILL 3
function Madara.Strike(Player, MousePosition)
	local Character: Model = Player.Character
	local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
	
	if not HumanoidRootPart then return end

	Controls:Disable()
	task.delay(1, function() Controls:Enable() end)

	local function CreateLightning(Origin, TargetPosition)
		local Point0 = Instance.new("Part")
		Point0.Parent = IgnoreFolder
		Point0.Anchored = true
		Point0.CanCollide = false
		Point0.Transparency = 1

		local Attachment0 = Instance.new("Attachment")
		Attachment0.Parent = Point0

		local Point1 = Instance.new("Part")
		Point1.Parent = IgnoreFolder
		Point1.Anchored = true
		Point1.CanCollide = false
		Point1.Transparency = 1

		local Attachment1 = Instance.new("Attachment")
		Attachment1.Parent = Point1

		Point0.Position = Origin
		Point1.Position = TargetPosition

		local Lightning = LightningBolt.new(Attachment0, Attachment1, 50)
		Lightning.MinRadius = 1
		Lightning.MaxRadius = 4
		Lightning.AnimationSpeed = 4
		Lightning.FadeLength = 0.5
		Lightning.PulseLength = 2.5
		Lightning.Thickness = 2
		Lightning.MinTransparency, Lightning.MaxTransparency = 0, 1
		Lightning.ContractFrom = 3
		Lightning.PulseSpeed = math.random(8, 15)
		Lightning.MinThicknessMultiplier, Lightning.MaxThicknessMultiplier = 0.5, 1.5
		Lightning.Color = ColorSequence.new(Color3.fromRGB(116, 88, 255), Color3.fromRGB(123, 79, 255))

		LightningSparks.new(Lightning)
	end

	for i = 1, 3 do
		local MouseCFrame = CFrame.new(MousePosition) * CFrame.new(i * 1, 1, i * 1)
		local Ray = Ray.new(MouseCFrame.Position, Vector3.new(0, -50, 0))
		local Hit, VectorPosition, SurfaceNormal = workspace:FindPartOnRayWithIgnoreList(Ray, {Character, IgnoreFolder})

		if Hit then
			local TargetCFrame = CFrame.new(VectorPosition, VectorPosition + SurfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)
			local OriginPosition = (TargetCFrame * CFrame.new(0, 70, 0)).Position
			CreateLightning(OriginPosition, TargetCFrame.Position)
		end
	end

	local StrikeVisuals = Visuals.LightningStrike:Clone()
	StrikeVisuals.CFrame = AlignToGround(CFrame.new(MousePosition))
	StrikeVisuals.Parent = IgnoreFolder

	task.spawn(function()
		Utility.Emit(StrikeVisuals)
	
		local StrikeShaker = CameraShaker.new(20, 30, 0.35, 0.3)
		StrikeShaker:Once("Strike")
		
		local Rock = Rocks.Ground(StrikeVisuals.Position, 20, Vector3.one * 3, false, 8, false, 3)

		task.spawn(function() -- Busy so I took some os script...
			for i = 1, math.random(4,8) do
				local Velocity = 35

				local bits = ReplicatedStorage.Assets.Visuals.Madara.FlyingRocks:Clone()
				bits.Parent = IgnoreFolder
				bits.CFrame = StrikeVisuals.CFrame
				bits.Size = Vector3.one * 1.5
				bits.Material = Enum.Material.Concrete
				bits.Color = Color3.new(0.258824, 0.258824, 0.258824)
				bits.A0.WorldCFrame = bits.CFrame * CFrame.new(-bits.Size.X * 0.5, 0, 0)
				bits.A1.WorldCFrame = bits.CFrame * CFrame.new(bits.Size.X * 0.5, 0, 0)

				for _, particle in pairs(bits:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle.Enabled = false
					end
				end

				local vel = Instance.new("BodyVelocity", bits)
				vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				vel.Velocity = bits.CFrame.LookVector * math.random(-Velocity,Velocity) * 2 + Vector3.new(math.random(-Velocity,Velocity),math.random(0,Velocity),math.random(-Velocity,Velocity))

				delay(0.25, function()
					bits.CanCollide = true
					vel:Destroy()
					bits:FindFirstChildWhichIsA("Trail"):Destroy()
				end)

				delay(3, function()
					for _, particle in pairs(bits:GetDescendants()) do
						if particle:IsA("ParticleEmitter") then
							particle.Rate = 0
						end
					end
					TweenService:Create(bits, TweenInfo.new(0.5), {Size = Vector3.new(0, 0, 0)}):Play()
					Debris:AddItem(bits, 1)
				end)
				task.wait()
			end
		end)
	end)
end

--// SKILL 4
function Madara.Meteor(Player, MousePosition)
	local Character: Model = Player.Character
	local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
	
	if not HumanoidRootPart then return end
	
	Controls:Disable()
	task.delay(1, function() Controls:Enable() end)

	local MeteorVisuals = Visuals.Meteor:Clone()
	MeteorVisuals.Parent = IgnoreFolder
	MeteorVisuals.CFrame = CFrame.new(MousePosition) * CFrame.new(math.random(-360, 360), math.random(350, 500), math.random(-360, 360))

	local function CreateTween(Instance, TweenInfo, Goal)
		local Tween = TweenService:Create(Instance, TweenInfo, Goal)
		Tween:Play()
		return Tween
	end

	local TweenMove = CreateTween(MeteorVisuals, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {CFrame = CFrame.new(MousePosition)})
	TweenMove.Completed:Wait()

	CreateTween(MeteorVisuals, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1})
	CreateTween(MeteorVisuals.Outer, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1})

	Utility.DisableEmitting(MeteorVisuals, false)

	local Result = workspace:Raycast(MeteorVisuals.Position, MeteorVisuals.CFrame.UpVector * -30, Parameters)

	local ExplosionVisuals = Visuals.MeteorExplosion:Clone()
	ExplosionVisuals.Parent = IgnoreFolder
	ExplosionVisuals.Position = Result and Result.Position or MeteorVisuals.Position + Vector3.new(0, 5.5, 0)

	Utility.Emit(ExplosionVisuals)

	ColorCorrection()
	local Rock = Rocks.Ground(ExplosionVisuals.Position, 40, Vector3.one * 8, false, 14, false, 3)

	local ExplosionShaker = CameraShaker.new(14, 19, 1, 0.5)
	ExplosionShaker:Once("Explosion")
	
	task.spawn(function() -- Busy so I took some os script...
		for i = 1, math.random(4,8) do
			local Velocity = 85

			local bits = ReplicatedStorage.Assets.Visuals.Madara.FlyingRocks:Clone()
			bits.Parent = IgnoreFolder
			bits.CFrame = ExplosionVisuals.CFrame
			bits.Size = Vector3.new(math.random(2,6), math.random(2,6), math.random(2, 6))
			bits.Material = Enum.Material.Concrete
			bits.Color = Color3.new(0.258824, 0.258824, 0.258824)
			bits.A0.WorldCFrame = bits.CFrame * CFrame.new(-bits.Size.X * 0.5, 0, 0)
			bits.A1.WorldCFrame = bits.CFrame * CFrame.new(bits.Size.X * 0.5, 0, 0)

			for _, particle in pairs(bits:GetDescendants()) do
				if particle:IsA("ParticleEmitter") then
					particle.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, bits.Size.X)
					})
				end
			end

			local vel = Instance.new("BodyVelocity", bits)
			vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			vel.Velocity = bits.CFrame.LookVector * math.random(-Velocity,Velocity) * 2 + Vector3.new(math.random(-Velocity,Velocity),math.random(0,Velocity),math.random(-Velocity,Velocity))

			delay(0.25, function()
				bits.CanCollide = true
				vel:Destroy()
				bits:FindFirstChildWhichIsA("Trail"):Destroy()
			end)

			delay(3, function()
				for _, particle in pairs(bits:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle.Rate = 0
					end
				end
				TweenService:Create(bits, TweenInfo.new(0.5), {Size = Vector3.new(0, 0, 0)}):Play()
				Debris:AddItem(bits, 1)
			end)
			task.wait(.1)
		end
	end)
end

return Madara
