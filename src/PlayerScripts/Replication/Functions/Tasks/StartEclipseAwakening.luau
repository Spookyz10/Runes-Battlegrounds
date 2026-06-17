local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets
local Debris = Constants.Debris

return function(Params)
	State.EclipseNightTime = 10

	-- Incrementa o contador de noite (mesmo sistema do Lunar)
	State.lunarNightCount += 1
	if State.lunarNightCount == 1 then
		State:tweenToNight()
	end

	-- Registra o character para decrementar quando a animação acabar
	if Params.Character then
		local char = Params.Character
		-- Aguarda o sinal de fim da awakening (tag Awakened sendo removida)
		task.spawn(function()
			-- Espera enquanto o character ainda está Awakened
			while char and char.Parent and char:HasTag("Awakened") do
				task.wait(1)
			end

			-- Animação acabou, decrementa contador
			State.lunarNightCount = math.max(0, State.lunarNightCount - 1)
			if State.lunarNightCount <= 0 then
				State:tweenToDay()
			end
		end)
	end

	local Fog = CharacterAssets.Eclipse:FindFirstChild(Params.FogName):Clone()
	Fog.Parent = workspace
	Fog:PivotTo(Params.Character.PrimaryPart.CFrame + Vector3.new(0, -3, 0))

	Debris:AddItem(Fog, 15)
end
