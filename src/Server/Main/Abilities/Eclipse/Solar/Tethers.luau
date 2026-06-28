local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local WeldSystem = require(ReplicatedModules.WeldSystem)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local SEARCH_RADIUS = 300
local DAMAGE = 1
local INFERNO_DURATION = 3.5
local KICK_VELOCITY = Vector3.new(0, 30, 0)
local KICK_HORIZONTAL_FORCE = 85
local WELD_OFFSET = CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
local PULL_OFFSET = Vector3.new(0, 0, -4)
local PULL_TIME = 0.5
local WELD_TIME = 0.15
local MAX_PULL_WAIT = 6
local CLOSE_DISTANCE = 5
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local HITBOX_OFFSET = CFrame.new(0, 0, -5)

-- Tempo que a corrente "viaja" até o inimigo antes de travar ele (efeito visual de lançamento)
local CHAIN_TRAVEL_TIME = 0.35
-- Slow-fall: multiplica a velocidade Y do inimigo quando preso no ar
local AIR_SLOW_FACTOR = 0.12

local function isInAir(EnemyCharacter)
	if EnemyCharacter:FindFirstChild("inAir") then
		return true
	end
	local touched = EnemyCharacter:GetAttribute("TouchedGround")
	if touched and (tick() - touched) <= 0.25 then
		return true
	end
	return false
end

--[[
	Cancela o PerfectKnockback e limpa todos os estados de knockback do personagem.
	Chamado quando o inimigo recebe dano ou é pego numa hitbox, para evitar a
	animação ficar congelada no estado "freeze" do PerfectKnockback.
]]
local function cancelAllKnockbackStates(EnemyCharacter)
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

	-- Cancela o PerfectKnockback — isso para a animação, destrói os body movers
	-- e chama Unstun internamente, evitando o freeze da animação de knockback
	PerfectKnockback:Cancel(EnemyCharacter)

	if EnemyHumRP then
		for _, v in EnemyCharacter:GetDescendants() do
			if
				v:IsA("BodyVelocity")
				or v:IsA("BodyAngularVelocity")
				or v:IsA("LinearVelocity")
				or v:IsA("AngularVelocity")
				or v:IsA("VectorForce")
				or v:IsA("Torque")
				or v:IsA("BodyPosition")
				or v:IsA("BodyGyro")
			then
				v:Destroy()
			end
		end

		for _, v in EnemyCharacter:GetDescendants() do
			if v:IsA("BasePart") then
				v.AssemblyLinearVelocity = Vector3.zero
				v.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	if EnemyCharacter:HasTag("Ragdolled") then
		if EnemyHumanoid then
			RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
		end
	end

	EnemyCharacter:RemoveTag("Knockbacked")

	-- Para garantir que a animação de knockback não fique congelada,
	-- paramos todas as animações se o PerfectKnockback estava ativo
	AnimationService:stopAll(EnemyCharacter)
end

local function applyInferno(EnemyCharacter)
	local existing = EnemyCharacter:GetAttribute("Inferno")
	EnemyCharacter:SetAttribute("Inferno", true)
	if existing then
		return
	end

	local tickStart = tick()
	local duration = INFERNO_DURATION
	local dotInterval = 0.5
	local dotDamage = 3

	task.spawn(function()
		while EnemyCharacter and EnemyCharacter.Parent and EnemyCharacter:GetAttribute("Inferno") do
			if tick() - tickStart >= duration then
				break
			end
			local Hum = EnemyCharacter:FindFirstChild("Humanoid")
			if not Hum or Hum.Health <= 0 then
				break
			end
			Hum:TakeDamage(dotDamage)
			task.wait(dotInterval)
		end
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)

	task.delay(duration, function()
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)
end

