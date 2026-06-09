--// Services \\--

local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')



--// Modules Required \\--

local RPModules = RS.Modules
local SvModules = script.Parent


local PlayerClasses = require(SvModules.PlayerClass)
local StunHandler = require(SvModules.StunHandler)
local AntiTeamModule = require(SvModules.Other.AntiTeam)
local KillMessagesModule = require(SvModules.Other.KillMessages)
local CombatLogger = require(script.CombatLogger)
local Utility = require(RPModules.Utility)

local InfoModule = require(RS.Info)



local AnimationService = require(SvModules.AnimationService)
local KillstreakModule = require(SvModules.KillstreakModule)


local CheckBehind = Utility('CheckBehind')



--// Module \\--

local DummyCounter = 0.08 / 100
local module = {}



--// Local Functions \\--

local function RNG()
	return Random.new():NextNumber() <= DummyCounter
end

local function AddDealtDamage(Damaged, Damager, Damage)
	local Player = Players:GetPlayerFromCharacter(Damager)
	task.spawn(function()
		if Player and Player.Commands.InstantAwk.Value == true and not Damager:GetAttribute("Awakened") then
			Player.AwakeningProgress.Value = 100
		end
	end)

	Damager:SetAttribute("LastAttackPosition", Damager:GetPivot().Position)
	if Player then
		Damaged:SetAttribute("LastHitBy", Player.UserId)
	end
	
	local DealtDmg = Damaged:GetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage')
	if not DealtDmg then
		Damaged:SetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage', Damage)
	else
		Damaged:SetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage', DealtDmg + Damage)
	end

	task.delay(CombatLogger.CombatStateDuration, function()
		if Damaged then
			local CurrDealtDmg = Damaged:GetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage')
			if CurrDealtDmg then
				Damaged:SetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage', CurrDealtDmg - Damage)

				CurrDealtDmg = Damaged:GetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage')

				if CurrDealtDmg <= 0 then
					Damaged:SetAttribute(Damager.Name:gsub(' ', '_')..'_Dealt_Damage', nil)
				end
			end
		end
	end)
end


--// Remotes \\--

local Remotes = RS.Remotes


local Comunicator = Remotes.Comunicator

local ComSet = Comunicator.Set
local ComGet = Comunicator.Get


local Replication = Remotes.Replicate

local ReplicateSet = Replication.Set
local ReplicateGet = Replication.Get



--// Variables \\--

local Animations = game.ServerStorage.Assets.Animations



--// Module Functions \\--

