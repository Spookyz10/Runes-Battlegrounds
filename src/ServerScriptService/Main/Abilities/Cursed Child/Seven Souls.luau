local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")


local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes


local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local WeaponsHandler = require(ServerModules.WeaponsHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)



local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models


local Weapons = Models.Weapons

local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local CombatAnims = Animations.Combat
local CombatSounds = Sounds.Combat


local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get


local ReplicateEffects_Set = RemotesContainer.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		
		local StartupAnimation = MoveAnims["Cursed Child"]["Seven Souls"].Startup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		
		
		local moveme = Instance.new("BodyVelocity")
		moveme.MaxForce = Vector3.new(100000, 0, 100000)
		moveme.Name = "moveme"
		moveme:SetAttribute("End", 1)
		moveme:SetAttribute("Fallout", 0.96)
		moveme:SetAttribute("Goto", 100)
		moveme:SetAttribute("Speed", 500)
		
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("boost"):Once(function()
			moveme.Parent = HumRP
		end))
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("chara"):Once(function()
			local DashHitbox = ReplicatedHitbox.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Vector3.new(8, 8, 14)
			DashHitbox.Offset = CFrame.new(0, 0, -4.5)
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:FindFirstChild("Ragdolled") then return end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(100000, 100000, 100000),
					Velocity = HumRP.CFrame.LookVector * 75 + HumRP.CFrame.UpVector * 30
				})
				
				pcall(function()
					DashHitbox:Destroy()
				end)
			end

			DashHitbox:Start(1.2, true)
		end))
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("jump"):Once(function()
			moveme:SetAttribute("Goto", nil)
		end))
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
			local HitboxParams = ReplicatedHitbox.new(Player)
			HitboxParams.Instance = HumRP
			HitboxParams.Size = Vector3.new(8, 8, 10)
			HitboxParams.Offset = CFrame.new(0, 0, -4.5)
			HitboxParams.Ignore = { Character }
			HitboxParams.destroyAfterOnce = true
			HitboxParams.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -7) * CFrame.Angles(0, math.pi, 0), -1)
				
				
				local MainUserAnimation = MoveAnims["Cursed Child"]["Seven Souls"].User
				local MainVictimAnimation = MoveAnims["Cursed Child"]["Seven Souls"].Victim
				
				local MainVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, MainVictimAnimation)
				local MainUserTrack, MainUserEvents = AnimationService:getAnimationTrack(Character, MainUserAnimation)
				
				
				local FirstQTESuccess = false
				local SecondQTESuccess = false
				
				
				local CharaSevenSouls = Instance.new("RemoteEvent")
				CharaSevenSouls.Name = "CharaSevenSoulsRemote"
				CharaSevenSouls.Parent = Character
				
				
				CharaSevenSouls.OnServerEvent:Connect(function(plr, IsSuccess, Mark)
					if plr ~= Player then return end
					
					local successBool = false
					if type(IsSuccess) == "boolean" then
						successBool = IsSuccess
					elseif type(IsSuccess) == "number" then
						successBool = (IsSuccess ~= 0)
					elseif type(IsSuccess) == "string" then
						successBool = (IsSuccess == "true")
					end
					
					if Mark == 2 then
						SecondQTESuccess = successBool
					else
						FirstQTESuccess = successBool
					end
				end)
				
				
				table.insert(MainUserEvents, MainUserTrack:GetMarkerReachedSignal("qte"):Once(function()
					ReplicateEffects_Set:FireClient(Player, "toggleUI", { State = false })
				end))
				
				table.insert(MainUserEvents, MainUserTrack:GetMarkerReachedSignal("on_qte"):Once(function()
					if FirstQTESuccess == false then
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						EnemyCharacter:RemoveTag("CantRotate")
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 26, nil, nil, false, false, true, false, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						NewKnockback:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(100000, 100000, 100000),
							Velocity = HumRP.CFrame.LookVector * 85 + HumRP.CFrame.UpVector * 30
						})
						
						
						local FailUserAnimation = MoveAnims["Cursed Child"]["Seven Souls"].FirstMiss
						local FailUserTrack, FailUserEvents = AnimationService:getAnimationTrack(Character, FailUserAnimation)
						
						
						
						FailUserTrack.Stopped:Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
							CollisionsModule:SetCollisionGroup(Character, "Players")
							Character:RemoveTag("CantRotate")
							
							if CharaSevenSouls then
								CharaSevenSouls:Destroy()
							end
						end)
						
						
						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)
						
						AnimationService:playAnimation(Character, FailUserAnimation)
						
						ReplicateEffects_Set:FireClient(Player, "toggleUI", { State = true })
					else
						Player:SetAttribute("Cutscenes", true)
						if EnemyPlayer then
							EnemyPlayer:SetAttribute("Cutscenes", true)
						end
					end
				end))
				
				table.insert(MainUserEvents, MainUserTrack:GetMarkerReachedSignal("big_slash"):Once(function()
					if SecondQTESuccess == false then
						task.delay(0.3, function()
							AnimationService:stopAll(EnemyCharacter)
							AnimationService:stopAll(Character)

							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 48, nil, nil, false, false, true, false, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1,1,1) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 70, 70, HumRP.CFrame.LookVector.Z * 70), Time = 0.5 })

							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
						end)
					end
				end))
				
				table.insert(MainUserEvents, MainUserTrack:GetMarkerReachedSignal("boom"):Once(function()
					if SecondQTESuccess == true then
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						EnemyCharacter:RemoveTag("CantRotate")
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, false, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 4)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 30, 800, HumRP.CFrame.LookVector.Z * 30), Time = .4 })
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
					end
				end))
				
				
				MainVictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")
					
					if EnemyPlayer then
						EnemyPlayer:SetAttribute("Cutscenes", nil)
						ReplicateEffects_Set:FireClient(EnemyPlayer, "toggleUI", { State = true })
					end
				end)

				MainUserTrack.Stopped:Once(function()
					if not FirstQTESuccess then return end
					
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
					
					if CharaSevenSouls then
						CharaSevenSouls:Destroy()
					end
					
					ReplicateEffects_Set:FireClient(Player, "toggleUI", { State = true })
					
					Player:SetAttribute("Cutscenes", nil)
				end)
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, MainUserAnimation)
				AnimationService:playAnimation(EnemyCharacter, MainVictimAnimation)
				
				
				Weld:Start()
				
				ReplicateEffects_Set:FireAllClients("SevenSouls", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, HitAnim = MainUserAnimation.AnimationId })
			end
			
			
			HitboxParams:Once()
			
			
			ReplicateEffects_Set:FireAllClients("SevenSouls", { Stage = "Slash", Char = Character })
		end))
		
		
		StartupTrack.Stopped:Once(function()
			if moveme then
				moveme:Destroy()
				moveme = nil
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("SevenSouls", { Stage = "Start", Char = Character, StartAnim = StartupAnimation.AnimationId })
	end
}