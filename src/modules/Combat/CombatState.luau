local CombatState = {}

--[[
	Estado por player:

	characterName    string   -- nome do personagem ativo
	comboStep        number   -- passo atual do combo M1 (1-4)
	lastAttackTime   number   -- tick() do ultimo ataque (reset de combo)

	inAttack         bool     -- esta executando um ataque agora
	inEndlag         bool     -- esta no endlag de um ataque

	cancelTier       number   -- tier de cancelabilidade do ataque ATUAL pelo proprio jogador
	                           --   0 = pode cancelar livremente
	                           --   1 = so cancela se receber knockback de qualquer tier
	                           --   2 = totalmente inparavel pelo proprio jogador
	interruptTier    number   -- quao dificil e interromper este ataque POR INIMIGOS
	                           --   0 = qualquer hit interrompe
	                           --   1 = so ignoreInterrupt >= 1 interrompe
	                           --   2 = so ignoreInterrupt >= 2 interrompe
	                           --   3 = so ignoreInterrupt >= 3 interrompe

	isBlocking       bool     -- esta bloqueando
	iframeType       number   -- tier do iframe ativo (0 = sem iframe)
	isCountering     bool     -- counter ativo
	counterTier      number   -- tier do counter ativo
	counterTarget    Model?   -- personagem que trigou o counter
	counterTriggered bool     -- flag para a skill de counter ler e executar
]]

local DEFAULT = {
	characterName = "Vitality",
	comboStep = 0,
	lastAttackTime = 0,
	inAttack = false,
	inEndlag = false,
	cancelTier = 0,
	interruptTier = 0,
	isBlocking = false,
	iframeType = 0,
	isCountering = false,
	counterTier = 0,
	counterTarget = nil,
	counterTriggered = false,
}

local states = {}

local function ensure(player)
	if not states[player] then
		states[player] = table.clone(DEFAULT)
	end
	return states[player]
end

function CombatState.get(player)
	return ensure(player)
end

function CombatState.set(player, key, value)
	ensure(player)[key] = value
end

function CombatState.reset(player)
	states[player] = table.clone(DEFAULT)
end

function CombatState.clear(player)
	states[player] = nil
end

return CombatState
