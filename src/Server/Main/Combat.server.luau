local RS = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Remotes = RS.Remotes

local CombatSet = Remotes.Combat.Set
local CombatSetEvent = CombatSet.OnServerEvent

local SvModules = SvSt.Modules

local DamageHandler = require(SvModules.DamageHandler)
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local NewKnockback = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)
local SoundsModule = require(SvModules.SoundsModule)
local SFX = require(SvModules.SFXModule)

local Assets = SvSt.Assets
local Animations = Assets.Animations
local CombatAnims = Animations.Combat
local Sounds = Assets.Sounds
local CombatSounds = Sounds.Combat
local ReplicateSet = Remotes.Replicate.Set

local LastPunch = {}
local MaxCombo = 4
local M1Damage = {
	[1] = 2,
	[2] = 2,
	[3] = 2,
	[4] = 4,
}

local function ChangeCombo(Char)
	if not Char:GetAttribute("Combo") then
		Char:SetAttribute("Combo", 0)
	end

	if Char:GetAttribute("TrueComboCount") then
		Char:SetAttribute("Combo", Char:GetAttribute("TrueComboCount"))
		Char:SetAttribute("TrueComboCount", nil)
	else
		if LastPunch[Char] then
			if (time() - LastPunch[Char]) >= 1.5 then
				Char:SetAttribute("Combo", 1)
			else
				if Char:GetAttribute("Combo") >= MaxCombo then
					Char:SetAttribute("Combo", 1)
				else
					Char:SetAttribute("Combo", Char:GetAttribute("Combo") + 1)
				end
			end
		else
			Char:SetAttribute("Combo", Char:GetAttribute("Combo") + 1)
		end
	end

	LastPunch[Char] = time()
	return Char:GetAttribute("Combo")
end

local function GetPunchAnim(Char, Uppercut, Downslam)
	local CurrentCombo = Char:GetAttribute("Combo")
	local PunchesFolder = CombatAnims.Punches.Default
	local Player = Players:GetPlayerFromCharacter(Char)

	if Player and CombatAnims.Punches:FindFirstChild(Player:GetAttribute("Moveset")) then
		PunchesFolder = CombatAnims.Punches[Player:GetAttribute("Moveset")]
	end

	local Animation = nil

	if CurrentCombo < MaxCombo then
		Animation = PunchesFolder[tostring(CurrentCombo)]
	else
		if not Uppercut and not Downslam then
			Animation = PunchesFolder[tostring(MaxCombo)]
		elseif Downslam then
			Animation = CombatAnims.Punches.Downslam
		elseif Uppercut then
			Animation = CombatAnims.Punches.Uppercut
		end
	end

	return Animation, PunchesFolder[tostring(CurrentCombo - 1 > 0 and CurrentCombo - 1 or 4)]
end

