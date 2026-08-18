local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RPModules = RS.Shared.Modules
local SvModules = script.Parent

local StunHandler = require(SvModules.StunHandler)
local CombatLogger = require(script.CombatLogger)

local Utility = require(RPModules.Utility)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Data = require(ReplicatedStorage.Shared.Data).server
local AnimationService = require(SvModules.AnimationService)
local AntiTeamingHandler = require(SvModules.AntiTeamingHandler)
local AwakeningService = require(SvModules.AwakeningService)
local CombatEvents = require(SvModules.CombatEvents)
local BadgeAwardService = require(SvModules.BadgeAwardService)
local KillSoundService = require(SvModules.KillSoundService)

local CheckBehind = Utility("CheckBehind")

local BlockAnims = ServerStorage.Assets.Animations.BlockAnims

local module = {}

local function AddDealtDamage(Damaged, Damager, Damage)
	local Player = Players:GetPlayerFromCharacter(Damager)

	Damager:SetAttribute("LastAttackPosition", Damager:GetPivot().Position)
	if Player then
		Damaged:SetAttribute("LastHitBy", Player.UserId)
	end

	local DealtDmg = Damaged:GetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage")
	if not DealtDmg then
		Damaged:SetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage", Damage)
	else
		Damaged:SetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage", DealtDmg + Damage)
	end

	task.delay(CombatLogger.CombatStateDuration, function()
		if Damaged then
			local CurrDealtDmg = Damaged:GetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage")
			if CurrDealtDmg then
				Damaged:SetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage", CurrDealtDmg - Damage)
				CurrDealtDmg = Damaged:GetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage")
				if CurrDealtDmg <= 0 then
					Damaged:SetAttribute(Damager.Name:gsub(" ", "_") .. "_Dealt_Damage", nil)
				end
			end
		end
	end)
end

