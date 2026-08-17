local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local iFramesService = require(SvModules.iFramesService)
local AnimationService = require(SvModules.AnimationService)

local ReplicatedHitboxes = require(SvModules.ReplicatedHitboxes)
local DamageHandler = require(SvModules.DamageHandler)
local StatusEffectHandler = require(SvModules.StatusEffectHandler)
local CooldownSystem = require(SvModules.CooldownSystem)
local EvasiveService = require(SvModules.EvasiveService)

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)

local Configs = require(script.Configs)
local SkillCollision = require(script.Parent.SkillCollision)

local DashHandler = {}

local DASH_HIT_SANITY_TOLERANCE = 35
local DASH_INPUT_DEBOUNCE = 0.5

local DashDebounce = {}

local AxisKey = {
	Front = "Dash_Z",
	Back = "Dash_Z",
	Left = "Dash_X",
	Right = "Dash_X",
}

local function getConfig(Player, Direction)
	local Moveset = Player:GetAttribute("Moveset") or "Default"
	local MovesetConfigs = Configs[Moveset] or Configs.Default
	return MovesetConfigs[Direction]
end

local function runAttackDash(Player: Player, Character: Model, HumRP: BasePart, Humanoid: Humanoid, Config)
	print("[DASH][" .. Player.Name .. "] runAttackDash INICIADO | Direction/Id=" .. tostring(Config.Id))

	local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
	local Hit = false
	local Ended = false
	local DashHitbox
	local DashResumed = false
	local HitList = {}
	local SlopeClampConn

	local Animation = Config.Animation()
	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, Animation)
	if not AnimTrack then
		print("[DASH][" .. Player.Name .. "] ERRO: AnimTrack nil, abortando runAttackDash")
		StunHandler:Unstun(Character, Stun)
		return
	end

	print("[DASH][" .. Player.Name .. "] AnimTrack carregado, Length=" .. tostring(AnimTrack.Length))

	SkillCollision:Lock(Character)

	local Velocity = Instance.new("BodyVelocity")
	Velocity.Name = Config.Id .. "Velocity"
	Velocity.MaxForce = Vector3.new(Config.Speed, 0, Config.Speed)
	Velocity.Velocity = Vector3.new()

	local function stopSlopeClamp()
		if SlopeClampConn then
			SlopeClampConn:Disconnect()
			SlopeClampConn = nil
		end
	end

	local function startSlopeClamp()
		stopSlopeClamp()
		SlopeClampConn = RunService.Heartbeat:Connect(function()
			if not HumRP or not HumRP.Parent then
				stopSlopeClamp()
				return
			end

			local Vel = HumRP.AssemblyLinearVelocity
			if Vel.Y > 0 then
				HumRP.AssemblyLinearVelocity = Vector3.new(Vel.X, 0, Vel.Z)
			end
		end)
	end

	local function destroyDashHitbox()
		if DashHitbox then
			print("[DASH][" .. Player.Name .. "] destroyDashHitbox() chamado, destruindo hitbox atual")
			pcall(function()
				DashHitbox:Destroy()
			end)
			DashHitbox = nil
		else
			print("[DASH][" .. Player.Name .. "] destroyDashHitbox() chamado mas DashHitbox já era nil")
		end
	end

	local function endDash()
		if Ended then
			print("[DASH][" .. Player.Name .. "] endDash() chamado mas já estava Ended")
			return
		end
		Ended = true
		print("[DASH][" .. Player.Name .. "] endDash() EXECUTANDO, Hit=" .. tostring(Hit))
		Character:SetAttribute("Dashing", false)
		destroyDashHitbox()
		stopSlopeClamp()
		SkillCollision:Unlock(Character)
		if Velocity and Velocity.Parent then
			Velocity:Destroy()
		end
		AnimTrack:AdjustSpeed(1)
	end

	local function killVelocity()
		print("[DASH][" .. Player.Name .. "] killVelocity() chamado")
		if Velocity and Velocity.Parent then
			Velocity.Velocity = Vector3.new()
			Velocity.MaxForce = Vector3.new()
		end
		if HumRP and HumRP.Parent then
			HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
		end
	end

	local function resumeDash()
		print(
			"[DASH]["
				.. Player.Name
				.. "] resumeDash() CHAMADO | Ended="
				.. tostring(Ended)
				.. " DashResumed(antes)="
				.. tostring(DashResumed)
		)

		if Ended or DashResumed then
			print("[DASH][" .. Player.Name .. "] resumeDash() ABORTADO (já Ended ou já DashResumed)")
			return
		end

		DashResumed = true
		print(
			"[DASH][" .. Player.Name .. "] resumeDash() EXECUTANDO -> AdjustSpeed(1) + destroyDashHitbox + killVelocity"
		)
		AnimTrack:AdjustSpeed(1)
		destroyDashHitbox()

		killVelocity()

		if Velocity and Velocity.Parent then
			Velocity:Destroy()
		end
	end

	local function applyHit(EnemyCharacter: Model)
		print(
			"[DASH]["
				.. Player.Name
				.. "] applyHit() CHAMADO com alvo="
				.. tostring(EnemyCharacter and EnemyCharacter.Name)
		)

		if Ended or HitList[EnemyCharacter] then
			print(
				"[DASH]["
					.. Player.Name
					.. "] applyHit() ABORTADO | Ended="
					.. tostring(Ended)
					.. " jaNaHitList="
					.. tostring(HitList[EnemyCharacter])
			)
			return
		end

		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid") :: Humanoid?
		local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not EnemyHumanoid or not EnemyHumRP or EnemyHumanoid.Health <= 0 then
			print("[DASH][" .. Player.Name .. "] applyHit() ABORTADO: EnemyHumanoid/EnemyHumRP nil ou Health<=0")
			return
		end

		if not HumRP or not HumRP.Parent then
			print("[DASH][" .. Player.Name .. "] applyHit() ABORTADO: HumRP proprio nil/sem Parent")
			return
		end

		local Distance = (EnemyHumRP.Position - HumRP.Position).Magnitude
		print("[DASH][" .. Player.Name .. "] applyHit() Distance=" .. tostring(Distance))

		if Distance > DASH_HIT_SANITY_TOLERANCE then
			print("[DASH][" .. Player.Name .. "] applyHit() ABORTADO: Distance > tolerance")
			return
		end

		if iFramesService:HasiFrame(EnemyCharacter, 1) then
			print("[DASH][" .. Player.Name .. "] applyHit() ABORTADO: alvo com iFrame")
			return
		end

		HitList[EnemyCharacter] = true

		local HitAnims = Config.HitAnimations and Config.HitAnimations()
		SFXModule:Play("DashHit", HumRP)

		print(
			"[DASH]["
				.. Player.Name
				.. "] applyHit() -> chamando DamageHandler:TakeDamage, Damage="
				.. tostring(Config.Damage)
		)

		local HitInfo = DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			Config.Damage,
			Config.StunTime,
			HitAnims and HitAnims[tostring(math.random(1, 3))],
			true,
			true,
			true
		)

		print(
			"[DASH]["
				.. Player.Name
				.. "] applyHit() TakeDamage retornou | Countered="
				.. tostring(HitInfo.Countered)
				.. " Blocked="
				.. tostring(HitInfo.Blocked)
				.. " CouldHit="
				.. tostring(HitInfo.CouldHit)
		)

		if HitInfo.Countered then
			print("[DASH][" .. Player.Name .. "] applyHit() ABORTADO pos-dano: Countered")
			return
		end

		Hit = true
		print("[DASH][" .. Player.Name .. "] applyHit() SUCESSO, Hit=true, chamando resumeDash + Unstun")

		resumeDash()

		StunHandler:Unstun(Character, Stun)
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Once(function()
			print("[DASH][" .. Player.Name .. "] MARKER 'jump' disparado | Ended=" .. tostring(Ended))

			if Ended then
				return
			end

			Velocity.Parent = HumRP

			startSlopeClamp()

			DashHitbox = ReplicatedHitboxes.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Config.Hitbox.Size
			DashHitbox.Offset = Config.Hitbox.Offset
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = function(EnemyCharacter)
				print(
					"[DASH]["
						.. Player.Name
						.. "] hitbox do 'jump' TOCOU em "
						.. tostring(EnemyCharacter and EnemyCharacter.Name)
						.. " -> chamando resumeDash"
				)
				resumeDash()
			end
			DashHitbox.onTimeout = function()
				print(
					"[DASH]["
						.. Player.Name
						.. "] hitbox do 'jump' deu TIMEOUT (1s sem tocar nada) -> chamando resumeDash"
				)
				resumeDash()
			end
			print(
				"[DASH]["
					.. Player.Name
					.. "] iniciando DashHitbox do 'jump' (Constant, 1s), Bridge="
					.. tostring(DashHitbox.Bridge and DashHitbox.Bridge.Name)
			)
			DashHitbox:Start(1, false)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
			print(
				"[DASH]["
					.. Player.Name
					.. "] MARKER 'freeze' disparado | Ended="
					.. tostring(Ended)
					.. " DashResumed="
					.. tostring(DashResumed)
			)

			if Ended then
				return
			end

			print("[DASH][" .. Player.Name .. "] 'freeze' -> AdjustSpeed(0)")
			AnimTrack:AdjustSpeed(0)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("hit"):Once(function()
			print("[DASH][" .. Player.Name .. "] MARKER 'hit' disparado | Ended=" .. tostring(Ended))

			if Ended then
				return
			end

			destroyDashHitbox()

			DashHitbox = ReplicatedHitboxes.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Config.Hitbox.Size
			DashHitbox.Offset = Config.Hitbox.Offset
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = function(EnemyCharacter)
				print(
					"[DASH]["
						.. Player.Name
						.. "] hitbox do 'hit' TOCOU em "
						.. tostring(EnemyCharacter and EnemyCharacter.Name)
						.. " -> chamando applyHit"
				)
				applyHit(EnemyCharacter)
			end
			print(
				"[DASH]["
					.. Player.Name
					.. "] iniciando DashHitbox do 'hit' (Once), Bridge="
					.. tostring(DashHitbox.Bridge and DashHitbox.Bridge.Name)
			)
			DashHitbox:Once()

			task.delay(0.3, function()
				print("[DASH][" .. Player.Name .. "] task.delay(0.3) pos-'hit' -> destruindo hitbox do 'hit'")
				destroyDashHitbox()
			end)
		end)
	)

	AnimTrack.Stopped:Once(function()
		print(
			"[DASH]["
				.. Player.Name
				.. "] AnimTrack.Stopped disparado | Hit="
				.. tostring(Hit)
				.. " Ended(antes)="
				.. tostring(Ended)
		)

		for _, v in AnimEvents do
			v:Disconnect()
		end
		destroyDashHitbox()
		stopSlopeClamp()
		StunHandler:Unstun(Character, Stun)
		if not Hit then
			print("[DASH][" .. Player.Name .. "] AnimTrack.Stopped -> disparando efeito DashMiss (nao acertou ninguem)")
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"DashMiss",
				{ PrimaryPart = HumRP, YAngle = math.pi, Front = true }
			)
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Animation)

	Character:SetAttribute("Dashing", true)

	RemoteManager.FireAllClients("ReplicateTask", "DashMiss", { PrimaryPart = HumRP })

	task.delay(2, function()
		print("[DASH][" .. Player.Name .. "] task.delay(2) HARD TIMEOUT do dash -> zerando velocity + endDash")
		HumRP.AssemblyLinearVelocity = Vector3.new()
		endDash()
	end)

	task.delay(1.25, function()
		if Character and Character.Parent then
			print(
				"[DASH]["
					.. Player.Name
					.. "] task.delay(1.25) -> AdjustSpeed(1) + Unstun (fallback caso freeze nunca destrave)"
			)
			AnimTrack:AdjustSpeed(1)
			StunHandler:Unstun(Character, Stun)
		end
	end)
