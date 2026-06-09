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
		local Janitor = Trove.new()
		
		
		local StartupAnimation = MoveAnims["The Dark Lord"]["Merciless Sequence"].Startup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit, Finisher = false, false
		local Container, Assets = {}, {}
		

		local function MoveDude(Params)
			for _, v in pairs(Container) do
				v:Destroy()
			end

			local BodyVelocity = Janitor:Add(Instance.new("BodyVelocity"))

			table.insert(Assets, BodyVelocity)
			table.insert(Container, BodyVelocity)

			BodyVelocity.Name = "moveme"
			BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
			BodyVelocity:SetAttribute("Speed", Params.speed or 100)
			BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
			BodyVelocity:SetAttribute("End", Params.endd or 5)
			BodyVelocity.Parent = HumRP

			Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
		end
		
		
		table.insert(StartEvents, Janitor:Add(StartupTrack:GetMarkerReachedSignal("hitreg"):Once(function() --ts so dumb gng
			--Simple once or normalized :pray:
			
			--Their moves are simple whatever lmao
			pcall(function()
				MoveDude({ speed = 80, fallout = 0.9, endd = 3, deletiontime = 0.2 })
			end)
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(9, 8.5, 8), CFrame.new(0, 0, -4.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then --i dont think this can grab ragdolled idk i never played anim bg
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "NoCol")
				
				
				local UserAnimation = MoveAnims["The Dark Lord"]["Merciless Sequence"].User
				local VictimAnimation = MoveAnims["The Dark Lord"]["Merciless Sequence"].Victim
				
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1) --idk abt this
				
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("Damage"):Once(function()
					MoveDude({ speed = 80, fallout = 0.9, endd = 3, deletiontime = 0.2 })
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, false, false, false, true, false, nil, nil)
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3 } })
				end)))
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("Up"):Once(function()
					MoveDude({ speed = 100, fallout = 0.98, endd = 5, deletiontime = 0.3 })
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2, Last = 0.5 } })
				end)))
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("Throw"):Once(function()
					pcall(function()
						for _, v in Assets do
							if not v.Parent then continue end

							v:Destroy()
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
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, false, true, true, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 10, 0) })
					
					
					task.delay(0.5, function()
						local Dropped = false

						for i = 1, 100 do
							if Dropped ~= true and EnemyHumRP then
								if workspace:Raycast(EnemyHumRP.Position, Vector3.new(0, -5, 0), MapRayParams) then
									Dropped = true

									ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
									shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8 } })
								end

								task.wait(0.1)
							else
								break
							end
						end
					end)
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2 } })
				end)))
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("End"):Once(function()
					if Finisher == true then return end
					
					if Janitor then
						pcall(function()
							Janitor:Destroy()
						end)
						Janitor = nil
					end
					
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					for _, v in Assets do
						if not v.Parent then continue end

						v:Destroy()
					end
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
				end)))
				
				
				VictimTrack.Stopped:Once(function()
					if Finisher == true then return end
					
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
					if Finisher == true then return end
					
					if Janitor then
						pcall(function()
							Janitor:Destroy()
						end)
						Janitor = nil
					end
					
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					for _, v in Assets do
						if not v.Parent then continue end

						v:Destroy()
					end
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
				end)
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				
				Weld:Start(nil, EnemyPlayer or Player)
				
				ReplicateEffects_Set:FireAllClients("MercilessSequence", { Stage = "Hit", Char = Character })
			end)
		end)))
		
		
		StartupTrack.Stopped:Once(function()
			if not Hit then
				if Janitor then
					pcall(function()
						Janitor:Destroy()
					end)
					Janitor = nil
				end
				for _, v in Assets do
					if not v.Parent then continue end

					v:Destroy()
				end
				
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
	end
}