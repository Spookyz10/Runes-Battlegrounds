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
	workspace.Map
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
		
		
		local MissAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Doom Dive"].Miss
		local MissTrack, MissEvents = AnimationService:getAnimationTrack(Character, MissAnimation)
		
		
		local jumpmoveme = Instance.new("BodyVelocity")
		jumpmoveme.MaxForce = Vector3.new(40000, 40000, 40000)
		jumpmoveme.Name = "moveme"
		jumpmoveme:SetAttribute("Aerial", 130)
		jumpmoveme:SetAttribute("AerialDecrease", 0.975)
		jumpmoveme:SetAttribute("BeganTick", tick())
		jumpmoveme:SetAttribute("End", 5)
		jumpmoveme:SetAttribute("Fallout", 0.9)
		jumpmoveme:SetAttribute("Inverted", true)
		jumpmoveme:SetAttribute("Monster", true)
		jumpmoveme:SetAttribute("RemoveOthers", true)
		jumpmoveme:SetAttribute("Speed", 90)
		
		
		local Dived = false
		
		
		local function Dive()
			Dived = true
			ReplicateEffects_Set:FireClient(Player, "StayVelocity", { MaxDistance = 60, Time = 0.1 })
			
			local DiveAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Doom Dive"].Dive
			local DiveTrack, DiveEvents = AnimationService:getAnimationTrack(Character, DiveAnimation)
			
			
			local function Land(hitPosition)
				local PositionValue = Character:FindFirstChild("MonsterPosConfrim")
				
				local function extractPositionFromValue(val)
					if not val then return nil end
					
					if typeof(val.Value) == "Vector3" then
						return val.Value
					end
					
					if typeof(val.Value) == "CFrame" then
						return val.Value.Position
					end
					
					if typeof(val.Value) == "Instance" and val.Value.Position then
						return val.Value.Position
					end
					
					if typeof(val) == "Vector3" then
						return val
					end
					
					return nil
				end
				
				
				local preferredTargetPos = extractPositionFromValue(PositionValue)
				local finalLandPos = nil
				
				
				if hitPosition then
					finalLandPos = hitPosition
				else
					if preferredTargetPos then
						local downOrigin = preferredTargetPos + Vector3.new(0, 5, 0)
						local downResult = workspace:Raycast(downOrigin, Vector3.new(0, -200, 0), MapRayParams)
						
						if downResult then
							finalLandPos = downResult.Position
						else
							finalLandPos = preferredTargetPos
						end
					else
						finalLandPos = HumRP.Position
					end
				end
				
				
				local lookAtTarget = preferredTargetPos or HumRP.Position
				local CF = CFrame.new(finalLandPos, lookAtTarget)
				
				
				DiveTrack:AdjustSpeed(1)
				
				
				local LandAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Doom Dive"].Land
				local LandTrack, LandEvents = AnimationService:getAnimationTrack(Character, LandAnimation)
				
				
				task.spawn(function()
					ReplicateEffects_Set:FireAllClients("Ground Crater", { ["end"] = Vector3.new(0, -10, 0), start = CF.Position, Seed = math.random(1,2147483647), size = 0.2 })
					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 5 })
					
					HitboxHandler:SimpleOnce(CF.Position, Vector3.new(8, 8, 8), CFrame.new(0, 0, 0), { Character }, nil, nil, function(EnemyCharacter: Model)
						local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
						local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

						local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, true, false, true, false, false, nil, 15)
						if HitInfo.Blocked == true then return end


						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)

						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 5 })
					end)
				end)
				
				
				LandTrack.Stopped:Once(function()
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
				end)


				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, LandAnimation)

				ReplicateEffects_Set:FireAllClients("DiveEvents", { Event = "DiveImpact", Char = Character })
			end
			
			
			local LandConnection: RBXScriptConnection
			LandConnection = RunService.Heartbeat:Connect(function()
				local PositionValue = Character:FindFirstChild("MonsterPosConfrim")
				local rayOrigin = HumRP.Position
				
				if PositionValue then
					local pos = nil
					
					local ok, extracted = pcall(function()
						if typeof(PositionValue.Value) == "Vector3" then
							return PositionValue.Value
						elseif typeof(PositionValue.Value) == "CFrame" then
							return PositionValue.Value.Position
						elseif typeof(PositionValue.Value) == "Instance" and PositionValue.Value.Position then
							return PositionValue.Value.Position
						end
						
						return nil
					end)
					
					if ok and extracted then
						rayOrigin = extracted + Vector3.new(0, 5, 0)
					end
				end
				
				local result = workspace:Raycast(rayOrigin, Vector3.new(0, -200, 0), MapRayParams)
				if result then
					LandConnection:Disconnect()
					LandConnection = nil
					
					Land(result.Position)
				end
			end)
			
			
			task.delay(1.5, function()
				if LandConnection then
					LandConnection:Disconnect()
					LandConnection = nil
					
					Land()
				end
			end)
			
			
			table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("start"):Once(function()
				ReplicateEffects_Set:FireAllClients("DiveEvents", { Event = "Dive", Char = Character })
			end))
			
			table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("freeze"):Once(function()
				DiveTrack:AdjustSpeed(0)
			end))
			
			
			DiveTrack.Stopped:Once(function()
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end)
			
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, DiveAnimation)
			
			ReplicateEffects_Set:FireAllClients("DiveEvents", { Event = "PreDive", Char = Character })
		end
		
		
		table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("jump"):Once(function()
			if jumpmoveme then
				jumpmoveme.Parent = HumRP
			end
			
			ReplicateEffects_Set:FireAllClients("DiveEvents", { Event = "FirstEvent", Char = Character })
			
			task.delay(0.2, function()
				local UsedTwice = false
				Character:SetAttribute("DoomDiveTwice", true)

				local Changed = Character:GetAttributeChangedSignal("DoomDiveTwice"):Once(function()
					UsedTwice = true

					Dive()
				end)
				
				task.delay(1, function()
					if UsedTwice then return end
					Changed:Disconnect()
					Character:SetAttribute("DoomDiveTwice", nil)
				end)
			end)
		end))
		
		table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("end"):Once(function()
			
		end))
		
		
		MissTrack.Stopped:Once(function()
			if jumpmoveme then
				jumpmoveme:Destroy()
				jumpmoveme = nil
			end
			
			if not Dived then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation)
		
		ReplicateEffects_Set:FireAllClients("DiveEvents", { Event = "Start", Char = Character })
	end
}