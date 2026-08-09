local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TS = game:GetService("TweenService")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

export type KnockbackData = {
	Velocity: Vector3?,
	Position: Vector3?,
	MaxForce: Vector3?,
	KnockbackType: string?,
	P: number?,
	D: number?,
	Time: number?,
	Style: string?,
	Direction: string?,
	Inverse: boolean?,
	ApplyAngular: boolean?,
	Owner: Player?,
}

local BMS = {}

local function TakeNetworkOwnership(RootPart: BasePart): Player?
	local OriginalOwner: Player? = nil

	local Ok, CurrentOwner = pcall(function()
		return RootPart:GetNetworkOwner()
	end)

	if Ok then
		OriginalOwner = CurrentOwner
	end

	pcall(function()
		if RootPart:CanSetNetworkOwnership() then
			RootPart:SetNetworkOwner(nil)
		end
	end)

	return OriginalOwner
end

local function RestoreNetworkOwnership(Character: Model, OriginalOwner: Player?)
	if not Character or not Character.Parent then
		return
	end

	if Character:HasTag("Ragdolled") or Character:FindFirstChild("Ragdoll") then
		return
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart or not RootPart.Parent then
		return
	end

	pcall(function()
		if RootPart:CanSetNetworkOwnership() then
			RootPart:SetNetworkOwner(OriginalOwner)
		end
	end)
end

function BMS:Knockback(Character: Model, Data: KnockbackData): BodyMover?
	if not Data.Velocity and not Data.Position then
		return nil
	end

	Data.MaxForce = Data.MaxForce or Vector3.new(math.huge, math.huge, math.huge)

	RemoteManager.FireAllClients("ReplicateTask", "RemoveAllBodyMovers", Character)
	for _, BodyMover in Character:GetDescendants() do
		if BodyMover:IsA("BodyVelocity") or BodyMover:IsA("LinearVelocity") or BodyMover:IsA("BodyPosition") then
			BodyMover:Destroy()
		end
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local OriginalOwner: Player? = nil

	if RootPart then
		local Player = Data.Owner or Players:GetPlayerFromCharacter(Character)
		OriginalOwner = Player
		TakeNetworkOwnership(RootPart)
	end

	local Bodymover: BodyMover

	if Data.KnockbackType == "Velocity" or not Data.KnockbackType then
		local Velocity = Instance.new("BodyVelocity")
		Velocity.MaxForce = Data.MaxForce
		Velocity.Velocity = Data.Velocity :: Vector3
		if Data.P then
			Velocity.P = Data.P
		end
		if Data.D then
			Velocity.D = Data.D
		end
		Bodymover = Velocity
	elseif Data.KnockbackType == "Position" then
		local Position = Instance.new("BodyPosition")
		Position.MaxForce = Data.MaxForce
		Position.Position = Data.Position :: Vector3
		if Data.P then
			Position.P = Data.P
		end
		if Data.D then
			Position.D = Data.D
		end
		Bodymover = Position
	elseif Data.KnockbackType == "Linear" then
		local Linear = Instance.new("LinearVelocity")
		Linear.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		Linear.MaxAxesForce = Data.MaxForce
		Linear.VectorVelocity = Data.Velocity :: Vector3
		if Data.P then
			Linear.P = Data.P
		end
		if Data.D then
			Linear.D = Data.D
		end
		Linear.Attachment0 = (Character.HumanoidRootPart :: BasePart).RootAttachment
		Bodymover = Linear
	elseif Data.KnockbackType == "VelocityTweenDown" then
		local Velocity = Instance.new("BodyVelocity")
		Velocity.MaxForce = Data.MaxForce
		if Data.P then
			Velocity.P = Data.P
		end
		if Data.D then
			Velocity.D = Data.D
		end

		local EasingStyle = Enum.EasingStyle[Data.Style or "Sine"]
		local EasingDirection = Enum.EasingDirection[Data.Direction or "Out"]

		if Data.Inverse == true then
			Velocity.Velocity = Vector3.zero
			TS
				:Create(
					Velocity,
					TweenInfo.new(Data.Time or 0, EasingStyle, EasingDirection),
					{ Velocity = Data.Velocity }
				)
				:Play()
		else
			Velocity.Velocity = Data.Velocity :: Vector3
			TS
				:Create(
					Velocity,
					TweenInfo.new(Data.Time or 0, EasingStyle, EasingDirection),
					{ Velocity = Vector3.zero }
				)
				:Play()
		end

		Bodymover = Velocity
	else
		if RootPart then
			RestoreNetworkOwnership(Character, OriginalOwner)
		end
		return nil
	end

	if Character:FindFirstChild("Humanoid") then
		Bodymover.Parent = Character.HumanoidRootPart
	else
		Bodymover.Parent = Character

		if typeof(Data.Owner) == "Instance" and Data.Owner:IsA("Player") then
			Character:SetNetworkOwner(Data.Owner)
		end
	end

	if Data.ApplyAngular then
		local BasePart = (Character:FindFirstChild("HumanoidRootPart") or Character) :: BasePart
		BasePart.AssemblyAngularVelocity =
			Vector3.new(math.random(-270, 270), math.random(-270, 270), math.random(-270, 270))
	end

	local Duration = Data.Time or 0.1
	Debris:AddItem(Bodymover, Duration)

	if RootPart then
		task.delay(Duration, function()
			RestoreNetworkOwnership(Character, OriginalOwner)
		end)
	end

	return Bodymover
end

function BMS:makeEnemyFaceCharacter(Enemy: Model, Character: Model, To: boolean?)
	local EnemyRoot = Enemy.HumanoidRootPart :: BasePart
	local CharacterRoot = Character.HumanoidRootPart :: BasePart

	if To == true then
		EnemyRoot.CFrame = CFrame.lookAt(EnemyRoot.Position, CharacterRoot.Position)
	else
		EnemyRoot.CFrame = CFrame.lookAlong(EnemyRoot.Position, CharacterRoot.CFrame.LookVector)
			* CFrame.Angles(0, math.pi, 0)
	end
end

return BMS
