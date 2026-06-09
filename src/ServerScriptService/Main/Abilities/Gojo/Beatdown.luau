local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)

local WeldSystem = require(ReplicatedModules.WeldSystem)

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local Animations = ServerStorage.Assets.Animations
local BeatdownAnims = Animations.Moves.Gojo.Beatdown

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Hit = false

		AnimationService:stopAll(Character)
		local Anim = AnimationService:playAnimation(Character, BeatdownAnims.Anim)
		local AnimEvents = {}

		ReplicateEffects_Set:FireAllClients("Beatdown", {
			Stage = "Start",
			Char = Character,
			StartAnim = BeatdownAnims.Anim.AnimationId
		})

		AnimEvents["damage"] = Anim:GetMarkerReachedSignal("Damage"):Once(function()
			local HitboxConnection = ReplicatedHitbox.new(Player)
			HitboxConnection.Instance = HumRP
			HitboxConnection.Size = Vector3.new(6, 5, 8)
			HitboxConnection.Offset = CFrame.new(0, 0, -4)
			HitboxConnection.Ignore = { Character }

			HitboxConnection.onTouch = function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

				if Hit then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				if EnemyCharacter:HasTag("Ragdolled") then return end
				if EnemyHumRP.Anchored then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, false, nil)
				if HitInfo.Blocked == true then return end

				Hit = true
				pcall(function() HitboxConnection:Destroy() end)

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				-- Victim placed 2 studs in front of attacker
				-- CFrame.Angles(0, math.rad(180), 0) makes victim face toward attacker
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0), 14)

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				local Anim1 = AnimationService:playAnimation(Character, BeatdownAnims.Anim1)
				Weld:Start(nil, EnemyPlayer, Player)

				-- Pass EnemyPlayer not EnemyCharacter so client can get .Character safely
				ReplicateEffects_Set:FireAllClients("Beatdown", {
					Stage = "Hit",
					Char = Character,
					Victim = EnemyPlayer, -- player reference, client does .Character
					HitAnim = BeatdownAnims.Anim1.AnimationId
				})

				local VictimAnimator = EnemyHumanoid:FindFirstChildOfClass("Animator")

				Anim1:GetMarkerReachedSignal("Damage"):Connect(function()
					local HitInfo2 = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
					if HitInfo2.Blocked then return end

					if VictimAnimator then
						local hitAnim = math.random(1, 2) == 1 and BeatdownAnims.Hit1 or BeatdownAnims.Hit2
						VictimAnimator:LoadAnimation(hitAnim):Play(0)
					end

					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 1, Last = 0.15 })
					end
				end)

				Anim1:GetMarkerReachedSignal("End"):Once(function()
					if Weld then pcall(function() Weld:Stop() end); Weld = nil end

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, true, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 3)

					NewKnockback:Knockback(EnemyCharacter, {
						KnockbackType = "VelocityTweenDown",
						MaxForce = Vector3.new(math.huge, math.huge, math.huge),
						Velocity = HumRP.CFrame.LookVector * 120 + Vector3.new(0, 80, 0),
						Time = 0.15,
					})

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyCharacter:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(EnemyCharacter)

					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
					end
				end)

				Anim1.Stopped:Once(function()
					if Weld then pcall(function() Weld:Stop() end); Weld = nil end

					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(Character)

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyCharacter:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end)
			end

			HitboxConnection:Start(0.38, true)
		end)

		Anim.Stopped:Once(function()
			for _, v in AnimEvents do
				v:Disconnect()
			end
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
	end
}