local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local MoveAnims = ServerStorage.Assets.Animations.Moves

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local CharacterLifetime = require(ServerModules.CharacterLifetime)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local KnockbackService = require(ServerModules.KnockbackModule)
local StatusEffectHandler = require(ServerModules.StatusEffectHandler)

local PILLAR_SEARCH_RADIUS = 60
local PILLAR_DAMAGE = 10
local PILLAR_STUN = 1.5
local PILLAR_DELAY = 0.7
local PILLAR_HITBOX_SIZE = Vector3.new(20, 50, 20)

local FIRE_ARMS_STACKS = 2
local FIRE_ARMS_DURATION = 10

local SELF_DAMAGE_COST = 5

local INDICATOR_Y_OFFSET = 2

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
	Cooldown = 15,
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

		if Humanoid.Health > 0 then
			if Humanoid.Health <= SELF_DAMAGE_COST then
				Humanoid.Health = 1
			else
				Humanoid.Health -= SELF_DAMAGE_COST
			end
		end

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		iFramesService:AddiFrames(Character, "Base")

		StatusEffectHandler:Apply(Character, "FireArms", { Stacks = FIRE_ARMS_STACKS, Duration = FIRE_ARMS_DURATION })

		local UserAnimation = MoveAnims.Eclipse.Solar.Undawn
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			iFramesService:RemoveiFrames(Character, "Base")
			StunHandler:Unstun(Character, Stun)
			return
		end
		local cancelled = false
		local disconnectLifetime = CharacterLifetime.Watch(Character, function()
			cancelled = true
			fireVFX("IndicatorRemove", { char = Character })
		end)
		task.delay(5, disconnectLifetime)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("clap"):Once(function()
				-- A lista é fechada no primeiro Sphere. O beam, dano e ragdoll
				-- usam estes mesmos alvos; ninguém que entrar no raio depois recebe
				-- o efeito sem ter sido pego pela hitbox.
				local targets = {}

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

						local MarkedPosition = EnemyHumRP.Position

						fireVFX("Indicator", {
							char = Character,
							position = MarkedPosition,
							yOffset = INDICATOR_Y_OFFSET,
						})
						table.insert(targets, { Character = EnemyCharacter, Position = MarkedPosition })
					end
				)

				task.delay(2, function()
					fireVFX("IndicatorRemove", { char = Character })
				end)

				if #targets == 0 then
					return
				end

				task.delay(PILLAR_DELAY, function()
					if cancelled then
						return
					end
					local beamPositions = {}
					for _, Target in targets do
						local pos = Target.Position
						table.insert(beamPositions, Vector3.new(pos.X, pos.Y - INDICATOR_Y_OFFSET, pos.Z))
					end

					fireVFX("Beam", {
						char = Character,
						beamPositions = beamPositions,
					})

					for _, Target in targets do
						local EnemyCharacter = Target.Character
						local PillarPosition = Target.Position

						task.spawn(function()
							if cancelled or not EnemyCharacter.Parent then
								return
							end
							if not EnemyCharacter or not StatusEffectHandler:Has(EnemyCharacter, "Inferno") then
								return
							end

							-- Hitbox real na MESMA posição marcada pelo indicator (não
							-- na posição atual do inimigo), pra dar chance de desviar
							-- saindo dali antes do pilar cair.
							local hitConfirmed = false

							HitboxHandler:SimpleOnce(
								PillarPosition,
								PILLAR_HITBOX_SIZE,
								nil,
								{ Character },
								"Box",
								nil,
								function(HitCharacter)
									if HitCharacter == EnemyCharacter then
										hitConfirmed = true
									end
								end
							)

							if not hitConfirmed then
								clearInferno(EnemyCharacter)
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
								true,
								false,
								true,
								true,
								false,
								nil,
								nil
							)

							if HitInfo.Countered or HitInfo.Blocked then
								return
							end

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
						end)
					end
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end
			iFramesService:RemoveiFrames(Character, "All")
			StunHandler:Unstun(Character, Stun)
		end)
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