local function doHitEffects(
	Character,
	HumRP,
	closestEnemy,
	EnemyHumanoid,
	EnemyHumRP,
	EnemyPlayer,
	CasterStun,
	VictimStun,
	Tool
)
	StunHandler:Unstun(closestEnemy, VictimStun)
	iFramesService:RemoveAlliFrames(closestEnemy)
	closestEnemy:RemoveTag("CantRotate")
	closestEnemy:RemoveTag("Knockbacked")

	DamageHandler:TakeDamage(Character, EnemyHumanoid, DAMAGE, nil, nil, true, true, true, true, true, nil, nil)

	EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
	EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

	local kickDir = HumRP.CFrame.LookVector
	local kickFlat = Vector3.new(kickDir.X, 0, kickDir.Z)
	if kickFlat.Magnitude < 0.1 then
		kickFlat = Vector3.new(0, 0, -1)
	else
		kickFlat = kickFlat.Unit
	end

	RagdollHandler.ragdoll(EnemyHumanoid, 2, nil, nil, nil, nil, true)

	task.defer(function()
		if not closestEnemy or not closestEnemy.Parent then
			return
		end
		BodymoverService:Knockback(closestEnemy, {
			KnockbackType = "Velocity",
			MaxForce = Vector3.new(1, 1, 1) * 100000,
			Velocity = kickFlat * KICK_HORIZONTAL_FORCE + KICK_VELOCITY,
		})
	end)

	applyInferno(closestEnemy)

	if EnemyPlayer then
		ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 4, Last = 0.4 })
	end

	iFramesService:RemoveAlliFrames(Character)
	StunHandler:Unstun(Character, CasterStun)
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

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Eclipse.Solar.Tethers
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local closestEnemy = nil
		local EnemyHumanoid = nil
		local EnemyHumRP = nil
		local EnemyPlayer = nil
		local VictimStun = nil

		local pullDone = false
		local hitDone = false
		local Weld = nil
		local rotateConn = nil

		local function stopRotation()
			if rotateConn then
				rotateConn:Disconnect()
				rotateConn = nil
			end
		end

		local function startRotation()
			stopRotation()
			rotateConn = RunService.Heartbeat:Connect(function()
				if not HumRP or not HumRP.Parent or not EnemyHumRP or not EnemyHumRP.Parent then
					stopRotation()
					return
				end
				local targetPos = EnemyHumRP.Position
				local myPos = HumRP.Position
				local dir = targetPos - myPos
				if dir.Magnitude > 0.1 then
					HumRP.CFrame = CFrame.lookAt(myPos, targetPos) * CFrame.new(0, 0, 0)
				end
			end)
		end

		local function cleanupWeld()
			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end
		end

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("pull"):Once(function()
				UserTrack:AdjustSpeed(0)

				task.wait(0.2)

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = { workspace.Live }

				local parts = workspace:GetPartBoundsInRadius(HumRP.Position, SEARCH_RADIUS, overlapParams)
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
					if iFramesService:HasiFrame(char, Tool.Name) then
						continue
					end
					if not isInAir(char) then
						continue
					end

					local dist = (hrp.Position - HumRP.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						closestEnemy = char
					end
				end

				if not closestEnemy then
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:Stop()
					return
				end

				EnemyHumanoid = closestEnemy:FindFirstChild("Humanoid")
				EnemyHumRP = closestEnemy:FindFirstChild("HumanoidRootPart")
				EnemyPlayer = Players:GetPlayerFromCharacter(closestEnemy)

				if not EnemyHumanoid or not EnemyHumRP then
					closestEnemy = nil
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:Stop()
					return
				end

				-- ── SLOW-FALL: reduz a velocidade vertical do inimigo no ar ─────────────
				-- Isso dá a sensação de que as correntes "travaram" ele no ar antes de puxar
				do
					local currentVel = EnemyHumRP.AssemblyLinearVelocity
					EnemyHumRP.AssemblyLinearVelocity = Vector3.new(
						currentVel.X * 0.3,
						math.min(currentVel.Y, 0) * AIR_SLOW_FACTOR, -- só freia queda, não sobe
						currentVel.Z * 0.3
					)

					-- BodyVelocity temporário para segurar o inimigo no ar enquanto a corrente viaja
					local holdBV = Instance.new("BodyVelocity")
					holdBV.Name = "TetherHold"
					holdBV.MaxForce = Vector3.new(100000, 100000, 100000)
					holdBV.Velocity = Vector3.zero
					holdBV.P = 50000
					holdBV.Parent = EnemyHumRP
					game:GetService("Debris"):AddItem(holdBV, CHAIN_TRAVEL_TIME + 0.05)
				end

				-- ── CANCELAR KNOCKBACK ANTES (inclui PerfectKnockback com animação freezada) ──
				cancelAllKnockbackStates(closestEnemy)

				VictimStun = StunHandler:Stun(closestEnemy, nil, true, 0, 0, true)
				closestEnemy:AddTag("CantRotate")
				closestEnemy:AddTag("Knockbacked")

				pcall(function()
					HumRP:SetNetworkOwner(nil)
				end)

				startRotation()

				-- ── VFX DAS CORRENTES: notifica o client para animar as correntes "viajando" ──
				-- O client receberá travelTime para interpolar a corrente do braço do caster até o victim.
				-- Após travelTime o client "trava" a corrente na posição final.
				ReplicateSet:FireAllClients("TethersVFX_Start", {
					casterChar = Character,
					victimChar = closestEnemy,
					travelTime = CHAIN_TRAVEL_TIME, -- novo campo: cliente usa para fazer tween
				})

				-- Espera a corrente "viajar" visualmente antes de iniciar o pull físico
				task.wait(CHAIN_TRAVEL_TIME)

				if pullDone then
					return
				end
				if not closestEnemy or not closestEnemy.Parent then
					stopRotation()
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:AdjustSpeed(1)
					return
				end

				local PullTarget = (HumRP.CFrame * CFrame.new(PULL_OFFSET)).Position

				local PullAnchor = Instance.new("Part")
				PullAnchor.Name = "FlarewhipPullAnchor"
				PullAnchor.Anchored = true
				PullAnchor.CanCollide = false
				PullAnchor.CanTouch = false
				PullAnchor.CanQuery = false
				PullAnchor.Transparency = 1
				PullAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
				PullAnchor.CFrame = EnemyHumRP.CFrame
				PullAnchor.Parent = workspace

				local PullOffset = PullAnchor.CFrame:ToObjectSpace(EnemyHumRP.CFrame)
				local PullWeld = WeldSystem.new(PullAnchor, EnemyHumRP, PullOffset, -1)
				PullWeld:Start(PULL_TIME + WELD_TIME + 0.5, EnemyPlayer, Player)

				local PullTween = TweenService:Create(
					PullAnchor,
					TweenInfo.new(PULL_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{ CFrame = CFrame.new(PullTarget, PullTarget + HumRP.CFrame.LookVector) }
				)

				local function onVictimArrived()
					if pullDone then
						return
					end
					pullDone = true

					ReplicateSet:FireAllClients("TethersVFX_Stop", {
						casterChar = Character,
						victimChar = closestEnemy,
					})

					pcall(function()
						PullWeld:Stop()
					end)
					if PullAnchor and PullAnchor.Parent then
						PullAnchor:Destroy()
					end

					if not closestEnemy or not closestEnemy.Parent then
						stopRotation()
						UserTrack:AdjustSpeed(1)
						return
					end

					cancelAllKnockbackStates(closestEnemy)
					closestEnemy:AddTag("CantRotate")
					closestEnemy:AddTag("Knockbacked")

					stopRotation()

					HumRP.CFrame = CFrame.lookAt(
						HumRP.Position,
						Vector3.new(EnemyHumRP.Position.X, HumRP.Position.Y, EnemyHumRP.Position.Z)
					)

					Weld = WeldSystem.new(HumRP, EnemyHumRP, WELD_OFFSET, -1)
					Weld:Start(WELD_TIME, EnemyPlayer, Player)

					UserTrack:AdjustSpeed(1)
				end

				local proximityConn
				local timeoutThread

				timeoutThread = task.delay(MAX_PULL_WAIT, function()
					if pullDone then
						return
					end
					pullDone = true

					PullTween:Cancel()
					pcall(function()
						PullWeld:Stop()
					end)
					if PullAnchor and PullAnchor.Parent then
						PullAnchor:Destroy()
					end

					ReplicateSet:FireAllClients("TethersVFX_Stop", {
						casterChar = Character,
						victimChar = closestEnemy,
					})

					stopRotation()
					UserTrack:AdjustSpeed(1)

					if not hitDone then
						hitDone = true
						cleanupWeld()

						if closestEnemy and closestEnemy.Parent and EnemyHumanoid and EnemyHumanoid.Health > 0 then
							doHitEffects(
								Character,
								HumRP,
								closestEnemy,
								EnemyHumanoid,
								EnemyHumRP,
								EnemyPlayer,
								CasterStun,
								VictimStun,
								Tool
							)
						else
							iFramesService:RemoveAlliFrames(Character)
							StunHandler:Unstun(Character, CasterStun)
						end
					end
				end)

				proximityConn = RunService.Heartbeat:Connect(function()
					if pullDone then
						proximityConn:Disconnect()
						return
					end
					if not EnemyHumRP or not EnemyHumRP.Parent or not HumRP or not HumRP.Parent then
						proximityConn:Disconnect()
						return
					end
					if (EnemyHumRP.Position - HumRP.Position).Magnitude <= CLOSE_DISTANCE then
						proximityConn:Disconnect()
						if timeoutThread then
							task.cancel(timeoutThread)
						end
						onVictimArrived()
					end
				end)

				PullTween.Completed:Once(function(state)
					if state == Enum.PlaybackState.Completed and not pullDone then
						if proximityConn then
							proximityConn:Disconnect()
						end
						if timeoutThread then
							task.cancel(timeoutThread)
						end
						onVictimArrived()
					end
				end)

				PullTween:Play()
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				stopRotation()
				cleanupWeld()

				if hitDone then
					return
				end
				hitDone = true

				local HitList = {}

				if closestEnemy and closestEnemy.Parent then
					HitList[closestEnemy] = true
				end

				HitboxHandler:SimpleOnce(
					HumRP,
					HITBOX_SIZE,
					HITBOX_OFFSET,
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						if HitList[EnemyCharacter] then
							return
						end
						if EnemyCharacter == closestEnemy then
							return
						end

						local Hum = EnemyCharacter:FindFirstChild("Humanoid")
						local Hrp = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not Hum or not Hrp then
							return
						end
						if Hum.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end

						HitList[EnemyCharacter] = true

						-- Cancela PerfectKnockback de qualquer inimigo atingido pela hitbox AoE
						cancelAllKnockbackStates(EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							Hum,
							DAMAGE,
							nil,
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

						Hrp.AssemblyLinearVelocity = Vector3.zero

						local pushDir = (Hrp.Position - HumRP.Position)
						pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
						pushDir = pushDir.Magnitude > 0 and pushDir.Unit or HumRP.CFrame.LookVector

						RagdollHandler.ragdoll(Hum, 2, nil, nil, nil, nil, true)

						task.defer(function()
							if not EnemyCharacter or not EnemyCharacter.Parent then
								return
							end
							BodymoverService:Knockback(EnemyCharacter, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(1, 1, 1) * 100000,
								Velocity = pushDir * KICK_HORIZONTAL_FORCE + KICK_VELOCITY,
							})
						end)

						applyInferno(EnemyCharacter)
					end
				)

				if closestEnemy and closestEnemy.Parent and EnemyHumanoid and EnemyHumanoid.Health > 0 then
					doHitEffects(
						Character,
						HumRP,
						closestEnemy,
						EnemyHumanoid,
						EnemyHumRP,
						EnemyPlayer,
						CasterStun,
						VictimStun,
						Tool
					)
				else
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
				end
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			stopRotation()
			cleanupWeld()

			pcall(function()
				HumRP:SetNetworkOwner(Player)
			end)
			if EnemyHumRP and EnemyHumRP.Parent then
				pcall(function()
					EnemyHumRP:SetNetworkOwner(EnemyPlayer)
				end)
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)

			if closestEnemy and closestEnemy.Parent and VictimStun then
				StunHandler:Unstun(closestEnemy, VictimStun)
				iFramesService:RemoveAlliFrames(closestEnemy)
				closestEnemy:RemoveTag("CantRotate")
				closestEnemy:RemoveTag("Knockbacked")
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
