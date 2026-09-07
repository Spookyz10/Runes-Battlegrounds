local SvSt = game:GetService("ServerStorage")

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AirDetectionService = require(SvSt.Modules.AirDetectionService)

local Assets = SvSt.Assets

local SvModules = SvSt.Modules
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(SvModules.StunHandler)
local AnimationService = require(SvModules.AnimationService)
local NewKnockback = require(SvModules.BodymoverService)
local HitboxHandler = require(SvModules.HitboxHandler)
local DamageHandler = require(SvModules.DamageHandler)
local iFramesService = require(SvModules.iFramesService)

local Ragdoll = {}

local ActiveKnockbackCancellers = {}

function Ragdoll.RegisterActiveKnockbackCanceller(fn)
	table.insert(ActiveKnockbackCancellers, fn)
end

local function cancelActiveKnockbacks(Character)
	for _, fn in ActiveKnockbackCancellers do
		pcall(fn, Character)
	end
end

local JointMotor6D = {
	["RootJoint"] = {
		C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0,
	},
	["Left Hip"] = {
		C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0,
	},
	["Left Shoulder"] = {
		C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0,
	},
	["Neck"] = {
		C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0,
	},
	["Right Hip"] = {
		C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0),
		C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.rad(90), 0),
		CurrentAngle = 0,
	},
	["Right Shoulder"] = {
		C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0),
		C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0),
		CurrentAngle = 0,
	},
}

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map:WaitForChild("Arena"),
	workspace.Map:WaitForChild("Miscellaneous"),
}

local DEFAULT_HARD_RAGDOLL_DAMAGE = 12
local DEFAULT_HARD_RAGDOLL_SIZE = Vector3.new(20, 20, 20)
local DEFAULT_HARD_RAGDOLL_OFFSET = CFrame.new(0, 0, 0)
local DEFAULT_HARD_RAGDOLL_KNOCKUP_FORCE = 75

local DEFAULT_GROUND_CRATERS = {
	{
		["end"] = Vector3.new(0, -24, 0),
		amount = 6,
		size = 0.3,
	},
	{
		["end"] = Vector3.new(0, -14, 0),
		amount = 6,
		sizemult = 1.35,
		size = 2,
	},
	{
		["end"] = Vector3.new(0, -14, 0),
		amount = 9,
		sizemult = 1.75,
		size = 3,
	},
}

local function setOwnershipAll(Character, Owner)
	for _, v in Character:GetDescendants() do
		if v:IsA("BasePart") then
			pcall(function()
				if v:CanSetNetworkOwnership() then
					v:SetNetworkOwner(Owner)
				end
			end)
		end
	end
end

local function fireGroundCraters(HumRP, CraterConfigs)
	local Configs = CraterConfigs or DEFAULT_GROUND_CRATERS

	for _, CraterConfig in Configs do
		local Params = table.clone(CraterConfig)
		Params.Seed = Params.Seed or math.random(1, 2000000000)
		Params.start = Params.start or (HumRP.Position + Vector3.new(0, 0.10000000149011612, 0))
		RemoteManager.FireAllClients("ReplicateTask", "Ground Crater", Params)
	end
end

