local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer
local Resources = Constants.Resources
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule

local SHAKE_RADIUS = 40

return function(Params)
	local Position = Params.Position
	if not Position then
		return
	end

	local Smoke = Resources.Effects.DashSmoke:Clone()
	Smoke.CFrame = CFrame.new(Position)
	Smoke.Parent = workspace.Debris
	Smoke.Smoke.Enabled = true
	ParticlesModule.Emit(Smoke)

	task.delay(0.2, function()
		if Smoke and Smoke.Parent then
			Smoke.Smoke.Enabled = false
		end
	end)
	Debris:AddItem(Smoke, 3)

	local Character = LocalPlayer.Character
	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if HumRP and (HumRP.Position - Position).Magnitude <= SHAKE_RADIUS then
		shared.repfire("ShakeCamera", { Magnitude = 3, Roughness = 6, FadeInTime = 0.05, FadeOutTime = 0.4 })
	end
end
