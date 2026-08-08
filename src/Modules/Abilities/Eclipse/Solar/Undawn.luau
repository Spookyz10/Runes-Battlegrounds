local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local MoveAnims = ServerStorage.Assets.Animations.Moves

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local KnockbackService = require(ServerModules.KnockbackModule)
local StatusEffectHandler = require(ServerModules.StatusEffectHandler)

local PILLAR_SEARCH_RADIUS = 60
local PILLAR_DAMAGE = 10
local PILLAR_STUN = 1.5
local PILLAR_DELAY = 0.7

local FIRE_ARMS_STACKS = 2

local function fireVFX(func, params)
	params.func = func
	RemoteManager.FireAllClients("ReplicateTask", "UndawnVFX", params)
end

local function clearInferno(EnemyCharacter)
	for _, source in StatusEffectHandler:GetSources(EnemyCharacter, "Inferno") do
		StatusEffectHandler:Remove(EnemyCharacter, "Inferno", source)
	end
end

return {
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
		iFramesService:AddBaseiFrames(Character)

		local UserAnimation = MoveAnims.Eclipse.Solar.Undawn
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		task.spawn(function()
			local beamPositions = {}

			HitboxHandler:SimpleOnce(
				HumRP,
				PILLAR_SEARCH_RADIUS,
				CFrame.new(0, 0, 0),
				{ Character },
				"Sphere",
				nil,
				function(EnemyCharacter)
					if not StatusEffectHandler:Has(EnemyCharacter, "Inferno") then
						return
					end
					local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumRP then
						return
					end
					local pos = EnemyHumRP.Position
					local beamPos = Vector3.new(pos.X, pos.Y - 3, pos.Z)

					fireVFX("Indicator", {
						char = Character,
						beamPos = beamPos,
					})
					table.insert(beamPositions, beamPos)
				end
			)

			if #beamPositions == 0 then
				return
			end

			task.delay(PILLAR_DELAY, function()
				fireVFX("Beam", {
					char = Character,
					beamPositions = beamPositions,
				})

				HitboxHandler:SimpleOnce(
					HumRP,
					PILLAR_SEARCH_RADIUS,
					CFrame.new(0, 0, 0),
					{ Character },
					"Sphere",
					nil,
					function(EnemyCharacter)
						if not StatusEffectHandler:Has(EnemyCharacter, "Inferno") then
							return
						end

						if EnemyCharacter:HasTag("Blocking") then
							clearInferno(EnemyCharacter)
							return
						end

						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP then
							return
						end

						clearInferno(EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							PILLAR_DAMAGE,
							PILLAR_STUN,
							nil,
							false,
							false,
							true,
							true,
							false,
							nil,
							nil
						)

						if not HitInfo.Countered and not HitInfo.Blocked then
							EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
							EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

							RagdollHandler.ragdoll(EnemyHumanoid, 6, nil, nil, nil, nil, true)

							task.defer(function()
								if not EnemyCharacter or not EnemyCharacter.Parent then
									return
								end
								KnockbackService:Knockback(
									EnemyCharacter,
									Vector3.new(0, 90, 0),
									nil,
									nil,
									nil,
									nil,
									nil,
									true
								)
							end)
						end
					end
				)
			end)
		end)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("clap"):Once(function()
				fireVFX("IndicatorRemove", { char = Character })

				local toolCDS = Tool:GetAttribute("CDS") or 15
				StatusEffectHandler:Apply(Character, "FireArms", { Stacks = FIRE_ARMS_STACKS, Duration = toolCDS })
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)
	end,
}
