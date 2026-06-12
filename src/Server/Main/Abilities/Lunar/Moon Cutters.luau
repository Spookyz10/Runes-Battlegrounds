local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local BodymoverService = require(ServerModules.BodymoverService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)

local WeldSystem = require(ReplicatedModules.WeldSystem)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = RemotesContainer.Replicate.Set

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart
		local Humanoid = Character.Humanoid

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local StartAnimation = MoveAnims.Lunar["Moon Cutters Start"]
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)

		local Hit = false
		local EnemyCharacter = nil
		local EnemyStun = nil
		local Weld = nil

		table.insert(
			StartEvents,
			StartTrack:GetMarkerReachedSignal("grab"):Once(function()
				HitboxHandler:SimpleOnce(
					HumRP,
					Vector3.new(8, 10, 8),
					CFrame.new(0, 0, -4),
					{ Character },
					nil,
					nil,
					function(HitCharacter)
						local EnemyPlayer = Players:GetPlayerFromCharacter(HitCharacter)
						local EnemyHumanoid = HitCharacter.Humanoid
						local EnemyHumRP = HitCharacter.HumanoidRootPart

						if
							Hit
							or iFramesService:HasiFrame(HitCharacter, Tool.Name)
							or EnemyHumanoid.Health <= 0
							or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
						then
							return
						end

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							4,
							nil,
							nil,
							true,
							true,
							true,
							false,
							false,
							nil,
							nil
						)

						if HitInfo.Countered or HitInfo.Blocked then
							return
						end

						Hit = true
						EnemyCharacter = HitCharacter

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
						end

						EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
						EnemyCharacter:AddTag("CantRotate")

						iFramesService:AddAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")

						Weld =
							WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
						Weld:Start(nil, EnemyPlayer, Player)

						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Lunar["Moon Cutters Victim Hold"])

						ReplicateSet:FireAllClients("MoonCutters", {
							Stage = "Grab",
							Char = Character,
							EChar = EnemyCharacter,
						})

						if EnemyPlayer then
							ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 3 })
						end
					end
				)
			end)
		)

		table.insert(
			StartEvents,
			StartTrack:GetMarkerReachedSignal("launch"):Once(function()
				if not Hit or not EnemyCharacter or not EnemyCharacter.Parent then
					return
				end

				local EnemyHumRP = EnemyCharacter.HumanoidRootPart

				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				Character:AddTag("CantRotate")
				Humanoid.AutoRotate = false

				local LaunchDirection = HumRP.CFrame.LookVector

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

				BodymoverService:Knockback(EnemyCharacter, {
					KnockbackType = "VelocityTweenDown",
					MaxForce = Vector3.new(math.huge, math.huge, math.huge),
					Velocity = LaunchDirection * 65 + Vector3.new(0, 30, 0),
					Time = 1.8,
					Style = "Sine",
					Direction = "Out",
				})

				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.Lunar["Moon Cutters Victim Air"])

				ReplicateSet:FireAllClients("MoonCutters", {
					Stage = "Launch",
					Char = Character,
					EChar = EnemyCharacter,
					Direction = LaunchDirection,
				})

				-- Inicia sequência de moon cutters com a animação do user
				local UserAnimation = MoveAnims.Lunar["Moon Cutters User"]
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

				local CutterDamages = { 8, 8, 10 }

				local function fireCutter(index)
					if not EnemyCharacter or not EnemyCharacter.Parent then
						return
					end

					local EnemyHum = EnemyCharacter.Humanoid
					if EnemyHum.Health <= 0 then
						return
					end

					DamageHandler:TakeDamage(
						Character,
						EnemyHum,
						CutterDamages[index] or 8,
						nil,
						nil,
						false,
						false,
						true,
						true,
						false,
						nil,
						nil
					)

					ReplicateSet:FireAllClients("MoonCutters", {
						Stage = "Cutter",
						Index = index,
						Char = Character,
						EChar = EnemyCharacter,
						UserHumRP = HumRP,
					})

					local EnemyPlr = Players:GetPlayerFromCharacter(EnemyCharacter)
					if EnemyPlr then
						ReplicateSet:FireClient(EnemyPlr, "ShakeCamera", { Intensity = 2 })
					end
					ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1.5 })
				end

				for i = 1, 3 do
					local markerName = "cutter" .. tostring(i)
					table.insert(
						UserEvents,
						UserTrack:GetMarkerReachedSignal(markerName):Once(function()
							fireCutter(i)
						end)
					)
				end

				table.insert(
					UserEvents,
					UserTrack:GetMarkerReachedSignal("final"):Once(function()
						if not EnemyCharacter or not EnemyCharacter.Parent then
							return
						end

						local EnemyHum = EnemyCharacter.Humanoid
						local EnemyHumRP2 = EnemyCharacter.HumanoidRootPart
						local EnemyPlr = Players:GetPlayerFromCharacter(EnemyCharacter)

						EnemyHumRP2.AssemblyLinearVelocity = Vector3.zero

						DamageHandler:TakeDamage(
							Character,
							EnemyHum,
							14,
							nil,
							nil,
							false,
							false,
							true,
							true,
							true,
							nil,
							nil
						)

						BodymoverService:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(math.huge, math.huge, math.huge),
							Velocity = HumRP.CFrame.LookVector * 80 + Vector3.new(0, 25, 0),
						})

						RagdollHandler.ragdoll(EnemyHum, 2.5)

						if EnemyStun then
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyStun = nil
						end
						EnemyCharacter:RemoveTag("CantRotate")
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						ReplicateSet:FireAllClients("MoonCutters", {
							Stage = "Final",
							Char = Character,
							EChar = EnemyCharacter,
						})

						if EnemyPlr then
							ReplicateSet:FireClient(EnemyPlr, "ShakeCamera", { Intensity = 7 })
						end
						ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 5 })
					end)
				)

				UserTrack.Stopped:Once(function()
					for _, v in UserEvents do
						v:Disconnect()
					end

					Character:RemoveTag("CantRotate")
					Humanoid.AutoRotate = true

					if EnemyCharacter and EnemyCharacter.Parent then
						if EnemyStun then
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyStun = nil
						end
						EnemyCharacter:RemoveTag("CantRotate")
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					end

					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					StunHandler:Unstun(Character, Stun)
				end)

				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, UserAnimation)
			end)
		)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do
				v:Disconnect()
			end

			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end

			if not Hit then
				Character:RemoveTag("CantRotate")
				Humanoid.AutoRotate = true
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				StunHandler:Unstun(Character, Stun)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}
