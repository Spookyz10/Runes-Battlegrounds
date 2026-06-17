local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets
local Debris = Constants.Debris

return function(Params)
	State.EclipseNightTime = 10

	local Fog = CharacterAssets.Eclipse:FindFirstChild(Params.FogName):Clone()
	Fog.Parent = workspace
	Fog:PivotTo(Params.Character.PrimaryPart.CFrame + Vector3.new(0, -3, 0))

	Debris:AddItem(Fog, 15)
end
