local Character = script.Parent
local HumRP = Character.HumanoidRootPart
local Humanoid = Character.Humanoid

local RNS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local AnimationService = require(ServerStorage.Modules.AnimationService)
local HitboxHandler = require(ServerStorage.Modules.HitboxHandler)
local iFramesService = require(ServerStorage.Modules.iFramesService)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)

local Animations = ServerStorage.Assets.Animations

RNS.Heartbeat:Connect(function()
	if not Character:HasTag("Punching") and not Character:HasTag("PunchCDS") and not Character:HasTag("CantPunch") then
		Character:AddTag("Punching")
		Character:AddTag("PunchCDS")

		local PunchAnim: Animation = Animations.Combat.Punches.Default["1"]
		local PunchAnimTrack, Events = AnimationService:getAnimationTrack(Character, PunchAnim)

		table.insert(
			Events,
			PunchAnimTrack:GetMarkerReachedSignal("hit"):Once(function()
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(1, 1, 1) * 7
				Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z / 2)
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter.Humanoid
					local EnemyHumRP = EnemyCharacter.HumanoidRootPart

					if
						EnemyCharacter == Character
						or EnemyHumanoid.Health <= 0
						or iFramesService:HasiFrame(EnemyCharacter, 1)
						or EnemyCharacter:HasTag("Ragdolled")
					then
						return
					end

					local HitInfo = DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						4,
						1,
						ServerStorage.Assets.Animations.Combat.Hits["1"],
						true,
						true,
						false,
						false,
						true,
						"M1"
					)
					if HitInfo.Countered == true then
						return
					end

					if HitInfo.Blocked == true then
						local SFX: Sound

						if EnemyCharacter:HasTag("PerfectBlock") then
							SFX = ServerStorage.Assets.Sounds.Combat.Hits.PerfectBlocked
						else
							SFX = ServerStorage.Assets.Sounds.Combat.Hits.Blocked
						end

						SFXModule:PlaySound(SFX, EnemyHumRP)
					else
						SFXModule:PlaySound(ServerStorage.Assets.Sounds.Combat.Hits.Default["1"], EnemyHumRP)
					end
				end

				Hitbox:Once()
				Hitbox:Destroy()
			end)
		)

		PunchAnimTrack.Stopped:Once(function()
			Character:RemoveTag("Punching")
			task.wait(1)
			Character:RemoveTag("PunchCDS")
		end)

		Humanoid.Died:Connect(function()
			Character:RemoveTag("PunchCDS")
		end)

		AnimationService:playAnimation(Character, PunchAnim)

		SFXModule:PlaySound(ServerStorage.Assets.Sounds.Combat.Swings.Default["1"], HumRP)
	end
end)