end

local function runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	print("[DASH][" .. Player.Name .. "] runDisplacementDash INICIADO | Id=" .. tostring(Config.Id))

	local Duration = Config.Duration or 1.017

	Character:SetAttribute("Dashing", true)
	task.delay(Duration, function()
		if Character and Character.Parent then
			Character:SetAttribute("Dashing", false)
		end
	end)

	if not Config.NoStun then
		StunHandler:Stun(Character, Duration, true, 0, 0, true, nil, false)
	else
		Character:AddTag("CantDash")
		task.delay(Duration, function()
			if Character and Character.Parent then
				Character:RemoveTag("CantDash")
			end
		end)
	end

	if Config.IFrames then
		iFramesService:AddBaseiFrames(Character)
		task.delay(Duration, function()
			iFramesService:RemoveiFrames(Character, "Base")
		end)
	end

	local IsTeleport = StatusEffectHandler:Has(Character, "TpDash")

	if IsTeleport then
		RemoteManager.FireClient(
			Player,
			"ReplicateTask",
			"DashTeleport",
			{ Direction = Config.Id, Duration = Duration }
		)
	else
		RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Start", char = Character })
		task.delay(Duration, function()
			RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Stop", char = Character })
		end)
	end

	local Animation = Config.Animation and Config.Animation()
	if Animation then
		AnimationService:playAnimation(Character, Animation)
	end
