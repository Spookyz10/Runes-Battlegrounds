local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule

return function(Params)
	local EnemyChar = Params.Char
	if not EnemyChar or not EnemyChar.Parent then
		return
	end

	local HumRP = EnemyChar:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local SlamExplosion = Constants.Resources.Effects:FindFirstChild("Downslam")

	if not SlamExplosion then
		return
	end

	local Clone = SlamExplosion:Clone()
	Clone.Parent = workspace
	Clone.CFrame = HumRP.CFrame + Vector3.new(0, -3, -2)

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
end
