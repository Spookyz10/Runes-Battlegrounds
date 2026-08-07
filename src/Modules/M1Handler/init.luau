local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")

local SvModules = SvSt.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local DamageHandler = require(SvModules.DamageHandler)
local HitboxHandler = require(SvModules.HitboxHandler)
local AnimationService = require(SvModules.AnimationService)
local iFramesService = require(SvModules.iFramesService)
local SFX = require(SvModules.SFXModule)
local KnockbackPresets = require(script.KnockbackPresets)

local Configs = {}
for _, module in script.Configs:GetChildren() do
	if module:IsA("ModuleScript") then
		Configs[module.Name] = require(module)
	end
end

local M1Handler = {}

local LastPunch = {}
local MaxCombo = 4

local function getConfig(Player)
	local Moveset = Player:GetAttribute("Moveset") or "Default"
	local Mode = Player:GetAttribute("MovesetMode_" .. Moveset)

	if Mode and Configs[Moveset .. "_" .. Mode] then
		return Configs[Moveset .. "_" .. Mode]
	end

	return Configs[Moveset] or Configs.Default
end

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

local function resolveStep(Character, Config, Combo, Humanoid)
	if Combo >= MaxCombo then
		if Config.Empowered and Config.Empowered.Condition and Config.Empowered.Condition(Character) then
			return Config.Empowered, "Empowered"
		end

		if Humanoid:GetState() == Enum.HumanoidStateType.Freefall and Config.Downslam then
			return Config.Downslam, "Downslam"
		elseif Humanoid.Jump and Config.Uppercut then
			return Config.Uppercut, "Uppercut"
		end
	end

	return Config.Steps[Combo] or Config.Steps[MaxCombo], tostring(Combo)
end

function M1Handler:Punch(Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doPunch") ~= true then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not HumRP or not Humanoid then
		return
	end

	if Character:HasTag("CantPunch") or Character:HasTag("Stunned") then
		task.delay(0.1, function()
			M1Handler:Punch(Player)
		end)
		return
	elseif Character:HasTag("PunchCDS") then
		return
	end

	local Config = getConfig(Player)
	local Combo = ChangeCombo(Character)
	local Step, StepId = resolveStep(Character, Config, Combo, Humanoid)

	if not Step then
		warn("[M1Handler] No step resolved for combo " .. tostring(Combo))
		return
	end

	Character:AddTag("Punching")
	Character:AddTag("PunchCDS")

	local Hit = false

	Character:SetAttribute("DefaultJumpPower", 0)
	Humanoid.JumpPower = 0
	Character:SetAttribute("DefaultRunSpeed", 16)
	Character:SetAttribute("DefaultWalkSpeed", 16)
	Humanoid.WalkSpeed = 16

	Character:SetAttribute("LastM1Type", StepId)
	Character:SetAttribute("LastM1Time", tick())
	Character:SetAttribute("LastM1Position", HumRP.Position)

	local Animation = Step.Animation
	local PunchAnimTrack, PunchEvents = AnimationService:getAnimationTrack(Character, Animation)

	table.insert(
		PunchEvents,
		PunchAnimTrack:GetMarkerReachedSignal("hit"):Connect(function()
			SFX:Play(Step.HitSound or "Hit", HumRP)

			HitboxHandler:SimpleOnce(
				HumRP,
				Step.Hitbox.Size,
				Step.Hitbox.Offset,
				{ Character },
				nil,
				nil,
				function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter.Humanoid
					local EnemyHumRP = EnemyCharacter.HumanoidRootPart

					if
						EnemyCharacter == Character
						or (Step.IgnoreRagdollCheck ~= true and (EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag(
							"Ragdolled"
						)))
						or iFramesService:HasiFrame(EnemyCharacter, "M1")
					then
						return
					end

					local Damage = Step.Damage
					if Step.GetDamage then
						Damage = Step.GetDamage(Character, EnemyCharacter, Combo)
					end

					local HitInfo = DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						Damage,
						Step.StunTime or 1,
						Step.HitAnimation,
						Step.Blockable ~= false,
						true,
						Step.BypassStunImmunity == true,
						true,
						Step.DoFinisher ~= false,
						"M1"
					)

					if HitInfo.Countered then
						return
					end

					if HitInfo.Blocked then
						if Step.OnBlocked then
							Step.OnBlocked(Character, EnemyCharacter)
						end
						return
					end

					Hit = true
					Character:SetAttribute("LastM1Hit", EnemyCharacter.Name)

					if Step.PlayHitEffect ~= false then
						RemoteManager.FireAllClients(
							"ReplicateTask",
							"HitEffect",
							{ EChar = EnemyCharacter, HitChar = Character }
						)
					end

					if Step.Knockback then
						local Preset = KnockbackPresets[Step.Knockback]
						if Preset then
							Preset(Character, EnemyCharacter, HumRP, EnemyHumRP)
						end
					end

					if Step.OnHit then
						Step.OnHit(Character, EnemyCharacter, HitInfo, Combo)
					end
				end,
				nil,
				Step.Voxels
			)

			if not Hit and Combo >= MaxCombo then
				Character:SetAttribute("DefaultRunSpeed", 0)
				Character:SetAttribute("DefaultWalkSpeed", 0)
				Humanoid.WalkSpeed = 0
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
			if Combo >= MaxCombo and not Hit then
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

		if Combo >= MaxCombo then
			task.delay(1.5, function()
				Character:RemoveTag("PunchCDS")
				if Character:GetAttribute("doPunch") then
					M1Handler:Punch(Player)
				end
			end)
		else
			Character:RemoveTag("PunchCDS")
			if Character:GetAttribute("doPunch") then
				M1Handler:Punch(Player)
			end
		end
	end

	table.insert(PunchEvents, PunchAnimTrack:GetMarkerReachedSignal("end"):Once(EndFunction))
	PunchAnimTrack.Stopped:Once(EndFunction)

	local PrevIndex = Combo - 1
	if PrevIndex <= 0 then
		PrevIndex = MaxCombo
	end
	local PrevStep = Config.Steps[PrevIndex]
	if PrevStep then
		AnimationService:stopAnimation(Character, PrevStep.Animation)
	end

	AnimationService:playAnimation(Character, Animation)
	AnimationService:adjustSpeed(Character, Animation, Step.Speed or 1.5)

	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "M1" })
end

return M1Handler