function module:TakeDamage(Damager: Model, Hum: Humanoid, Damage: number, StunTime: number, Animation: Animation, Blockable: boolean, Counterable: boolean, bypassStunImmunity: boolean, addAwkProgress: boolean, doFinisher: boolean, Type: string, FinisherRequirement: number)
	if not Damager or not Damager.Parent or not Hum or not Hum.Parent then return end
	if doFinisher == nil then
		doFinisher = true
	end

	Damage *= workspace.Configuration.DamageMult.Value

	local DamagerPlayer = Players:GetPlayerFromCharacter(Damager)
	local Damaged: Model = Hum.Parent
	local DamagedPlayer = Players:GetPlayerFromCharacter(Damaged)
	
	local returnValue = { CouldHit = false; Blocked = false; Countered = false; Finisher = ((DamagerPlayer and DamagerPlayer.Commands.OnlyFinishers == true) or workspace.Configuration.OnlyFinishers.Value == true or Hum.Health <= (FinisherRequirement or Damage)); }

	local WasDead = Hum.Health <= 0 or Hum:GetState() == Enum.HumanoidStateType.Dead


	if Blockable == true and Damaged:HasTag('Blocking') and CheckBehind(Damager.HumanoidRootPart, Damaged.HumanoidRootPart) == false then
		returnValue.Blocked = true
		
		
		if Damaged:GetAttribute("DivineForm") then
			if not Damaged:GetAttribute("CurrentDodges") then
				Damaged:SetAttribute("CurrentDodges", 0)
			end

			Damaged:SetAttribute("CurrentDodges", Damaged:GetAttribute("CurrentDodges") + 1)
			
			AnimationService:stopAll(Damaged, 0)
			AnimationService:playAnimation(Damaged, Animations.Combat.Dodges[Damaged:GetAttribute("CurrentDodges")])

			if Damaged:GetAttribute("CurrentDodges") >= 7 then
				Damaged:SetAttribute("CurrentDodges", nil)
			end
		end
	else
		local specialCountered = (Damaged:FindFirstChild('Dummy') and ((RNG() == true and (Type == 'M1' or Type == 'Dropkick')))) or Damaged:HasTag('SpecialCounter') or Damaged:GetAttribute("CMDCounter")

		if (Damaged:HasTag('Countering') and Counterable == true) or specialCountered then
			if specialCountered then
				Damaged:AddTag('SpecialCounter')
				AnimationService:stopAll(Damaged)
			end

			returnValue.Countered = true

		else
			returnValue.CouldHit = true

			if returnValue.Finisher == true then
				if doFinisher == true then
					task.spawn(function()
						for _,v in workspace:GetDescendants() do
							if (v:IsA("Weld") or v:IsA("WeldConstraint")) and ((v.Part1 == Damaged.HumanoidRootPart and v.Part0 == Damager.HumanoidRootPart) or (v.Part1 == Damager.HumanoidRootPart and v.Part0 == Damaged.HumanoidRootPart)) then
								v:Destroy()
							end
						end
					end)

					local HealthScript: Script = Damaged:FindFirstChild('Health')
					if HealthScript then
						HealthScript.Enabled = false
					end

					Hum:TakeDamage(FinisherRequirement or Damage)
					AddDealtDamage(Damaged, Damager, Damage)
					
					if Damaged:FindFirstChild("Snowball") and Damaged:FindFirstChild("HasSnowball") then
						Damaged.Snowball:Destroy()
						Damaged.HasSnowball:Destroy()
					end
					
					if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
						workspace:SetAttribute("Legendary", true)
					end
				end
			else
				Hum:TakeDamage(Damage)
				AddDealtDamage(Damaged, Damager, Damage)
				AntiTeamModule.LogDamager(Damaged, Damager, Damage, Type)
				
				if Damaged:FindFirstChild("Snowball") and Damaged:FindFirstChild("HasSnowball") then
					Damaged.Snowball:Destroy()
					Damaged.HasSnowball:Destroy()
				end
				
				if Type == "M1" then
					if AntiTeamModule.CheckForAntiTeam(Damaged) then
						AntiTeamModule.StartAntiTeam(Damaged, Damager, false)
					end
					
					ReplicateSet:FireAllClients('RemoveAllBodyMovers', Damaged)
					for _, BodyMover: BodyVelocity in Damaged:GetDescendants() do
						if BodyMover:IsA("BodyVelocity") or BodyMover:IsA("BodyAngularVelocity") or BodyMover:IsA("LinearVelocity") or BodyMover:IsA("AngularVelocity") or BodyMover:IsA("VectorForce") or BodyMover:IsA("Torque") or BodyMover:IsA('BodyPosition') then
							BodyMover:Destroy()
						end
						
						if BodyMover:IsA("BasePart") then
							BodyMover.AssemblyLinearVelocity = Vector3.zero
							BodyMover.AssemblyAngularVelocity = Vector3.zero
						end
					end
				end
				
				if DamagerPlayer and DamagerPlayer:GetAttribute("Moveset") == "Cursed Child" then
					ReplicateSet:FireAllClients("DamageIndicator", { Char = Damaged, Val = Damage })
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
					if Type == "M1" then
						
					end
					
					if not Damaged:GetAttribute("OnAntiTeam") then
						AnimationService:stopAll(Damaged)
						AnimationService:playAnimation(Damaged, Animation)
					end
				end)
			end

			if DamagerPlayer then
				local DamagerClass = shared.playerClasses[DamagerPlayer.UserId]

				if not WasDead and returnValue.Finisher == true and doFinisher == true then
					local MostDealt = nil
					for Name, Value in Damaged:GetAttributes() do
						if Name:find('_Dealt_Damage') then
							local RealDamagerPlayer = Players:FindFirstChild(Name:gsub('_Dealt_Damage', ''))
							if RealDamagerPlayer then
								if MostDealt then
									if Value > MostDealt.Dealt then
										MostDealt = { Player = RealDamagerPlayer; Dealt = Value; }
									end
								else
									MostDealt = { Player = RealDamagerPlayer; Dealt = Value; }
								end
							else
								Damaged:SetAttribute(Name, nil)
							end
						end
					end
					
					
					if MostDealt and MostDealt.Player == DamagerPlayer then
						local DamagedHumRP = Damaged:FindFirstChild("HumanoidRootPart")
						local killSoundId = DamagerPlayer:GetAttribute("killSound")
						if killSoundId ~= nil and DamagedHumRP then
							local killSound = Instance.new("Sound")
							killSound.RollOffMaxDistance = 250
							killSound.RollOffMinDistance = 10
							killSound.Volume = 1
							killSound.SoundId = "rbxassetid://"..tostring(killSoundId)
							killSound.SoundGroup = game.SoundService.Sounds
							killSound.Parent = DamagedHumRP
							killSound:Play()
							task.spawn(function()
								killSound.Stopped:Wait()
								killSound:Destroy()
							end)
						end
						
						
						if not Damaged:FindFirstChild('Dummy') and game.PrivateServerOwnerId == 0 then
							if Damager == Damaged then return end
							local IsVIP = DamagerPlayer:GetAttribute("HasVIP")
							
							
							pcall(function()
								KillMessagesModule.SendMessage(Damaged, Damager, IsVIP)
							end)
							
							
							local Kills = DamagerPlayer.leaderstats:FindFirstChild("Kills", true)
							if Kills then
								Kills.Value += 1
							end

							local TotalKills = DamagerPlayer.leaderstats:FindFirstChild("Total Kills", true)
							if TotalKills then
								TotalKills.Value += 1
							end
							
							
							Damager:SetAttribute('Streak', (Damager:GetAttribute('Streak') or 0) + 1)
							
							
							local playerClass = shared.playerClasses[DamagerPlayer.UserId]
							if playerClass then
								if Damager:GetAttribute("Streak") > playerClass.TitlesProgress.Killstreak then
									playerClass.TitlesProgress.Killstreak = Damager:GetAttribute("Streak")
									DamagerPlayer:SetAttribute("KillstreakProgress", playerClass.TitlesProgress.Killstreak)
								end
								
								
								if Damager:GetAttribute('Streak') >= 30 then
									if playerClass.CompletedQuest ~= true then
										playerClass.CompletedQuest = true
									end
								end
								
								
								local BonusGold = math.clamp((Damager:GetAttribute('Streak') or 1 - 1) * 5, 0, 450)
								local GoldAmouth = IsVIP and 50 or 30 + BonusGold
								
								
								playerClass.Gold += GoldAmouth
								DamagerPlayer:SetAttribute("Gold", playerClass.Gold)
								
								
								ComSet:FireClient(DamagerPlayer, "SendNotification", { Text = "Earned " .. GoldAmouth .. " gold. (Streak: " .. tostring(Damager:GetAttribute('Streak') or 1) .. ")" })
							end
							
							
							if Damager:GetAttribute('Streak') >= 10 and not Damager:HasTag('HighestStreak') then
								KillstreakModule:AddKillstreak(Damager)
							end
							
							
							if #DamagerClass.OwnedEmotes < #RS.Resources.Emotes.Animations:GetChildren() then
								if DamagerClass.KillsForEmote > 0 then
									DamagerClass.KillsForEmote -= 1

									if DamagerClass.KillsForEmote == 0 then
										ComSet:FireClient(DamagerPlayer, 'CanSpinEmote')
									else
										ComSet:FireClient(DamagerPlayer, 'ChangeKillForEmote', DamagerClass.KillsForEmote)
									end
								end
							end
						end
					end
				end
				
				
				if addAwkProgress == true or addAwkProgress == nil then
					local GainedDamage = Damage / InfoModule.UFWrequirement
					local CurrentDamage = DamagerPlayer:GetAttribute("DamageNeed") or 0
					
					
					DamagerPlayer:SetAttribute("DamageNeed", math.clamp(CurrentDamage + GainedDamage, 0, 1))
					if DamagerPlayer:GetAttribute("DamageNeed") then
						task.spawn(function()
							if DamagerPlayer:GetAttribute("DamageNeed") >= 1 then
								ComSet:FireClient(DamagerPlayer, 'ModifyHotbar', { ToolName = 'Special Hell', Property = 'Description', Value = 'READY' })
								
							elseif DamagerPlayer:GetAttribute("DamageNeed") >= 0.5 and DamagerPlayer:GetAttribute("DamageNeed") <= 1 then
								ComSet:FireClient(DamagerPlayer, 'ModifyHotbar', { ToolName = 'Special Hell', Property = 'Description', Value = 'HALF WAY' })
								
							end
						end)
					end
					
					
					if not Damager:HasTag('Awakened') then
						DamagerPlayer.AwakeningProgress.Value += Damage/3
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


