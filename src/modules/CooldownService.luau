--[[
	CooldownService
	src/modules/CooldownService.luau

	Gerencia cooldowns por player + chave.
	Completamente independente — sem dependências internas.

	API:
	  CooldownService.start(player, key, duration)
	    → Inicia um cooldown. Retorna false se já estiver em cooldown.

	  CooldownService.check(player, key)
	    → Retorna true se o cooldown JÁ PASSOU (livre pra usar).

	  CooldownService.remaining(player, key)
	    → Retorna segundos restantes (0 se livre).

	  CooldownService.reset(player, key)
	    → Reseta um cooldown específico (libera imediatamente).

	  CooldownService.resetAll(player)
	    → Reseta TODOS os cooldowns de um player.

	  CooldownService.resetKey(key)
	    → Reseta um cooldown específico para TODOS os players.

	  CooldownService.clear(player)
	    → Remove completamente o player da tabela (usar no PlayerRemoving).

	  CooldownService.getAll(player)
	    → Retorna { [key] = remainingSeconds } para debug/UI.

	Uso típico em uma skill:
	  local ok = CooldownService.start(player, "JawBreaker", 8)
	  if not ok then return end  -- ainda em cooldown
	  ... executa a skill ...
]]

local CooldownService = {}

-- { [player] = { [key] = expireTime } }
local data = {}

local function ensure(player)
	if not data[player] then
		data[player] = {}
	end
	return data[player]
end

--[[ Tenta iniciar um cooldown.
     Retorna true  → cooldown iniciado com sucesso (pode usar a skill).
     Retorna false → ainda em cooldown (bloqueado). ]]
function CooldownService.start(player, key, duration)
	local now = tick()
	local playerData = ensure(player)

	local expire = playerData[key]
	if expire and now < expire then
		return false -- ainda em cooldown
	end

	playerData[key] = now + duration
	return true
end

--[[ Retorna true se o player PODE usar (cooldown zerado ou inexistente). ]]
function CooldownService.check(player, key)
	local playerData = data[player]
	if not playerData then
		return true
	end
	local expire = playerData[key]
	if not expire then
		return true
	end
	return tick() >= expire
end

--[[ Retorna quantos segundos faltam. 0 se já liberado. ]]
function CooldownService.remaining(player, key)
	local playerData = data[player]
	if not playerData then
		return 0
	end
	local expire = playerData[key]
	if not expire then
		return 0
	end
	local remaining = expire - tick()
	return remaining > 0 and remaining or 0
end

--[[ Reseta um cooldown específico de um player. ]]
function CooldownService.reset(player, key)
	local playerData = data[player]
	if playerData then
		playerData[key] = nil
	end
end

--[[ Reseta TODOS os cooldowns de um player. ]]
function CooldownService.resetAll(player)
	data[player] = {}
end

--[[ Reseta uma key específica para TODOS os players online. ]]
function CooldownService.resetKey(key)
	for _, playerData in data do
		playerData[key] = nil
	end
end

--[[ Remove o player da memória (chamar em PlayerRemoving). ]]
function CooldownService.clear(player)
	data[player] = nil
end

--[[ Retorna tabela { [key] = remainingSeconds } para debug ou HUD. ]]
function CooldownService.getAll(player)
	local playerData = data[player]
	if not playerData then
		return {}
	end
	local now = tick()
	local result = {}
	for key, expire in playerData do
		local rem = expire - now
		result[key] = rem > 0 and rem or 0
	end
	return result
end

-- Limpeza automática quando o player sai
local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(player)
	CooldownService.clear(player)
end)

return CooldownService
