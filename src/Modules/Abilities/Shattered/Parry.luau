local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local CounterHandler = require(ServerModules.CounterHandler)
local CombatEvents = require(ServerModules.CombatEvents)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local COUNTER_TIER = 1
local COUNTER_DAMAGE = 10
local WINDOW_HOLD_AFTER_FREEZE = 1

return {
	Cooldown = 8,
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserAnimation = MoveAnims.Shattered.Parry
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			StunHandler:Unstun(Character, Stun)
			return
		end

		local cancelled = false
		local counterToken = nil
		local counterConn = nil

		local function stopCountering()
			if counterToken then
				CounterHandler:StopCounter(Character, counterToken)
				counterToken = nil
			end
			if counterConn then
				counterConn:Disconnect()
				counterConn = nil
			end
		end

		local onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			stopCountering()
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		counterToken = CounterHandler:StartCounter(Character, COUNTER_TIER)

		counterConn = CombatEvents.Countered:Connect(function(Attacker, Defender, AttackTier)
			if Defender ~= Character then
				return
			end

			local AttackerHumanoid = Attacker and Attacker:FindFirstChild("Humanoid")
			if not AttackerHumanoid or AttackerHumanoid.Health <= 0 then
				return
			end

			DamageHandler:TakeDamage(
				Character,
				AttackerHumanoid,
				COUNTER_DAMAGE,
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
		end)

		SFXModule:Play("counterStartup", HumRP)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				if cancelled then
					return
				end

				UserTrack:AdjustSpeed(0)

				task.delay(WINDOW_HOLD_AFTER_FREEZE, function()
					if cancelled then
						return
					end

					stopCountering()

					if UserTrack and UserTrack.Parent then
						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			stopCountering()
			SkillCancelHandler:Unregister(Character, onDamageCancel)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