local function playRandomBlockAnim(Damaged)
	local anims = BlockAnims:GetChildren()
	if #anims == 0 then
		return
	end

	local randomAnim = anims[math.random(1, #anims)]
	if randomAnim:IsA("Animation") then
		AnimationService:playAnimation(Damaged, randomAnim)
	end
end

function module:TakeDamage(
	Damager,
	Hum,
	Damage,
	StunTime,
	Animation,
	Blockable,
	Counterable,
	bypassStunImmunity,
	addAwkProgress,
	doFinisher,
	Type,
	FinisherRequirement
)
	if not Damager or not Damager.Parent or not Hum or not Hum.Parent then
		return
	end
	if doFinisher == nil then
		doFinisher = true
	end

	local DamagerPlayer = Players:GetPlayerFromCharacter(Damager)
	local Damaged = Hum.Parent

	local mult = AntiTeamingHandler:GetDamageMultiplier(Damager)
	if mult ~= 1 then
		Damage = math.round(Damage * mult)
	end

	local damageTakenMult = Damaged:GetAttribute("DamageTakenMult") or 1
	if damageTakenMult ~= 1 then
		Damage = math.round(Damage * damageTakenMult)
	end

	local returnValue = {
		CouldHit = false,
		Blocked = false,
		Countered = false,
		Finisher = (Hum.Health <= (FinisherRequirement or Damage)),
	}

	local WasDead = Hum.Health <= 0 or Hum:GetState() == Enum.HumanoidStateType.Dead

	if Blockable ~= true and Damaged:HasTag("Blocking") then
		Damaged:SetAttribute("doBlock", false)
	end

	if
		Blockable == true
		and Damaged:HasTag("Blocking")
		and CheckBehind(Damager.HumanoidRootPart, Damaged.HumanoidRootPart) == false
	then
		returnValue.Blocked = true
		playRandomBlockAnim(Damaged)
	else
		if Damaged:HasTag("Countering") and Counterable == true then
			returnValue.Countered = true
		else
			returnValue.CouldHit = true

			if returnValue.Finisher == true and doFinisher == true then
				task.spawn(function()
					for _, v in workspace:GetDescendants() do
						if
							(v:IsA("Weld") or v:IsA("WeldConstraint"))
							and (
								(v.Part1 == Damaged.HumanoidRootPart and v.Part0 == Damager.HumanoidRootPart)
								or (v.Part1 == Damager.HumanoidRootPart and v.Part0 == Damaged.HumanoidRootPart)
							)
						then
							v:Destroy()
						end
					end
				end)

				local HealthScript = Damaged:FindFirstChild("Health")
				if HealthScript then
					HealthScript.Enabled = false
				end

				Hum:TakeDamage(FinisherRequirement or Damage)
				AddDealtDamage(Damaged, Damager, Damage)

				CombatEvents.DamageDealt:Fire(Damager, Damaged, FinisherRequirement or Damage, Type)

				RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Damaged, func = "Hit" })
			else
				Hum:TakeDamage(Damage)
				AddDealtDamage(Damaged, Damager, Damage)

				CombatEvents.DamageDealt:Fire(Damager, Damaged, Damage, Type)

				RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Damaged, func = "Hit" })

				if Type == "M1" then
					RemoteManager.FireAllClients("ReplicateTask", "RemoveAllBodyMovers", Damaged)
					for _, BodyMover in Damaged:GetDescendants() do
						if
							BodyMover:IsA("BodyVelocity")
							or BodyMover:IsA("BodyAngularVelocity")
							or BodyMover:IsA("LinearVelocity")
							or BodyMover:IsA("AngularVelocity")
							or BodyMover:IsA("VectorForce")
							or BodyMover:IsA("Torque")
							or BodyMover:IsA("BodyPosition")
						then
							BodyMover:Destroy()
						end
						if BodyMover:IsA("BasePart") then
							BodyMover.AssemblyLinearVelocity = Vector3.zero
							BodyMover.AssemblyAngularVelocity = Vector3.zero
						end
					end
				end
			end

			if StunTime then
				if typeof(StunTime) == "table" then
					StunHandler:Stun(
						Damaged,
						StunTime[1],
						bypassStunImmunity,
						StunTime[2],
						StunTime[3],
						nil,
						nil,
						false
					)
				else
					StunHandler:Stun(Damaged, StunTime, bypassStunImmunity, nil, nil, nil, nil, false)
				end
			end

			if Animation then
				task.spawn(function()
					if not Damaged:GetAttribute("OnAntiTeam") then
						AnimationService:stopAll(Damaged)
						AnimationService:playAnimation(Damaged, Animation)
					end
				end)
			end

			if DamagerPlayer then
				if not WasDead and Hum.Health <= 0 then
					local MostDealt = nil
					for Name, Value in Damaged:GetAttributes() do
						if Name:find("_Dealt_Damage") then
							local RealDamagerPlayer = Players:FindFirstChild(Name:gsub("_Dealt_Damage", ""))
							if RealDamagerPlayer then
								if MostDealt then
									if Value > MostDealt.Dealt then
										MostDealt = { Player = RealDamagerPlayer, Dealt = Value }
									end
								else
									MostDealt = { Player = RealDamagerPlayer, Dealt = Value }
								end
							else
								Damaged:SetAttribute(Name, nil)
							end
						end
					end

					if MostDealt and MostDealt.Player == DamagerPlayer then
						if Damager == Damaged then
							return
						end

						KillSoundService:PlaySound(Damager, Damaged)

						if not Damaged:FindFirstChild("Dummy") and game.PrivateServerOwnerId == 0 then
							local DamagerData = Data.Service:waitForData(DamagerPlayer)
							if DamagerData then
								DamagerData.Kills(function(k)
									return k + 1
								end)

								local NewTotalKills = DamagerData.TotalKills(function(k)
									return k + 1
								end)

								BadgeAwardService:CheckKills(DamagerPlayer, NewTotalKills)

								Damager:SetAttribute("Streak", (Damager:GetAttribute("Streak") or 0) + 1)
							end
						end
					end
				end

				if addAwkProgress == true or addAwkProgress == nil then
					AwakeningService:GiveProgress(DamagerPlayer, Damage / 3)
				end
			end
		end
	end

	CombatLogger:DamagedLog(Damager, Damaged, Counterable, Type)
	CombatLogger:DamagerLog(Damager, Damaged)

	return returnValue
end

Players.PlayerRemoving:Connect(function(DamagedPlayer)
	local Damaged = DamagedPlayer.Character
	if not Damaged then
		return
	end
	if Damaged:FindFirstChild("Dummy") then
		return
	end

	AntiTeamingHandler:Cleanup(Damaged)

	local LastHitFrom = Damaged:GetAttribute("LastHitBy")
	if not LastHitFrom then
		return
	end

	local DamagerPlayer = Players:GetPlayerByUserId(LastHitFrom)
	if not DamagerPlayer or DamagerPlayer == DamagedPlayer then
		return
	end

	local Damager = DamagerPlayer.Character
	if not Damager then
		return
	end

	local DealtDamage = 0
	for Name, Value in Damaged:GetAttributes() do
		if Name:find("_Dealt_Damage") and typeof(Value) == "number" then
			DealtDamage += Value
		end
	end
	if DealtDamage <= 0 then
		return
	end
	if Damager == Damaged then
		return
	end

	local DamagerData = Data.Service:waitForData(DamagerPlayer)
	if DamagerData then
		DamagerData.Kills(function(k)
			return k + 1
		end)

		local NewTotalKills = DamagerData.TotalKills(function(k)
			return k + 1
		end)

		BadgeAwardService:CheckKills(DamagerPlayer, NewTotalKills)

		Damager:SetAttribute("Streak", (Damager:GetAttribute("Streak") or 0) + 1)
	end
end)

return module
