local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local RPModules = RS.Shared.Modules
local SvModules = script.Parent

local StunHandler = require(SvModules.StunHandler)
local CombatLogger = require(script.CombatLogger)
local Utility = require(RPModules.Utility)
local AnimationService = require(SvModules.AnimationService)

local CheckBehind = Utility("CheckBehind")

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

local Remotes = RS.Remotes
local ReplicateSet = Remotes.Replicate.Set

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

	local returnValue = {
		CouldHit = false,
		Blocked = false,
		Countered = false,
		Finisher = (Hum.Health <= (FinisherRequirement or Damage)),
	}

	local WasDead = Hum.Health <= 0 or Hum:GetState() == Enum.HumanoidStateType.Dead

	if
		Blockable == true
		and Damaged:HasTag("Blocking")
		and CheckBehind(Damager.HumanoidRootPart, Damaged.HumanoidRootPart) == false
	then
		returnValue.Blocked = true
	else
		if Damaged:HasTag("Countering") and Counterable == true then
			returnValue.Countered = true
		else
			returnValue.CouldHit = true

			if returnValue.Finisher == true then
				if doFinisher == true then
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
				end
			else
				Hum:TakeDamage(Damage)
				AddDealtDamage(Damaged, Damager, Damage)

				if Type == "M1" then
					ReplicateSet:FireAllClients("RemoveAllBodyMovers", Damaged)
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
					StunHandler:Stun(Damaged, StunTime[1], bypassStunImmunity, StunTime[2], StunTime[3])
				else
					StunHandler:Stun(Damaged, StunTime, bypassStunImmunity)
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
				if not WasDead and returnValue.Finisher == true and doFinisher == true then
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
						if not Damaged:FindFirstChild("Dummy") and game.PrivateServerOwnerId == 0 then
							if Damager == Damaged then
								return
							end

							local Kills = DamagerPlayer.leaderstats:FindFirstChild("Kills", true)
							if Kills then
								Kills.Value += 1
							end

							local TotalKills = DamagerPlayer.leaderstats:FindFirstChild("Total Kills", true)
							if TotalKills then
								TotalKills.Value += 1
							end

							Damager:SetAttribute("Streak", (Damager:GetAttribute("Streak") or 0) + 1)
						end
					end
				end

				if addAwkProgress == true or addAwkProgress == nil then
					if not Damager:HasTag("Awakened") then
						DamagerPlayer.AwakeningProgress.Value += Damage / 3
					end
					if DamagerPlayer.AwakeningProgress.Value > 100 then
						DamagerPlayer.AwakeningProgress.Value = 100
					end
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

	local Kills = DamagerPlayer.leaderstats:FindFirstChild("Kills", true)
	if Kills then
		Kills.Value += 1
	end

	local TotalKills = DamagerPlayer.leaderstats:FindFirstChild("Total Kills", true)
	if TotalKills then
		TotalKills.Value += 1
	end

	Damager:SetAttribute("Streak", (Damager:GetAttribute("Streak") or 0) + 1)
end)

return module
