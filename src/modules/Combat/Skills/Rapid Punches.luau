--[[
	Skill: RapidPunches
	src/modules/Combat/Skills/Rapid Punches.luau

	Personagem: Vitality
	Cooldown: 10 segundos
]]

local RapidPunches = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)
local CombatService = require(script.Parent.Parent.CombatService)
local CombatState = require(script.Parent.Parent.CombatState)
local CooldownService = require(ServerStorage.Modules.CooldownService)

local COOLDOWN = 10 -- segundos
local PUNCH_COUNT = 6
local PUNCH_INTERVAL = 0.12
local PUNCH_SIZE = Vector3.new(5, 5, 4)
local PUNCH_OFFSET = Vector3.new(0, 0, -2)

--[[
	Dados do soco final.
	ignoreCounterTier = 1 → ignora counters tier 1.
	ignoreInterrupt   = 1 → interrompe ataques com interruptTier <= 1.
	ignoreIframe      = 1 → passa por iframes tier 1.
	interruptTier     = 1 → socos intermediários só são interrompidos por ignoreInterrupt >= 1.
]]
local FINAL_PUNCH = {
	windup = 0.10,
	endlag = 0.40,
	endlagMiss = 0.55,
	hitbox = Vector3.new(5.5, 5, 4.5),
	hitboxOffset = PUNCH_OFFSET,
	canMove = false,
	cancelTier = 1,
	interruptTier = 1,
	ignoreIframe = 1,
	ignoreCounterTier = 1,
	ignoreInterrupt = 1,
	ignoreBlock = false,
	knockback = { horizontal = 60, vertical = 12, duration = 1.4 },
}

function RapidPunches.execute(player, character)
	local state = CombatState.get(player)
	if state.inAttack or state.inEndlag then
		return
	end

	-- Verifica e inicia cooldown
	local ok = CooldownService.start(player, "RapidPunches", COOLDOWN)
	if not ok then
		return
	end

	state.inAttack = true
	state.cancelTier = 1
	state.interruptTier = 1

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.JumpPower = 0

	for i = 1, PUNCH_COUNT do
		if not state.inAttack then
			break
		end

		task.wait(PUNCH_INTERVAL)

		if not state.inAttack then
			break
		end

		local root = character:FindFirstChild("HumanoidRootPart")

		-- Usa a nova API do HitboxService
		local hits = HitboxService.query({
			origin = root.CFrame,
			size = PUNCH_SIZE,
			offset = PUNCH_OFFSET,
			exclude = { character },
		})

		for _, victimChar in hits do
			local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
			if not victimPlayer then
				continue
			end
			local victimState = CombatState.get(victimPlayer)
			local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")

			-- Iframe: socos intermediários têm ignoreIframe = 1
			if victimState.iframeType > 1 then
				continue
			end

			-- Counter tier 2 funciona contra socos intermediários
			if victimState.isCountering and victimState.counterTier > 1 then
				victimState.counterTriggered = true
				victimState.counterTarget = character
				if state.cancelTier >= 1 then
					CombatService.interruptSelf(player, character)
				end
				break
			end

			-- Block
			if victimState.isBlocking then
				local toAttacker = (root.Position - victimRoot.Position)
				toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
				if toAttacker:Dot(victimRoot.CFrame.LookVector) > 0 then
					continue
				end
			end

			-- Interrupt
			if victimState.inAttack and victimState.interruptTier <= 1 then
				CombatService.forceInterrupt(victimPlayer, victimChar)
			end

			-- Hit leve (sem ragdoll)
			KnockbackService.applyFromHit(victimChar, root.Position, 8, 2)
		end
	end

	-- Soco final
	if state.inAttack then
		CombatService.executeAttack(player, character, FINAL_PUNCH, { character })
	else
		state.inAttack = false
		state.inEndlag = false
		humanoid.JumpPower = 50
	end
end

return RapidPunches