--Leaving connections

Players.PlayerRemoving:Connect(function(DamagedPlayer: Player)
	local Damaged: Model = DamagedPlayer.Character
	if Damaged:FindFirstChild('Dummy') then return end
	if not Damaged then return end
	
	local LastHitFrom = Damaged:GetAttribute("LastHitBy")
	if not LastHitFrom then return end
	
	
	local DamagerPlayer: Player = Players:GetPlayerByUserId(LastHitFrom)
	if not DamagerPlayer or DamagerPlayer == DamagedPlayer then return end
	
	local Damager: Model = DamagerPlayer.Character
	if not DamagerPlayer.Character then return end
	
	
	local DealtDamage = 0
	for Name, Value in Damaged:GetAttributes() do
		if Name:find("_Dealt_Damage") and typeof(Value) == "number" then
			DealtDamage += Value
		end
	end
	if DealtDamage <= 0 then return end
	
	
	if Damager == Damaged then return end
	local IsVIP = DamagerPlayer:GetAttribute("HasVIP")
	
	
	pcall(function()
		KillMessagesModule.SendMessage(Damaged, Damager, IsVIP)
	end)
	
	
	local Kills = DamagerPlayer.leaderstats:FindFirstChild("Kills", true)
	if Kills then
		Kills.Value += 1
	end

	local TotalKills = DamagerPlayer.leaderstats:FindFirstChild("Total Kills", true)
	if TotalKills then
		TotalKills.Value += 1
	end


	Damager:SetAttribute('Streak', (Damager:GetAttribute('Streak') or 0) + 1)
	
	local playerClass = shared.playerClasses[DamagerPlayer.UserId]
	if playerClass then
		if Damager:GetAttribute("Streak") > playerClass.TitlesProgress.Killstreak then
			playerClass.TitlesProgress.Killstreak = Damager:GetAttribute("Streak")
			DamagerPlayer:SetAttribute("KillstreakProgress", playerClass.TitlesProgress.Killstreak)
		end
		
		
		if Damager:GetAttribute('Streak') >= 30 then
			if playerClass.CompletedQuest ~= true then
				playerClass.CompletedQuest = true
			end
		end
		
		
		local BonusGold = math.clamp((Damager:GetAttribute('Streak') or 1 - 1) * 5, 0, 450)
		local GoldAmouth = IsVIP and 50 or 30 + BonusGold
		
		
		playerClass.Gold += GoldAmouth
		DamagerPlayer:SetAttribute("Gold", playerClass.Gold)
		
		
		ComSet:FireClient(DamagerPlayer, "SendNotification", { Text = "Earned " .. GoldAmouth .. " gold. (Streak: " .. tostring(Damager:GetAttribute('Streak') or 1) .. ")" })
	end
	
	
	if Damager:GetAttribute('Streak') >= 10 and not Damager:HasTag('HighestStreak') then
		KillstreakModule:AddKillstreak(Damager)
	end
	
	
	if #playerClass.OwnedEmotes < #RS.Resources.Emotes.Animations:GetChildren() then
		if playerClass.KillsForEmote > 0 then
			playerClass.KillsForEmote -= 1
			
			if playerClass.KillsForEmote == 0 then
				ComSet:FireClient(DamagerPlayer, 'CanSpinEmote')
			else
				ComSet:FireClient(DamagerPlayer, 'ChangeKillForEmote', playerClass.KillsForEmote)
			end
		end
	end
	
	ComSet:FireClient(DamagerPlayer, "SendNotification", { Text = "Kill awarded because" .. DamagedPlayer.Name .. "left mid-fight."})
end)


return module