local function M1(Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doPunch") ~= true then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local Humanoid = Character.Humanoid

	if Character:HasTag("CantPunch") or Character:HasTag("Stunned") then
		task.spawn(function()
			task.wait(0.1)
			M1(Player)
		end)
		return
	elseif Character:HasTag("PunchCDS") then
		return
	end

	Character:AddTag("Punching")
	Character:AddTag("PunchCDS")

	local Hit = false
	local CurrentCombo = ChangeCombo(Character)
	local CurrentType

	Character:SetAttribute("DefaultJumpPower", 0)
	Humanoid.JumpPower = 0

	local Params = {}
	Params.Downslam = Humanoid:GetState() == Enum.HumanoidStateType.Freefall
	Params.Uppercut = Humanoid.Jump

	Character:SetAttribute("DefaultRunSpeed", 16)
	Character:SetAttribute("DefaultWalkSpeed", 16)
	Humanoid.WalkSpeed = 16

	local VoxelParameters = nil
	local Size, Offset = Vector3.new(7, 5, 7), CFrame.new(0, 0, -3.5)

	if CurrentCombo >= MaxCombo then
		if Params.Downslam then
			CurrentType = "Downslam"
			Size, Offset = Vector3.new(7, 14, 7), CFrame.new(0, -7, -3.5)
		elseif Params.Uppercut then
			CurrentType = "Uppercut"
			Size, Offset = Vector3.new(7, 14, 7), CFrame.new(0, -3, -3.5)
		else
			CurrentType = tostring(CurrentCombo)
		end
	else
		CurrentType = tostring(CurrentCombo)
	end

	Character:SetAttribute("LastM1Type", CurrentType)
	Character:SetAttribute("LastM1Time", tick())
	Character:SetAttribute("LastM1Position", HumRP.Position)

	local PunchAnim, PreviousAnimation = GetPunchAnim(Character, Params.Uppercut, Params.Downslam)
	local PunchAnimTrack, PunchEvents = AnimationService:getAnimationTrack(Character, PunchAnim)

	table.insert(
		PunchEvents,
		PunchAnimTrack:GetMarkerReachedSignal("hit"):Connect(function()
			SFX:Play("Hit", HumRP)
			HitboxHandler:SimpleOnce(HumRP, Size, Offset, { Character }, nil, nil, function(EnemyCharacter)
				local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid = EnemyCharacter.Humanoid
				local EnemyHumRP = EnemyCharacter.HumanoidRootPart

				if
					EnemyCharacter == Character
					or (CurrentType ~= "Downslam" and (EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled")))
					or iFramesService:HasiFrame(EnemyCharacter, "M1")
				then
					return
				end

				local Blockable = CurrentType ~= "Downslam"
				local Dmg = M1Damage[CurrentCombo] or 4

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					Dmg,
					1,
					Assets.Animations.Combat.Hits[tostring(CurrentCombo)],
					Blockable,
					true,
					false,
					true,
					true,
					"M1"
				)

				if HitInfo.Countered then
					return
				end

				if HitInfo.Blocked then
					SoundsModule:PlaySound(
						CombatSounds.Blocking.Hits:GetChildren()[math.random(
							1,
							#CombatSounds.Blocking.Hits:GetChildren()
						)],
						EnemyHumRP
					)
				else
					Hit = true

					Character:SetAttribute("LastM1Hit", EnemyCharacter.Name)

					if CurrentType ~= "Downslam" and CurrentType ~= "Uppercut" then
						ReplicateSet:FireAllClients("HitEffect", {
							EChar = EnemyCharacter,
							HitChar = Character,
						})
					end

					if CurrentCombo >= MaxCombo then
						if CurrentType == "Downslam" then
							RagdollHandler.ragdoll(EnemyHumanoid, 3, nil, nil, nil, nil, true)
							EnemyHumRP.CFrame *= CFrame.Angles(math.pi / 2, 0, 0)
						elseif CurrentType == "Uppercut" then
							RagdollHandler.ragdoll(EnemyHumanoid, 3)

							NewKnockback:Knockback(EnemyCharacter, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(1, 100000, 1),
								Velocity = Vector3.new(0, 75, 0),
							})

							SvSt.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)
						else
							local pushDir = HumRP.CFrame.LookVector
							local pushFlat = Vector3.new(pushDir.X, 0, pushDir.Z)
							pushFlat = pushFlat.Magnitude > 0 and pushFlat.Unit or Vector3.new(0, 0, -1)

							RagdollHandler.ragdoll(EnemyHumanoid, 3)

							NewKnockback:Knockback(EnemyCharacter, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(100000, 100000, 100000),
								Velocity = pushFlat * 45 + Vector3.new(0, 20, 0),
							})

							SvSt.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)
						end
					else
						local Velocity = HumRP.CFrame.LookVector * 13
						NewKnockback:Knockback(Character, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(math.huge, 0, math.huge),
							Velocity = Velocity,
						})
						if not EnemyCharacter:HasTag("Knockbacked") then
							NewKnockback:Knockback(EnemyCharacter, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(math.huge, 0, math.huge),
								Velocity = Velocity,
							})
						end
					end
				end
			end, nil, VoxelParameters)

			if Hit then
			else
				if CurrentCombo >= MaxCombo then
					Character:SetAttribute("DefaultRunSpeed", 0)
					Character:SetAttribute("DefaultWalkSpeed", 0)
					Humanoid.WalkSpeed = 0
				end
			end
		end)
	)

	local ended = false
	local function EndFunction()
		if ended then
			return
		end
		ended = true

		Character:RemoveTag("Punching")

		task.spawn(function()
			for _, v in PunchEvents do
				v:Disconnect()
			end

			local WaitTime = 0.15
			if CurrentCombo >= MaxCombo and not Hit then
				WaitTime *= 2
			end

			Character:AddTag("CantBlock")
			task.delay(WaitTime, function()
				if not Character:HasTag("Punching") then
					Character:SetAttribute("DefaultRunSpeed", 25)
					Character:SetAttribute("DefaultWalkSpeed", 16)
					Character:SetAttribute("DefaultJumpPower", 50)
					Character:RemoveTag("CantBlock")
					Humanoid.JumpPower = 50
					Humanoid.WalkSpeed = 16
				end
			end)
		end)

		if CurrentCombo >= MaxCombo then
			task.delay(1.5, function()
				Character:RemoveTag("PunchCDS")
				if Character:GetAttribute("doPunch") then
					M1(Player)
				end
			end)
		else
			Character:RemoveTag("PunchCDS")
			if Character:GetAttribute("doPunch") then
				M1(Player)
			end
		end
	end

	table.insert(PunchEvents, PunchAnimTrack:GetMarkerReachedSignal("end"):Once(EndFunction))
	PunchAnimTrack.Stopped:Once(EndFunction)

	AnimationService:stopAnimation(Character, PreviousAnimation)
	AnimationService:playAnimation(Character, PunchAnim)
	AnimationService:adjustSpeed(Character, PunchAnim, 1.5)

	ReplicateSet:FireAllClients("ActionHightlight", { char = Character, func = "M1" })
