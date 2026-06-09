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
		
		
		local StartupAnimation = MoveAnims["The Dark Lord"]["Spear of Justice"].Startup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Assets = {}
		local Hit = false
		
		
		table.insert(StartEvents, StartupTrack:GetMarkerReachedSignal("hitreg"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(6, 5, 9), CFrame.new(0, 0, -3.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or (EnemyCharacter:FindFirstChild("Ragdolled") and not EnemyCharacter:FindFirstChild('inAir')) then return end
				
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
				
				local UserAnimation = MoveAnims["The Dark Lord"]["Spear of Justice"].User
				local VictimAnimation = MoveAnims["The Dark Lord"]["Spear of Justice"].Victim
				
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				local VelocityContainer = {}
				local VelocityAssets = {}
				
				local function HandleVelocity(Params)
					for _, existingVel in pairs(VelocityContainer) do
						existingVel:Destroy()
					end
					
					local BodyVelocity = Instance.new("BodyVelocity")
					
					table.insert(VelocityAssets, BodyVelocity)
					table.insert(VelocityContainer, BodyVelocity)
					
					BodyVelocity.Name = "moveme"
					BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
					BodyVelocity:SetAttribute("Speed", Params.speed or 100)
					BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
					BodyVelocity:SetAttribute("End", Params.endd or 5)
					BodyVelocity.Parent = Character.PrimaryPart
					
					Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
				end
				HandleVelocity({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })
				
				
				local HitCount = 1
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Hit"):Connect(function()
					if HitCount == 9 then
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
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, false, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.RightVector * -80 + Vector3.new(0, 15, 0) })
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4 } })
					else
						if HitCount ~= 9 then
							HitCount += 1
						end
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2.5 } })
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.7, nil, nil, false, false, false, true, false, nil, nil)
						
						if HitCount == 2 or HitCount == 3 then
							HandleVelocity({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })
						end
						
						if HitCount == 4 then
							Character:AddTag("CantRotate")
						end
					end
				end))
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Bleed"):Connect(function()
					ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 8, force = 0.25, delay = 0.1 })
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
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					for _, v in VelocityAssets do
						if not v.Parent then continue end
						
						v:Destroy()
					end
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
				end)
				
				
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				
				Weld:Start(nil, EnemyPlayer or Player)
				
				
				ReplicateEffects_Set:FireAllClients("SpearOfCorruption", { Stage = "Start", Char = Character })
				
				table.insert(Assets, SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Spear of Justice"].User, HumRP))
				table.insert(Assets, SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Spear of Justice"].Victim, EnemyCharacter.Torso))
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			if not Hit then
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
		
		table.insert(Assets, SoundsModule:PlaySound(MoveSounds["The Dark Lord"]["Spear of Justice"].Startup, HumRP))
	end
}