-- Em: src/PlayerScripts/Replication/Functions/Tasks.luau (adicionar esta entrada)
-- Handler client-side do evento "SolarAwakenExplosion"
--
-- O server envia: { char = Character, position = Vector3 }
-- O client clona o ExplosionAsset, posiciona, deixa tocar e então
-- aplica FadeOut antes de destruir — sem custo no server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut) -- ajuste o path conforme sua estrutura

local FADE_DURATION = 1.2 -- duração do fade out em segundos
local VISUAL_LIFETIME = 5 -- quanto tempo o efeito fica visível antes de começar o fade

return function(params)
	local position = params.position
	if not position then
		return
	end

	local ExplosionAsset = CharacterAssets.Eclipse.Solar.Awaken:FindFirstChild("Explosion")
	if not ExplosionAsset then
		return
	end

	local ExplosionClone = ExplosionAsset:Clone()
	local currentCFrame = ExplosionClone:GetPivot()
	ExplosionClone:PivotTo(CFrame.new(position) * currentCFrame.Rotation)
	ExplosionClone.Parent = workspace

	-- Garante que não fica pra sempre no workspace mesmo se algo der errado
	Debris:AddItem(ExplosionClone, VISUAL_LIFETIME + FADE_DURATION + 1)

	-- Após o tempo de vida visual, inicia o fade out e destrói ao terminar
	task.delay(VISUAL_LIFETIME, function()
		if not ExplosionClone or not ExplosionClone.Parent then
			return
		end
		FadeOut.OutAndDestroy(ExplosionClone, FADE_DURATION)
	end)
end
