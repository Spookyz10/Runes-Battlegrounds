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

		local StartAnimation = MoveAnims.Dio.Beatdown.Start
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

				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0), 2.5, true)

				local BeatdownAnimation = MoveAnims.Dio.Beatdown.Beatdown
				local VictimAnimation   = MoveAnims.Dio.Beatdown.Enemy

				local BeatdownTrack  = AnimationService:getAnimationTrack(Character, BeatdownAnimation)
				local VictimTrack    = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local BeatdownEvents = {}

				BeatdownEvents["Hit"] = BeatdownTrack:GetMarkerReachedSignal("Hit"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("DioBeatdown", {
						Stage   = "hit",
						char    = Character,
						enemy   = EnemyCharacter,
						enemyCF = EnemyHumRP.CFrame,
					})
				end)

				BeatdownEvents["DustFX"] = BeatdownTrack:GetMarkerReachedSignal("DustFX"):Connect(function()
					ReplicateEffects_Set:FireAllClients("DioBeatdown", {
						Stage = "dust",
						char  = Character,
						hrpCF = HumRP.CFrame,
					})
				end)

				BeatdownEvents["FinalHit"] = BeatdownTrack:GetMarkerReachedSignal("FinalHit"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, true, true, true, nil, nil)

					knockbackService.Knockback(EnemyHumRP, {
						["duration"]  = 0.25,
						["force"]     = 160,
						["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.1, 0),
					}, Character)

					RagdollHandler.ragdoll(EnemyHumanoid, 2.5)

					ReplicateEffects_Set:FireAllClients("DioBeatdown", {
						Stage   = "finalHit",
						char    = Character,
						enemy   = EnemyCharacter,
						enemyCF = EnemyHumRP.CFrame,
						hrpCF   = HumRP.CFrame,
					})
				end)

				BeatdownTrack.Stopped:Once(function()
					for _, v in BeatdownEvents do v:Disconnect() end
					if Weld then pcall(function() Weld:Stop() end) end

					-- Kill any leftover velocity
					HumRP.AssemblyLinearVelocity = Vector3.zero
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					CollisionsModule:SetCollisionGroup(Character, "Players")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					StunHandler:Unstun(Character, Stun)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(Character)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end)

				VictimTrack.Stopped:Once(function()
					if Weld then pcall(function() Weld:Stop() end) end
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end)

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, BeatdownAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				Weld:Start(nil, EnemyPlayer, Player)

				ReplicateEffects_Set:FireAllClients("DioBeatdown", {
					Stage   = "start",
					char    = Character,
					enemy   = EnemyCharacter,
					enemyCF = EnemyHumRP.CFrame,
					hrpCF   = HumRP.CFrame,
				})
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

		ReplicateEffects_Set:FireAllClients("DioBeatdown", {
			Stage = "startup",
			char  = Character,
		})
	end,
}