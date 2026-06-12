local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)

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
	workspace.Map.Borders,
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 5, 0, true)
		iFramesService:AddAlliFrames(Character)

		local StartupAnimation = MoveAnims["Hero Hunter"]["WS Rock Smashing Fist"].User
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)

		local Bind = Instance.new("Accessory")
		Bind:SetAttribute("Delay", 0)
		Bind:SetAttribute("Times", 1.16)
		Bind.Parent = Character

		local BarrageTime = false
		local GrabbedEnemy = nil
		local Weld = nil
		local EnemyStun = nil

		table.insert(
			StartupEvents,
			StartupTrack:GetMarkerReachedSignal("start"):Once(function()
				ReplicateEffects_Set:FireAllClients(
					"PunchBarrage",
					{ Character = Character, Bind = Bind, Hunter = true }
				)
				BarrageTime = true

				while BarrageTime == true do
					HitboxHandler:SimpleOnce(
						HumRP,
						Vector3.new(4, 8, 8),
						CFrame.new(0, 0, -3),
						{ Character },
						nil,
						nil,
						function(EnemyCharacter: Model)
							local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
							local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
							local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

							if
								iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
								or EnemyCharacter:FindFirstChild("Ragdolled")
							then
								return
							end

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								1.3,
								nil,
								CombatAnims.Hits[tostring(math.random(1, 4))],
								false,
								EnemyCharacter:HasTag("DEATH") and true or false,
								true,
								true,
								false,
								nil
							)
							if HitInfo.Countered == true then
								return
							end

							shared.fireTo(
								ReplicateEffects_Set,
								{ Player, EnemyPlayer },
								{ "ShakeCamera", { Intensity = 1 } }
							)
						end
					)

					task.wait(0.1)
				end
			end)
		)

		table.insert(
			StartupEvents,
			StartupTrack:GetMarkerReachedSignal("end"):Once(function()
				BarrageTime = false
				if Bind then
					Bind:Destroy()
					Bind = nil
				end
			end)
		)

		table.insert(
			StartupEvents,
			StartupTrack:GetMarkerReachedSignal("grab"):Once(function()
				HitboxHandler:SimpleOnce(
					HumRP,
					Vector3.new(4, 8, 8),
					CFrame.new(0, 0, -3),
					{ Character },
					nil,
					nil,
					function(EnemyCharacter: Model)
						local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
						local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

						if
							GrabbedEnemy
							or iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
							or EnemyCharacter:FindFirstChild("Ragdolled")
						then
							return
						end
						GrabbedEnemy = EnemyCharacter

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
						end

						Weld = WeldSystem.new(
							Character:FindFirstChild("Right Arm"),
							EnemyCharacter:FindFirstChild("Head"),
							CFrame.new(0, 0, 0),
							-1
						)
						EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

						Character:AddTag("CantRotate")
						EnemyCharacter:AddTag("CantRotate")

						iFramesService:AddAlliFrames(Character)
						iFramesService:AddAlliFrames(EnemyCharacter)

						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "NoCol")

						Weld:Start(nil, EnemyPlayer, Player)

						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 3.5 } }
						)
					end
				)
			end)
		)

		table.insert(
			StartupEvents,
			StartupTrack:GetMarkerReachedSignal("slam"):Once(function()
				if GrabbedEnemy ~= nil and GrabbedEnemy then
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(GrabbedEnemy)
					local EnemyHumanoid: Humanoid = GrabbedEnemy.Humanoid
					local EnemyHumRP: BasePart = GrabbedEnemy.HumanoidRootPart

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					task.spawn(function()
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 6 } }
						)

						local Attachment = Instance.new("Attachment", workspace.Terrain)
						Attachment.Position = EnemyHumRP.Position
						Attachment.Orientation = Vector3.new(90, 0, 0)

						ReplicateEffects_Set:FireAllClients("Ground Crater", {
							Seed = math.random(1, 2147483647),
							amount = 6,
							start = Attachment.Position,
							size = 0.3,
							["end"] = Vector3.new(0, -14, 0),
							nosound = true,
						})

						ReplicateEffects_Set:FireAllClients("Ground Crater", {
							nosmoke = true,
							Seed = math.random(1, 2147483647),
							amount = 15,
							start = Attachment.Position,
							size = 1.8,
							["end"] = Vector3.new(0, -14, 0),
							nosound = true,
						})

						Debris:AddItem(Attachment, 2)
						EnemyHumRP.CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0)

						HitboxHandler:SimpleOnce(
							HumRP,
							Vector3.new(30, 30, 30),
							CFrame.new(0, 0, 0),
							{ Character, GrabbedEnemy },
							nil,
							nil,
							function(EnemyCharacter2: Model)
								local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
								local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

								if EnemyCharacter2:GetAttribute("iFrames") >= 2 then
									return
								end

								DamageHandler:TakeDamage(
									Character,
									EnemyHumanoid2,
									12,
									nil,
									nil,
									false,
									false,
									false,
									true,
									true,
									nil,
									nil
								)
								RagdollHandler.ragdoll(EnemyHumanoid2, 2)
								NewKnockback:Knockback(
									EnemyCharacter2,
									{
										KnockbackType = "Velocity",
										MaxForce = Vector3.new(1, 100000, 1),
										Velocity = HumRP.CFrame.UpVector * 85,
									}
								)
							end
						)
					end)

					StunHandler:Unstun(GrabbedEnemy, EnemyStun)
					GrabbedEnemy:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(GrabbedEnemy)
					CollisionsModule:SetCollisionGroup(GrabbedEnemy, "Players")

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						26,
						nil,
						nil,
						false,
						false,
						true,
						false,
						true,
						nil,
						nil
					)
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
				end
			end)
		)

		StartupTrack.Stopped:Once(function()
			if GrabbedEnemy ~= nil and GrabbedEnemy then
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				StunHandler:Unstun(GrabbedEnemy, EnemyStun)
				GrabbedEnemy:RemoveTag("CantRotate")
				iFramesService:RemoveAlliFrames(GrabbedEnemy)
				CollisionsModule:SetCollisionGroup(GrabbedEnemy, "Players")
			end

			BarrageTime = false
			if Bind then
				Bind:Destroy()
				Bind = nil
			end

			StunHandler:Unstun(Character, Stun)
			Character:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Character)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
	end,
}
