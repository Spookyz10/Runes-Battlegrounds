local ServerStorage = game:GetService("ServerStorage")

local SvModules = ServerStorage.Modules
local DamageHandler = require(SvModules.DamageHandler)
local PerfectKnockback = require(SvModules.PerfectKnockback)
local RagdollHandler = require(SvModules.RagdollHandler)

local DebrisDamage = {}

local DEBUG = true

local MIN_SPEED_TO_HURT = 5
local INSTAKILL_DAMAGE = math.huge
local IMPACT_RAGDOLL_DURATION = 2

local function dprint(...)
	if DEBUG then
		print("[DebrisDamage]", ...)
	end
end

local function getDebrisDamage(part)
	if part:GetAttribute("InstaKill") then
		return INSTAKILL_DAMAGE
	end
	local sizeMagnitude = part.Size.Magnitude
	return math.clamp(sizeMagnitude * 0.9, 2, 90)
end

local function cancelKnockbackState(character)
	local cancelOk, cancelErr = pcall(function()
		PerfectKnockback:Cancel(character)
	end)
	if not cancelOk then
		dprint("AVISO: falha ao cancelar PerfectKnockback -", cancelErr)
	end

	character:RemoveTag("Knockbacked")
	character:RemoveTag("CantRotate")

	local HumRP = character:FindFirstChild("HumanoidRootPart")
	if HumRP then
		for _, mover in HumRP:GetChildren() do
			if
				mover:IsA("BodyVelocity")
				or mover:IsA("BodyPosition")
				or mover:IsA("BodyGyro")
				or mover:IsA("LinearVelocity")
				or mover:IsA("BodyAngularVelocity")
			then
				mover:Destroy()
			end
		end
	end
end

function DebrisDamage:Track(Part, OwnerPlayer)
	local hasHit = {}
	local DamagerCharacter = OwnerPlayer and OwnerPlayer.Character

	dprint("Tracking iniciado para", Part.Name, "- Owner:", OwnerPlayer and OwnerPlayer.Name or "nil")

	Part.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if hasHit[character] then
			return
		end
		if DamagerCharacter and character == DamagerCharacter then
			return
		end

		local speed = Part.AssemblyLinearVelocity.Magnitude
		if speed < MIN_SPEED_TO_HURT and not Part:GetAttribute("InstaKill") then
			dprint("Touched ignorado - velocidade baixa demais:", speed)
			return
		end

		hasHit[character] = true

		local damage = getDebrisDamage(Part)
		local damageDealer = DamagerCharacter or character

		dprint("Impacto em", character.Name, "- Dano:", damage, "- Speed:", speed)

		cancelKnockbackState(character)

		local ok, err = pcall(function()
			DamageHandler:TakeDamage(
				damageDealer,
				humanoid,
				damage,
				nil,
				nil,
				false,
				false,
				true,
				false,
				false,
				nil,
				nil
			)
		end)

		if not ok then
			dprint("AVISO: DamageHandler falhou -", err, "- aplicando fallback direto")
			pcall(function()
				humanoid:TakeDamage(damage == math.huge and humanoid.Health or damage)
			end)
		end

		if humanoid.Health > 0 then
			local ragdollOk, ragdollErr = pcall(function()
				RagdollHandler.ragdoll(humanoid, IMPACT_RAGDOLL_DURATION, false, damageDealer, nil, nil, false)
			end)
			if not ragdollOk then
				dprint("AVISO: falha ao aplicar ragdoll -", ragdollErr)
			else
				dprint("Ragdoll de", IMPACT_RAGDOLL_DURATION, "s aplicado em", character.Name)
			end
		end
	end)
end

function DebrisDamage:TrackFall(Part, OwnerPlayer)
	local hasHit = {}
	local DamagerCharacter = OwnerPlayer and OwnerPlayer.Character

	Part.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if hasHit[character] then
			return
		end
		if DamagerCharacter and character == DamagerCharacter then
			return
		end

		hasHit[character] = true

		local damage = getDebrisDamage(Part)
		local damageDealer = DamagerCharacter or character

		cancelKnockbackState(character)

		local ok, err = pcall(function()
			DamageHandler:TakeDamage(
				damageDealer,
				humanoid,
				damage,
				nil,
				nil,
				false,
				false,
				true,
				false,
				false,
				nil,
				nil
			)
		end)

		if not ok then
			pcall(function()
				humanoid:TakeDamage(damage)
			end)
		end

		if humanoid.Health > 0 then
			pcall(function()
				RagdollHandler.ragdoll(humanoid, IMPACT_RAGDOLL_DURATION, false, damageDealer, nil, nil, false)
			end)
		end
	end)
end

return DebrisDamage