end

local function Block(Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doBlock") ~= true then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	if Character:HasTag("CantBlock") or Character:HasTag("Stunned") or Character:HasTag("Punching") then
		task.delay(0.1, function()
			Block(Player)
		end)
		return
	elseif Character:HasTag("Blocking") then
		return
	end

	local Actions = { "CantPunch", "CantDash", "CantBlock", "Blocking", "CantRun" }
	local Connections = {}
	local Stopped

	local Anim = Animations.Combat.Block
	SoundsModule:PlaySound(CombatSounds.Blocking.Start, HumRP)

	local function stopBlock()
		if Stopped then
			return
		end
		Stopped = true

		for _, v in Connections do
			v:Disconnect()
		end

		Character:SetAttribute("DefaultRunSpeed", 25)
		Character:SetAttribute("DefaultWalkSpeed", 16)
		Character:SetAttribute("DefaultJumpPower", 50)
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50

		for _, Action in ipairs(Actions) do
			Character:RemoveTag(Action)
		end

		SoundsModule:PlaySound(CombatSounds.Blocking.Stop, HumRP)

		ReplicateSet:FireAllClients("ActionHightlight", { char = Character, func = "BlockEnd" })
	end

	local BlockAnimTrack = AnimationService:getAnimationTrack(Character, Anim)

	Connections["Stopped"] = BlockAnimTrack.Stopped:Once(stopBlock)
	Connections["StopLoop"] = Character:GetAttributeChangedSignal("doBlock"):Connect(function()
		if not Character:GetAttribute("doBlock") then
			AnimationService:stopAnimation(Character, Anim)
			stopBlock()
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Anim)

	Character:SetAttribute("DefaultRunSpeed", 8)
	Character:SetAttribute("DefaultWalkSpeed", 8)
	Humanoid.WalkSpeed = 8
	Humanoid.JumpPower = 0

	for _, Action in ipairs(Actions) do
		Character:AddTag(Action)
	end

	ReplicateSet:FireAllClients("ActionHightlight", { char = Character, func = "BlockStart" })

	local Perfect = true
	local PC
	PC = Character.ChildAdded:Connect(function(Child)
		if Child.Name == "DamagedLog" and Child:HasTag("IsM1") and Perfect then
			if PC then
				PC:Disconnect()
				PC = nil
			end
			Character:AddTag("PerfectBlock")
			task.delay(1, function()
				Character:RemoveTag("PerfectBlock")
			end)
		end
	end)

	task.delay(0.25, function()
		if PC then
			PC:Disconnect()
			PC = nil
		end
		Perfect = false
	end)
end

CombatSetEvent:Connect(function(Player, Action, Params)
	if not Player:FindFirstChild("LoadedData") then
		return
	end

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not HumRP or not Humanoid then
		return
	end

	if Action == "PunchStart" then
		Character:SetAttribute("doPunch", true)
		M1(Player)
	elseif Action == "PunchEnd" then
		Character:SetAttribute("doPunch", false)
	elseif Action == "Block" then
		if Params.Stage == true then
			Character:SetAttribute("doBlock", true)
			Block(Player)
		else
			Character:SetAttribute("doBlock", false)
		end
	end
end)