function Ragdoll.cancelRagdoll(Humanoid, _, DoKnockback, MainPart, isCancel, fullCancel, ignoreComunication)
	if
		not Humanoid
		or not Humanoid.Parent
		or not Humanoid.Parent:GetAttribute("Ragdolled")
		or not Humanoid.Parent:FindFirstChild("HumanoidRootPart")
	then
		return
	end

	local Character = Humanoid.Parent
	local Player = Players:GetPlayerFromCharacter(Character)
	local HumRP = Character.HumanoidRootPart

	if fullCancel == true then
		for _, v in Character:GetChildren() do
			if v.Name == "Ragdoll" then
				v:Destroy()
			end
		end
	end

	if Character:FindFirstChild("Ragdoll") then
		return
	end

	Character:RemoveTag("Ragdolled")
	Character:SetAttribute("Ragdolled", nil)

	if isCancel == true then
		local ragdollCancel = Instance.new("BoolValue")
		ragdollCancel.Name = "RagdollCancel"
		ragdollCancel.Parent = Character
		Debris:AddItem(ragdollCancel, 2)
	end

	HumRP.CanCollide = true
	HumRP.CollisionGroup = "Players"
	HumRP.Massless = false

	Humanoid.PlatformStand = false

	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Part") then
			v.CollisionGroup = "Players"
		end
	end

	for _, v in ipairs(Character.Torso:GetChildren()) do
		if v:IsA("Motor6D") then
			if v.Part0.Name ~= "Torso" and v.Part0.Name ~= "Head" then
				v.Part0.CanCollide = true
			end

			v.Part0 = Character.Torso
			v.Enabled = true
		end
	end

	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("Part") or v:IsA("BasePart") then
			if v.Name:find("Hitbox_") then
				v.CanCollide = false
				v.Massless = true
				continue
			end

			v.CollisionGroup = "Players"

			if v.Name ~= "HumanoidRootPart" and v.Name ~= "Torso" then
				v.Massless = false
			end
		end
	end

	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if JointMotor6D[v.Name] then
				v.C0 = JointMotor6D[v.Name].C0
				v.C1 = JointMotor6D[v.Name].C1

				if JointMotor6D[v.Name]["CurrentAngle"] then
					v.CurrentAngle = JointMotor6D[v.Name]["CurrentAngle"]
				end
			end
		end
	end

	if Character:FindFirstChild("Dummy") then
		setOwnershipAll(Character, nil)
	else
		if Player then
			setOwnershipAll(Character, Player)
		end
	end

	Humanoid.PlatformStand = false

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

	if Humanoid.Health > 0 then
		Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

		if Player then
			if not ignoreComunication then
				RemoteManager.FireClient(Player, "Ragdoll", { State = false })
			end
		end
	end

	StunHandler:RemoveAllStuns(Character)

	Character:SetAttribute("Ragdolled", false)
	Character:RemoveTag("CantRotate")

	Character:AddTag("StunImmunity")
	task.delay(0.5, function()
		Character:RemoveTag("StunImmunity")
	end)

	iFramesService:AddiFrames(Character, "Base")
	task.delay(0.2, function()
		if Character and Character.Parent then
			iFramesService:RemoveiFrames(Character, "Base")
		end
	end)

	Humanoid.AutoRotate = true
	Humanoid.WalkSpeed = 16
	Humanoid.JumpPower = 50

	local RagdollGetup = Instance.new("Folder")
	RagdollGetup.Name = "RagdollGetup"
	RagdollGetup.Parent = Character
	Debris:AddItem(RagdollGetup, 1)

	if DoKnockback == true and MainPart ~= nil then
		Character:AddTag("CantRotate")
		Character:AddTag("Knockbacked")

		local EnemyStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local lookVector = MainPart.CFrame.LookVector

		local knockbackAnim = Assets.Animations.Other.Knockback
		local knockbackTrack, knockbackEvents = AnimationService:getAnimationTrack(Character, knockbackAnim)

		HumRP.CFrame = CFrame.lookAlong(
			Vector3.new(HumRP.Position.X, MainPart.Position.Y, HumRP.Position.Z),
			-HumRP.CFrame.LookVector
		)

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(100000, 0, 100000)
		bv.Velocity = lookVector * 140
		bv.Parent = HumRP
		game.TweenService
			:Create(
				bv,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Velocity = Vector3.zero }
			)
			:Play()
		game.Debris:AddItem(bv, 0.6)

		table.insert(
			knockbackEvents,
			knockbackTrack.Stopped:Once(function()
				pcall(function()
					bv:Destroy()
				end)

				StunHandler:Unstun(Character, EnemyStun)
				Character:RemoveTag("CantRotate")
				Character:RemoveTag("Knockbacked")
			end)
		)

		AnimationService:playAnimation(Character, knockbackAnim)
		SFXModule:PlaySound(Assets.Sounds.Other.KnockbackLand, HumRP)
	end
end

