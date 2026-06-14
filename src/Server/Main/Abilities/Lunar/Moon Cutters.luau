local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModule = require(ServerModules.KnockbackModule)
local RagdollHandler = require(ServerModules.RagdollHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)

local WeldSystem = require(ReplicatedModules.WeldSystem)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = RemotesContainer.Replicate.Set

local HIT_DAMAGE = { 8, 8, 10 }
local FINAL_DAMAGE = 30
local AOE_DAMAGE = 15

local HIT_SIZE = Vector3.new(8, 8, 9)
local HIT_OFFSET = CFrame.new(0, 0, -4.5)

local GRAB_SIZE = Vector3.new(10, 10, 10)
local GRAB_OFFSET = CFrame.new(0, 0, -4)

local WELD_OFFSET = CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart
		local Humanoid = Character.Humanoid

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Lunar["Moon Cutters"]
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local GrabbedEnemy = nil
		local EnemyStun = nil
		local Weld = nil

		-- ────────────────────────────────────────────────
		-- hit1 / hit2 / hit3
		-- ────────────────────────────────────────────────
		for i = 1, 3 do
			local markerName = "hit" .. i
			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal(markerName):Once(function()
					local localHitList = {}

					HitboxHandler:SimpleOnce(
						HumRP,
						HIT_SIZE,
						HIT_OFFSET,
						{ Character },
						nil,
						nil,
						function(EnemyCharacter)
							if table.find(localHitList, EnemyCharacter) then
								return
							end

							local EnemyHumanoid = EnemyCharacter.Humanoid
							if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
								return
							end
							if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
								return
							end
							if EnemyCharacter:HasTag("Ragdolled") then
								return
							end

							table.insert(localHitList, EnemyCharacter)

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								HIT_DAMAGE[i] or 8,
								nil,
								nil,
								true,
								true,
								true,
								true,
								false,
								nil,
								nil
							)

							if HitInfo.Countered or HitInfo.Blocked then
								return
							end

							StunHandler:Stun(EnemyCharacter, 1, true, 0, 0, true)

							local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
							if EnemyPlayer then
								ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 1.5 })
							end

							ReplicateSet:FireAllClients("MoonCuttersHit", {
								Index = i,
								Char = Character,
							})
						end
					)
				end)
			)
		end

		-- ────────────────────────────────────────────────
		-- finalstart — pega o inimigo mais próximo e welda
		-- ────────────────────────────────────────────────
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("finalstart"):Once(function()
				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = { workspace.Live }

				local parts = workspace:GetPartBoundsInBox(HumRP.CFrame * GRAB_OFFSET, GRAB_SIZE, overlapParams)

				local closestEnemy = nil
				local closestDist = math.huge

				for _, part in parts do
					local char = part.Parent
					if not char or char == Character then
						continue
					end
					local hum = char:FindFirstChild("Humanoid")
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if not hum or not hrp then
						continue
					end
					if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
						continue
					end
					if char:HasTag("Ragdolled") then
						continue
					end
					if iFramesService:HasiFrame(char, Tool.Name) then
						continue
					end
					local dist = (hrp.Position - HumRP.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						closestEnemy = char
					end
				end

				if not closestEnemy then
					return
				end

				GrabbedEnemy = closestEnemy
				local EnemyHumanoid = GrabbedEnemy.Humanoid
				local EnemyHumRP = GrabbedEnemy.HumanoidRootPart
				local EnemyPlayer = Players:GetPlayerFromCharacter(GrabbedEnemy)

				-- initial grab damage
				DamageHandler:TakeDamage(
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

				if EnemyHumanoid.Health <= 0 then
					GrabbedEnemy = nil
					return
				end

				if GrabbedEnemy:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end

				EnemyStun = StunHandler:Stun(GrabbedEnemy, nil, true, 0, 0, true)
				GrabbedEnemy:AddTag("CantRotate")

				iFramesService:AddAlliFrames(GrabbedEnemy)
				CollisionsModule:SetCollisionGroup(GrabbedEnemy, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")

				AnimationService:stopAll(GrabbedEnemy)

				Weld = WeldSystem.new(HumRP, EnemyHumRP, WELD_OFFSET, -1)
				Weld:Start(nil, EnemyPlayer, Player)

				if EnemyPlayer then
					ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 3 })
				end
				ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 2 })

				ReplicateSet:FireAllClients("MoonCuttersFinalStart", {
					Char = Character,
					EChar = GrabbedEnemy,
				})

				UserTrack:AdjustSpeed(0)

				task.delay(1, function()
					if UserTrack.IsPlaying then
						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		-- ────────────────────────────────────────────────
		-- finalend — socão + AOE
		-- ────────────────────────────────────────────────
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("finalend"):Once(function()
				-- destrói weld antes do voo
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				local slammedEnemy = GrabbedEnemy
				GrabbedEnemy = nil

				-- ── dano + knockback absurdo no alvo principal ──
				if slammedEnemy and slammedEnemy.Parent then
					local EnemyHumanoid = slammedEnemy.Humanoid
					local EnemyHumRP = slammedEnemy.HumanoidRootPart
					local EnemyPlayer = Players:GetPlayerFromCharacter(slammedEnemy)

					if EnemyStun then
						StunHandler:Unstun(slammedEnemy, EnemyStun)
						EnemyStun = nil
					end
					slammedEnemy:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(slammedEnemy)
					CollisionsModule:SetCollisionGroup(slammedEnemy, "Players")

					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						FINAL_DAMAGE,
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

					RagdollHandler.ragdoll(EnemyHumanoid, 3)

					KnockbackModule:Knockback(
						slammedEnemy,
						HumRP.CFrame.LookVector * 50 + Vector3.new(0, 10, 0),
						nil,
						nil,
						nil,
						nil,
						false
					)

					if EnemyPlayer then
						ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 10, Last = 0.6 })
					end
				end

				-- ── AOE em geral na área (exceto o alvo principal e o próprio user) ──
				local aoeIgnore = slammedEnemy and { Character, slammedEnemy } or { Character }

				HitboxHandler:SimpleOnce(
					HumRP,
					Vector3.new(22, 18, 22),
					CFrame.new(0, 0, -6),
					aoeIgnore,
					nil,
					nil,
					function(OtherCharacter)
						local OtherHumanoid = OtherCharacter.Humanoid
						if OtherHumanoid.Health <= 0 or OtherCharacter:HasTag("Ragdolled") then
							return
						end
						if iFramesService:HasiFrame(OtherCharacter, Tool.Name) then
							return
						end

						DamageHandler:TakeDamage(
							Character,
							OtherHumanoid,
							AOE_DAMAGE,
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

						local OtherHumRP = OtherCharacter.HumanoidRootPart
						local pushDir = (OtherHumRP.Position - HumRP.Position)
						pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
						if pushDir.Magnitude > 0 then
							pushDir = pushDir.Unit
						else
							pushDir = HumRP.CFrame.LookVector
						end

						RagdollHandler.ragdoll(OtherHumanoid, 2)

						KnockbackModule:Knockback(
							OtherCharacter,
							pushDir * 20 + Vector3.new(0, 45, 0),
							nil,
							nil,
							nil,
							nil,
							false
						)

						local OtherPlayer = Players:GetPlayerFromCharacter(OtherCharacter)
						if OtherPlayer then
							ReplicateSet:FireClient(OtherPlayer, "ShakeCamera", { Intensity = 7, Last = 0.35 })
						end
					end
				)

				ReplicateSet:FireAllClients("MoonCuttersFinalEnd", {
					Char = Character,
					EChar = slammedEnemy,
				})

				ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 8, Last = 0.5 })
				CollisionsModule:SetCollisionGroup(Character, "Players")
			end)
		)

		-- ────────────────────────────────────────────────
		-- cleanup geral ao parar a animação
		-- ────────────────────────────────────────────────
		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end

			if GrabbedEnemy and GrabbedEnemy.Parent then
				if EnemyStun then
					StunHandler:Unstun(GrabbedEnemy, EnemyStun)
					EnemyStun = nil
				end
				GrabbedEnemy:RemoveTag("CantRotate")
				iFramesService:RemoveAlliFrames(GrabbedEnemy)
				CollisionsModule:SetCollisionGroup(GrabbedEnemy, "Players")
				GrabbedEnemy = nil
			end

			iFramesService:RemoveAlliFrames(Character)
			CollisionsModule:SetCollisionGroup(Character, "Players")
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
