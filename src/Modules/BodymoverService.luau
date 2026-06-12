local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TS = game:GetService("TweenService")

local BMS = {}

function BMS:Knockback(Character, Data)
	if not Data.Velocity and not Data.Position then
		return
	end

	local Bodymover

	Data.MaxForce = Data.MaxForce or Vector3.new(math.huge, math.huge, math.huge)

	if not Character:HasTag("Ragdolled") then
		ReplicatedStorage.Remotes.Replicate.Set:FireAllClients("RemoveAllBodyMovers", Character)
		for _, BodyMover: BodyVelocity in Character:GetDescendants() do
			if BodyMover:IsA("BodyVelocity") or BodyMover:IsA("LinearVelocity") or BodyMover:IsA("BodyPosition") then
				BodyMover:Destroy()
			end
		end
	end

	if Data.KnockbackType == "Velocity" or not Data.KnockbackType then
		Bodymover = Instance.new("BodyVelocity")
		Bodymover.MaxForce = Data.MaxForce
		Bodymover.Velocity = Data.Velocity
		if Data.P then
			Bodymover.P = Data.P
		end
		if Data.D then
			Bodymover.D = Data.D
		end
	elseif Data.KnockbackType == "Position" then
		Bodymover = Instance.new("BodyPosition")
		Bodymover.MaxForce = Data.MaxForce
		Bodymover.Position = Data.Position
		if Data.P then
			Bodymover.P = Data.P
		end
		if Data.D then
			Bodymover.D = Data.D
		end
	elseif Data.KnockbackType == "Linear" then
		Bodymover = Instance.new("LinearVelocity")
		Bodymover.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		Bodymover.MaxAxesForce = Data.MaxForce
		Bodymover.VectorVelocity = Data.Velocity
		if Data.P then
			Bodymover.P = Data.P
		end
		if Data.D then
			Bodymover.D = Data.D
		end
		Bodymover.Attachment0 = Character.HumanoidRootPart.RootAttachment
	elseif Data.KnockbackType == "VelocityTweenDown" then
		Bodymover = Instance.new("BodyVelocity")
		Bodymover.MaxForce = Data.MaxForce
		if Data.P then
			Bodymover.P = Data.P
		end
		if Data.D then
			Bodymover.D = Data.D
		end

		local easingStyle = Enum.EasingStyle[Data.Style or "Sine"]
		local easingDirection = Enum.EasingDirection[Data.Direction or "Out"]

		if Data.Inverse == true then
			Bodymover.Velocity = Vector3.zero

			TS:Create(Bodymover, TweenInfo.new(Data.Time, easingStyle, easingDirection), { Velocity = Data.Velocity })
				:Play()
		else
			Bodymover.Velocity = Data.Velocity
			TS:Create(Bodymover, TweenInfo.new(Data.Time, easingStyle, easingDirection), { Velocity = Vector3.zero })
				:Play()
		end
	end

	if Character:FindFirstChild("Humanoid") then
		Bodymover.Parent = Character.HumanoidRootPart
	else
		Bodymover.Parent = Character

		if typeof(Data.Owner) == "Player" then
			Character:SetNetworkOwner(Data.Owner)
		end
	end

	if Data.ApplyAngular then
		local BasePart: BasePart = Character:FindFirstChild("HumanoidRootPart") or Character
		if BasePart:IsA("BasePart") then
			BasePart.AssemblyAngularVelocity =
				Vector3.new(math.random(-270, 270), math.random(-270, 270), math.random(-270, 270))
		end
	end

	if Data.Time then
		Debris:AddItem(Bodymover, Data.Time)
	else
		Debris:AddItem(Bodymover, 0.1)
	end

	return Bodymover
end

function BMS:makeEnemyFaceCharacter(Enemy, Character, to)
	if to == true then
		Enemy.HumanoidRootPart.CFrame =
			CFrame.lookAt(Enemy.HumanoidRootPart.Position, Character.HumanoidRootPart.Position)
	else
		Enemy.HumanoidRootPart.CFrame = CFrame.lookAlong(
			Enemy.HumanoidRootPart.Position,
			Character.HumanoidRootPart.CFrame.LookVector
		) * CFrame.Angles(0, math.pi, 0)
	end
end

return BMS
