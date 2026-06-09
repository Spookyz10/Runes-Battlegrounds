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
local Trove = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local VfxUtility = services:GetService("VFX_Utility")
local knockbackService = services:GetService("KnockbackService")


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
MapRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena, 
	workspace.Map.Miscellaneous, 
	workspace.Map.Borders
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddBaseiFrames(Character)
		
		
		local StartupAnimation = MoveAnims["The Dark Lord"]["Pure Brutality"].Startup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Assets = {}
		local Hit = false
		
		
		local moveme = Instance.new("BodyVelocity")
		moveme.MaxForce = Vector3.new(100000, 0, 100000)
		moveme.Name = "moveme"
		moveme:SetAttribute("End", 1)
		moveme:SetAttribute("Fallout", 0.96)
		moveme:SetAttribute("Goto", 10)
		moveme:SetAttribute("Speed", 15)
		
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("hitreg"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(8, 8, 8), CFrame.new(0, 0, -3.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), -1)
				
				local UserAnimation = MoveAnims["The Dark Lord"]["Pure Brutality"].User
				local VictimAnimation = MoveAnims["The Dark Lord"]["Pure Brutality"].Victim
				
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Step"):Once(function()
					moveme.Parent = HumRP
				end))
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Slam"):Once(function()
					task.spawn(function()
						local SpearWeapon = Character:FindFirstChild("SpearWeapon")

						if SpearWeapon then
							for _,v in SpearWeapon:GetChildren() do
								if v:IsA("MeshPart") then
									v.Transparency = 1
								end
							end
						end
					end)
					
					if moveme then
						moveme:Destroy()
						moveme = nil
					end
					HumRP.Anchored = true
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, false, true, false, nil, nil)
					
					ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5 } })
					
					HitboxHandler:SimpleOnce(HumRP, Vector3.new(11, 11, 11), CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
						local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
						local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

						if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid2, 12, nil, nil, false, false, false, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid2, 2)
						NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
					end)
				end))
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Damage"):Connect(function()
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4 } })
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.3, nil, nil, false, false, false, true, false, nil, nil)
				end))
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("LastDamage"):Once(function()
					task.spawn(function()
						local SpearWeapon = Character:FindFirstChild("SpearWeapon")

						if SpearWeapon then
							for _,v in SpearWeapon:GetChildren() do
								if v:IsA("MeshPart") then
									v.Transparency = 0
								end
							end
						end
					end)
					
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
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, false, true, true, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					
					if HitInfo.Finisher == true then
						local Head = EnemyCharacter:FindFirstChild("Head")
						
						if Head then
							pcall(function()
								Head.Transparency = 1
							end)
							
							if EnemyCharacter:FindFirstChild("FakeHead") then
								ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyCharacter.FakeHead, times = 8, force = 1, delay = 0.1 })
							end
						end
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, false, true, true, nil, nil)
						
						SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Pure Brutality"].Voiceline, HumRP)
					else
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 55 + Vector3.new(0, 10, 0) })
					end
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 6 } })
					ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
					
					HitboxHandler:SimpleOnce(HumRP, Vector3.new(11, 11, 11), CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
						local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
						local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

						if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end

						DamageHandler:TakeDamage(Character, EnemyHumanoid2, 12, nil, nil, false, false, false, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid2, 2)
						NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
					end)
				end))
				
				
				VictimTrack.Stopped:Once(function()
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
				end)
				
				UserTrack.Stopped:Once(function()
					if moveme then
						moveme:Destroy()
						moveme = nil
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
					
					if HumRP then
						HumRP.Anchored = false
					end
				end)
				
				
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				
				Weld:Start(nil, EnemyPlayer or Player)
				
				
				ReplicateEffects_Set:FireAllClients("PureBrutality", { Stage = "Start", Char = Character })
				
				SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Pure Brutality"].Hit, HumRP)
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			if not Hit then
				if moveme then
					moveme:Destroy()
					moveme = nil
				end
				
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			else
				for _, v in Assets do
					if not v.Parent then continue end

					v:Destroy()
				end
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		table.insert(Assets, SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Pure Brutality"].Startup, HumRP))
	end
}