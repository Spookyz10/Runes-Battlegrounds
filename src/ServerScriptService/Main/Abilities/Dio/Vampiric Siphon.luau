local Debris            = game:GetService("Debris")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService    = game:GetService("Players")

local ServerModules     = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer  = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)
local RagdollHandler   = require(ServerModules.RagdollHandler)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local CollisionsModule = require(ServerModules.CollisionsModule)
local WeldSystem       = require(ReplicatedModules.WeldSystem)

local services         = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims            = ServerStorage.Assets.Animations.Moves
local ReplicateEffects_Set = RemotesContainer.Replicate.Set

return {
	Start = function(Player: Player, Tool: Tool)
		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Hit  = false

		local StartAnimation = MoveAnims.Dio.Blood.BloodStart
		local StartTrack     = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents    = {}

		StartEvents["Hit"] = StartTrack:GetMarkerReachedSignal("Hit"):Once(function()

			local Hitbox            = ReplicatedHitbox.new(Player)
			Hitbox.Instance         = HumRP
			Hitbox.Size             = Vector3.new(6, 6, 10)
			Hitbox.Offset           = CFrame.new(0, 0, -5)
			Hitbox.Ignore           = { Character }
			Hitbox.destroyAfterOnce = false

			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid : Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP    : BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				if Hit then return end

				Hit = true

				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyStun   = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				AnimationService:stopAll(Character)

				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0), 2, true)

				local SuccessAnimation = MoveAnims.Dio.Blood.BloodSuccses
				local VictimAnimation  = MoveAnims.Dio.Blood.VictimBlood

				local SuccessTrack = AnimationService:getAnimationTrack(Character, SuccessAnimation)
				local VictimTrack  = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, SuccessAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				Weld:Start(nil, EnemyPlayer, Player)

				ReplicateEffects_Set:FireAllClients("DioBlood", {
					Stage   = "start",
					char    = Character,
					enemy   = EnemyCharacter,
					enemyCF = EnemyHumRP.CFrame,
				})

				-- Blood drain pulses every 0.5s x4
				task.spawn(function()
					for i = 1, 4 do
						task.wait(0.5)
						if not EnemyCharacter or not EnemyCharacter.Parent then break end

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, false, true, false, nil, nil)

						ReplicateEffects_Set:FireAllClients("DioBlood", {
							Stage   = "pulse",
							char    = Character,
							enemy   = EnemyCharacter,
							enemyCF = EnemyHumRP.CFrame,
						})
					end

					task.wait(0.1)

					-- Final hit
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, true, true, true, nil, nil)

					knockbackService.Knockback(EnemyHumRP, {
						["duration"]  = 0.25,
						["force"]     = 80,
						["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.2, 0),
					}, Character)

					if Weld then pcall(function() Weld:Stop() end) end

					HumRP.AssemblyLinearVelocity      = Vector3.zero
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					CollisionsModule:SetCollisionGroup(Character, "Players")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					StunHandler:Unstun(Character, Stun)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(Character)
					iFramesService:RemoveAlliFrames(EnemyCharacter)

					ReplicateEffects_Set:FireAllClients("DioBlood", {
						Stage   = "finalHit",
						char    = Character,
						enemy   = EnemyCharacter,
						enemyCF = EnemyHumRP.CFrame,
					})
				end)
			end

			Hitbox:Once()
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}