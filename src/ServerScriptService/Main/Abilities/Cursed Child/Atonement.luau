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
		
		
		local StartupAnimation = MoveAnims["Cursed Child"].Atonement.Windup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local StartCF = HumRP.CFrame
		
		local Hit = false
		
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("hit"):Connect(function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(7, 7, 10)
			Hitbox.Offset = CFrame.new(0, 0, -4.5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
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
					Hitbox:Destroy()
				end)
			end
			
			Hitbox:Start(0.2, true)
		end))
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("grab"):Connect(function()
			local GrabHitbox = ReplicatedHitbox.new(Player)
			GrabHitbox.Instance = HumRP
			GrabHitbox.Size = Vector3.new(7, 7, 10)
			GrabHitbox.Offset = CFrame.new(0, 0, -4.5)
			GrabHitbox.Ignore = { Character }
			GrabHitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:FindFirstChild("Ragdolled") then return end
				
				Hit = true
				
				pcall(function()
					GrabHitbox:Destroy()
				end)
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				task.delay(0.4, function()
					EnemyHumRP.Anchored = true
				end)
				
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
				
				
				local MainUserAnimation = MoveAnims["Cursed Child"].Atonement.Hit
				local MainVictimAnimation = MoveAnims["Cursed Child"].Atonement.VictimHit
				
				local MainVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, MainVictimAnimation)
				local MainUserTrack, MainUserEvents = AnimationService:getAnimationTrack(Character, MainUserAnimation)
				
				
				local RemoteConnection: RBXScriptConnection
				RemoteConnection = RemotesContainer.Atonement.Main.OnServerEvent:Connect(function(Plr: Player, Action: string, Num: number)
					if not EnemyCharacter or not EnemyCharacter.Parent or Plr ~= EnemyPlayer then return end

					if Action == "Damage" then
						local Damage = tonumber(Num)
						if not Damage then return end
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, Damage * 1.5, nil, nil, false, false, false, true, false, nil, nil)
					end
				end)
				
				
				local function UserEnd()
					if RemoteConnection then
						RemoteConnection:Disconnect()
						RemoteConnection = nil
					end
					
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
				end
				
				local function EnemyEnd()
					if RemoteConnection then
						RemoteConnection:Disconnect()
						RemoteConnection = nil
					end
					
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
				end
				
				
				table.insert(MainUserEvents, MainUserTrack:GetMarkerReachedSignal("End"):Once(function()
					if EnemyPlayer then
						RemotesContainer.Atonement.Main:FireClient(EnemyPlayer, "Stop")
					end
					
					local ChanceBased = math.random(1, 2) == 1
					if EnemyHumanoid.Health <= 14 or (EnemyCharacter:FindFirstChild("Dummy") and ChanceBased) then
						local WinUserAnimation = MoveAnims["Cursed Child"].Atonement.Win.UserWin
						local WinVictimAnimation = MoveAnims["Cursed Child"].Atonement.Win.VictimWin

						local WinVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, WinVictimAnimation)
						local WinUserTrack, WinUserEvents = AnimationService:getAnimationTrack(Character, WinUserAnimation)
						
						
						if EnemyHumRP then
							EnemyHumRP.Anchored = false
						end
						
						if EnemyPlayer then
							EnemyPlayer:SetAttribute("Cutscenes", true)
						end
						Player:SetAttribute("Cutscenes", true)
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = false }})
						
						
						table.insert(WinUserEvents, WinUserTrack:GetMarkerReachedSignal("Kill"):Once(function()
							EnemyEnd()
							
							if EnemyHumRP then
								EnemyHumRP.Anchored = false
							end

							if EnemyPlayer then
								EnemyPlayer:SetAttribute("Cutscenes", nil)
							end
							
							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, false, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2)
							
							Character:SetPrimaryPartCFrame(CFrame.lookAlong(ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position, -HumRP.CFrame.LookVector))
							EnemyCharacter:SetPrimaryPartCFrame(HumRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0))
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
						end))
						
						
						WinVictimTrack.Stopped:Once(function()
							EnemyEnd()
							
							if EnemyHumRP then
								EnemyHumRP.Anchored = false
							end
							
							if EnemyPlayer then
								EnemyPlayer:SetAttribute("Cutscenes", nil)
								ReplicateEffects_Set:FireClient(EnemyPlayer, "toggleUI", { State = true })
							end
						end)
						
						WinUserTrack.Stopped:Once(function()
							UserEnd()
							
							Player:SetAttribute("Cutscenes", nil)
							ReplicateEffects_Set:FireClient(Player, "toggleUI", { State = true })
						end)
						
						
						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(Character, WinUserAnimation)
						AnimationService:playAnimation(EnemyCharacter, WinVictimAnimation)
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "Atonement", { Stage = "Win", Char = Character, EChar = EnemyCharacter, WinAnim = WinUserAnimation.AnimationId } })
					else
						local FailUserAnimation = MoveAnims["Cursed Child"].Atonement.Lose.UserLose
						local FailVictimAnimation = MoveAnims["Cursed Child"].Atonement.Lose.VictimLose
						
						local FailVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FailVictimAnimation)
						local FailUserTrack, FailUserEvents = AnimationService:getAnimationTrack(Character, FailUserAnimation)
						
						
						local HitCount = 1
						
						table.insert(FailUserEvents, FailUserTrack:GetMarkerReachedSignal("Hit"):Connect(function()
							if HitCount == 2 then
								EnemyEnd()
								
								if EnemyHumRP then
									EnemyHumRP.Anchored = false
								end
								
								DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, false, true, nil, nil)
								RagdollHandler.ragdoll(EnemyHumanoid, 2)
								NewKnockback:Knockback(EnemyCharacter, {
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(100000, 100000, 100000),
									Velocity = HumRP.CFrame.LookVector * 85 + HumRP.CFrame.UpVector * 30
								})
							else
								HitCount += 1
								DamageHandler:TakeDamage(EnemyCharacter, Humanoid, 16, nil, nil, false, false, false, true, false, nil, nil)
							end
						end))
						
						
						FailVictimTrack.Stopped:Once(function()
							EnemyEnd()
							
							if EnemyHumRP then
								EnemyHumRP.Anchored = false
							end
						end)
						
						FailUserTrack.Stopped:Once(function()
							UserEnd()
						end)
						
						
						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(Character, FailUserAnimation)
						AnimationService:playAnimation(EnemyCharacter, FailVictimAnimation)
						
						
						ReplicateEffects_Set:FireAllClients("Atonement", {
							Stage = "Lose",
							Char = Character,
							EChar = EnemyCharacter,
							LoseAnim = FailUserAnimation.AnimationId,
							LoseAnimVictim = FailVictimAnimation.AnimationId
						})
					end
				end))
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, MainUserAnimation)
				AnimationService:playAnimation(EnemyCharacter, MainVictimAnimation)
				
				
				Weld:Start()
				if EnemyPlayer then
					RemotesContainer.Atonement.Main:FireClient(EnemyPlayer, "Start")
				end
				
				ReplicateEffects_Set:FireAllClients("Atonement", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, HitAnim = MainUserAnimation.AnimationId })
			end
			
			GrabHitbox:Start(0.65, true)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		ReplicateEffects_Set:FireAllClients("Atonement", { Stage = "Start", Char = Character, StartAnim = StartupAnimation.AnimationId })
	end
}