local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local RagdollHandler = require(ServerModules.RagdollHandler)
local KnockbackService = require(ServerModules.KnockbackModule)

local PILLAR_SEARCH_RADIUS = 60
local PILLAR_DAMAGE = 10
local PILLAR_STUN = 1.5

local EMPOWERED_DAMAGE = 22
local EMPOWERED_STUN = 0.35
local EMPOWERED_COMBO_REQUIRED = 4

local function fireVFX(func, params)
	params.func = func
	ReplicateSet:FireAllClients("UndawnVFX", params)
end

local function removeArmsEffect(Character)
	fireVFX("ArmsRemove", { char = Character })
end

local function setupEmpoweredM1s(Character, Tool, chargesLeft)
	if chargesLeft <= 0 then
		Character:SetAttribute("UndawnEmpowered", nil)
		Character:SetAttribute("UndawnCharges", nil)
		return
	end

	Character:SetAttribute("UndawnEmpowered", true)
	Character:SetAttribute("UndawnCharges", chargesLeft)

	local connection
	connection = Character:GetAttributeChangedSignal("LastM1Time"):Connect(function()
		local remaining = Character:GetAttribute("UndawnCharges") or 0
		if remaining <= 0 then
			connection:Disconnect()
			return
		end

		if Character:GetAttribute("Combo") ~= EMPOWERED_COMBO_REQUIRED then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local hitboxCF = HumRP.CFrame * CFrame.new(0, 0, -3.5)
		local hitSize = Vector3.new(7, 5, 7)
		local hitOnce = false

		HitboxHandler:SimpleOnce(
			hitboxCF,
			hitSize,
			CFrame.new(0, 0, 0),
			{ Character },
			"Box",
			nil,
			function(EnemyCharacter)
				if hitOnce then
					return
				end

				local hum = EnemyCharacter:FindFirstChild("Humanoid")
				local hrp = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not hum or not hrp then
					return
				end
				if hum.Health <= 0 then
					return
				end

				hitOnce = true

				local newRemaining = (Character:GetAttribute("UndawnCharges") or 0) - 1
				Character:SetAttribute("UndawnCharges", newRemaining)

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					hum,
					EMPOWERED_DAMAGE,
					EMPOWERED_STUN,
					nil,
					true,
					true,
					true,
					true,
					false,
					"M1",
					nil
				)

				if not HitInfo.Countered and not HitInfo.Blocked then
					hrp.AssemblyLinearVelocity = Vector3.zero

					local pushDir = HumRP.CFrame.LookVector
					local lookFlat = Vector3.new(pushDir.X, 0, pushDir.Z).Unit
					local lookCF = CFrame.lookAt(hrp.Position, hrp.Position + lookFlat)

					PerfectKnockback:KnockBack(nil, EnemyCharacter, {
						LookVector = lookFlat,
						LookForce = 52,
						LookFinalForce = 48,
						LookAt = lookCF,
						UpVelocity = Vector3.new(0, 35, 0),
						UpVelocityTime = 0.12,
						GroundStunTime = 0.9,
						FallingDetectDelay = 0.4,
						Dot = 1,
						DontFreeze = false,
					}, Character)
				end

				if newRemaining <= 0 then
					connection:Disconnect()
					Character:SetAttribute("UndawnEmpowered", nil)
					Character:SetAttribute("UndawnCharges", nil)
					removeArmsEffect(Character)
				end
			end
		)
	end)

	local toolCDS = Tool:GetAttribute("CDS") or 15
	task.delay(toolCDS, function()
		if Character:GetAttribute("UndawnEmpowered") then
			connection:Disconnect()
			Character:SetAttribute("UndawnEmpowered", nil)
			Character:SetAttribute("UndawnCharges", nil)
			removeArmsEffect(Character)
		end
	end)
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

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

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
					if not EnemyCharacter:GetAttribute("Inferno") then
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

			task.delay(1, function()
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
						if not EnemyCharacter:GetAttribute("Inferno") then
							return
						end

						if EnemyCharacter:HasTag("Blocking") then
							EnemyCharacter:SetAttribute("Inferno", nil)
							return
						end

						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end

						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP then
							return
						end

						EnemyCharacter:SetAttribute("Inferno", nil)

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
				fireVFX("Arms", { char = Character })
				setupEmpoweredM1s(Character, Tool, 2)
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