end

function DashHandler:Dash(Player: Player, Direction: string): boolean
	print("[DASH][" .. Player.Name .. "] DashHandler:Dash CHAMADO | Direction=" .. tostring(Direction))

	local Character = Player.Character
	if not Character then
		print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: sem Character")
		return false
	end

	if DashDebounce[Character] then
		print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: DashDebounce ativo")
		return false
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: sem Humanoid/HumRP")
		return false
	end

	if Character:GetAttribute("Dashing") == true then
		print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: ja Dashing")
		return false
	end

	local Trapped = EvasiveService:IsTrapped(Character)
	print("[DASH][" .. Player.Name .. "] Dash() Trapped=" .. tostring(Trapped))

	if not Trapped and Character:HasTag("CantDash") then
		print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: tag CantDash")
		return false
	end

	if Direction == "Front" and Trapped then
		local Side = HumRP.CFrame.RightVector:Dot(Humanoid.MoveDirection)
		Direction = Side < 0 and "Left" or "Right"
		print("[DASH][" .. Player.Name .. "] Dash() Trapped + Front -> redirecionado para " .. Direction)
	end

	if Trapped then
		if not EvasiveService:CanEscape(Character) then
			print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: Trapped e nao pode escapar")
			return false
		end
		if not EvasiveService:Escape(Character) then
			print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: Escape() falhou")
			return false
		end
	else
		if Character:HasTag("Stunned") then
			print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: Stunned")
			return false
		end

		local CooldownId = AxisKey[Direction] or ("Dash_" .. Direction)

		if CooldownSystem:IsOnCooldown(Character, CooldownId) then
			print("[DASH][" .. Player.Name .. "] Dash() ABORTADO: cooldown ativo para " .. CooldownId)
			return false
		end
	end

	local Config = getConfig(Player, Direction)
	if not Config then
		warn("[DashHandler] No dash config for direction " .. Direction)
		return false
	end

	print(
		"[DASH]["
			.. Player.Name
			.. "] Dash() Config resolvido | Id="
			.. tostring(Config.Id)
			.. " Type="
			.. tostring(Config.Type)
	)

	local Cooldown = Config.Cooldown or 2
	local CooldownId = AxisKey[Direction] or ("Dash_" .. Direction)

	CooldownSystem:Set(Character, CooldownId, Cooldown)
	RemoteManager.FireClient(Player, "ExtraCds", Direction .. "Dash", Cooldown)
	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })

	DashDebounce[Character] = true
	task.delay(DASH_INPUT_DEBOUNCE, function()
		DashDebounce[Character] = nil
	end)

	if Config.Type == "Attack" then
		SFXModule:Play("DashStart", HumRP)
	else
		SFXModule:Play("Dash", HumRP)
	end

	if Config.Type == "Attack" then
		print("[DASH][" .. Player.Name .. "] Dash() -> runAttackDash")
		runAttackDash(Player, Character, HumRP, Humanoid, Config)
	else
		print("[DASH][" .. Player.Name .. "] Dash() -> runDisplacementDash")
		runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	end

	return true
end

return DashHandler
