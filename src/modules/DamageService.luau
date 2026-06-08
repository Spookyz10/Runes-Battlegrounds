local DamageService = {}

--[[
	DamageService.apply(victim, amount)
	  Aplica dano ao personagem. Ponto central pra hooks futuros
	  (resistência, eventos de morte, multiplicadores, etc).
]]

function DamageService.apply(victim, amount)
	local humanoid = victim:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	humanoid:TakeDamage(amount)
end

return DamageService