function Ragdoll.ragdoll(Humanoid, Duration, HardRagdoll, Ragdoller, HardRagdollConfig, _, checkAir)
	if not Humanoid.Parent or not Humanoid.Parent:FindFirstChild("HumanoidRootPart") or Humanoid.BreakJointsOnDeath then
		return
	end
	Duration = Duration or -1
	if Duration ~= -1 and Duration < 0 then
		return
	end

	local Character = Humanoid.Parent
	local Player = Players:GetPlayerFromCharacter(Character)

	local HumRP = Character.HumanoidRootPart

	cancelActiveKnockbacks(Character)

	Character:AddTag("Ragdolled")
	Character:SetAttribute("Ragdolled", true)
	Character:SetAttribute("lastRagdoll", tick())

	local Ragdolled = Instance.new("Folder")
	Ragdolled.Name = "Ragdolled"
	Ragdolled.Parent = Character

	AnimationService:stopAll(Character)

	setOwnershipAll(Character, nil)

	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("Part") or v:IsA("BasePart") then
			if v.Name:find("Hitbox_") then
				v.CanCollide = true
				v.Massless = true
				continue
			end

			v.CollisionGroup = "NoCol"

			if v.Name ~= "HumanoidRootPart" and v.Name ~= "Torso" then
				v.Massless = true
			end
		end
	end

	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true

	Character:AddTag("CantRotate")

	if not Player then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		RemoteManager.FireClient(Player, "Ragdoll", { State = true })
	end

	for _, v in ipairs(Character.Torso:GetChildren()) do
		if v:IsA("Motor6D") and v.Part0 == Character.Torso then
			if v.Name == "Neck" then
				continue
			end
			if v.Name == "RootJoint" then
				continue
			end

			v.Enabled = false
		end
	end

	if Duration ~= -1 and Duration > 0 then
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0)

		Ragdolled.Destroying:Once(function()
			StunHandler:Unstun(Character, Stun)
		end)

		task.delay(Duration, function()
			Ragdolled:Destroy()
			if Character:FindFirstChild("Ragdolled") then
				return
			end

			Ragdoll.cancelRagdoll(Humanoid)
		end)
	else
		StunHandler:Stun(Character)
	end

	if HardRagdoll == true then
		local Config = HardRagdollConfig or {}
		local ImpactDamage = Config.Damage or DEFAULT_HARD_RAGDOLL_DAMAGE
		local ImpactSize = Config.Size or DEFAULT_HARD_RAGDOLL_SIZE
		local ImpactOffset = Config.Offset or DEFAULT_HARD_RAGDOLL_OFFSET
		local GroundCraterConfigs = Config.GroundCrater
		local KnockupForce = Config.KnockupForce or DEFAULT_HARD_RAGDOLL_KNOCKUP_FORCE

		local LoopTask = nil
		LoopTask = task.spawn(function()
			local PastTime = 0
			while true do
				if PastTime < 0.4 then
					PastTime += task.wait()
					continue
				end

				if Character and Character.Parent then
					local Velocity = HumRP.AssemblyLinearVelocity
					local HitRay = workspace:Raycast(
						HumRP.Position,
						Vector3.new(
							math.clamp(Velocity.X, -5.3, 5.3),
							math.clamp(Velocity.Y, -5.3, 5.3),
							math.clamp(Velocity.Z, -5.3, 5.3)
						),
						MapRayParams
					)
					if HitRay then
						fireGroundCraters(HumRP, GroundCraterConfigs)

						local VoxelParameters = {
							Velocity = HumRP.CFrame.UpVector,
							Multiplier = { 15, 50 },
							Size = ImpactSize,
							CFrame = HumRP.CFrame * ImpactOffset,
						}

						HitboxHandler:SimpleOnce(
							HumRP,
							ImpactSize,
							ImpactOffset,
							{ Character, Ragdoller },
							nil,
							nil,
							function(EnemyCharacter)
								local EnemyHumanoid = EnemyCharacter.Humanoid

								DamageHandler:TakeDamage(
									Character,
									EnemyHumanoid,
									ImpactDamage,
									nil,
									nil,
									false,
									false,
									false,
									true,
									false,
									nil,
									13
								)
								NewKnockback:Knockback(EnemyCharacter, {
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(1, 100000, 1),
									Velocity = HumRP.CFrame.UpVector * KnockupForce,
								})
								Ragdoll.ragdoll(EnemyHumanoid, 2)
							end,
							nil,
							VoxelParameters
						)

						local ShakeHitboxSize = ImpactSize * 3
						local ShakeMaxDistance = ShakeHitboxSize.Magnitude / 2

						HitboxHandler:SimpleOnce(
							HumRP,
							ShakeHitboxSize,
							ImpactOffset + Vector3.new(0, 5, 0),
							{},
							nil,
							nil,
							function(ShakeCharacter)
								local ShakeHumanoid = ShakeCharacter:FindFirstChildOfClass("Humanoid")
								local ShakeRootPart = ShakeCharacter:FindFirstChild("HumanoidRootPart")
								if not ShakeHumanoid or not ShakeRootPart then
									return
								end

								local ShakePlayer = Players:GetPlayerFromCharacter(ShakeCharacter)
								if not ShakePlayer then
									return
								end

								local Distance = (ShakeRootPart.Position - HumRP.Position).Magnitude
								local Falloff = 1 - math.clamp(Distance / ShakeMaxDistance, 0, 1)
								local Intensity = 1 + (Falloff * 4)

								RemoteManager.FireClient(
									ShakePlayer,
									"ShakeCamera",
									{ Intensity = Intensity, Last = 0.3 }
								)
							end,
							nil,
							nil
						)

						break
					else
						task.wait()
					end
				else
					break
				end
			end

			LoopTask = nil
		end)

		task.delay(6, function()
			pcall(function()
				task.cancel(LoopTask)
			end)
			LoopTask = nil
		end)
	else
		if checkAir ~= false then
			AirDetectionService:Start(Character, {
				ragdoll = true,
			})
		end
	end

	Character.HumanoidRootPart.CanCollide = true

	return Ragdolled
end

return Ragdoll
