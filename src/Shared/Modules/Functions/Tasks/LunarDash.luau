local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local CharacterAssets = Constants.CharacterAssets
local ParticlesModule = Constants.ParticlesModule

return function(Params)
	local char = Params.char
	local HumRP = char.PrimaryPart
	local DashSmoke = CharacterAssets.Eclipse.Lunar.DashSmoke:Clone()
	local Circle = CharacterAssets.Eclipse.Lunar.Circle:Clone()

	DashSmoke.Parent = char
	Circle.Parent = char

	DashSmoke.CFrame = HumRP.CFrame + Vector3.new(0, -2, -4)
	Circle.CFrame = HumRP.CFrame + Vector3.new(0, -3, 0)

	ParticlesModule.Emit(DashSmoke)
	ParticlesModule.Emit(Circle)

	Debris:AddItem(DashSmoke, 1)
	Debris:AddItem(Circle, 1)
end
