local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local BodymoverService = require(ServerModules.BodymoverService)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Start = function(Player, Tool)
		print("Started Dash Slash")
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart
		local Humanoid = Character.Humanoid

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		Character:AddTag("CantRotate")

		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		DashVelocity.Velocity = HumRP.CFrame.LookVector * 120
		DashVelocity.P = math.huge
		DashVelocity.Parent = HumRP
		Debris:AddItem(DashVelocity, 0.45)

		local UserAnimation = MoveAnims.Lunar.DashSlash
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slash"):Once(function()
				if DashVelocity and DashVelocity.Parent then
					DashVelocity:Destroy()
				end

				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(1, 1, 1) * 14
				Hitbox.Method = "Box"
				Hitbox.Ignore = { Character }

				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter.Humanoid
					local EnemyHumRP = EnemyCharacter.HumanoidRootPart

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then
						return
					end

					local HitInfo = DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						18,
						1.5,
						nil,
						true,
						true,
						true,
						true,
						true,
						nil,
						nil
					)

					if HitInfo.Countered or HitInfo.Blocked then
						return
					end

					local PushDir = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector
					BodymoverService:Knockback(EnemyCharacter, {
						KnockbackType = "Velocity",
						MaxForce = Vector3.new(1, 1, 1) * 80000,
						Velocity = PushDir * 45 + Vector3.new(0, 15, 0),
					})

					if EnemyPlayer then
						ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 1, Last = 0.2 })
					end
				end

				Hitbox:Once()
				Hitbox:Destroy()
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end

			Character:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
