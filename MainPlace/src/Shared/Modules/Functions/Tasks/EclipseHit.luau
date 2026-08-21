local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local EnemyCharacter = Params.EChar
	if not EnemyCharacter or not EnemyCharacter.Parent then
		return
	end

	local Head = EnemyCharacter:FindFirstChild("Head")
	if not Head then
		return
	end

	local EclipseClone = CharacterAssets.Eclipse.Lunar.Eclipse:Clone()
	EclipseClone.Name = "Eclipse_FX"
	EclipseClone.Parent = Head

	ParticlesModule.Emit(EclipseClone)

	Debris:AddItem(EclipseClone, 3)
end
