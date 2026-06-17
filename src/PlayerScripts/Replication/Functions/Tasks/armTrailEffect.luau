local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local Resources = Constants.Resources
local BoatTween = Constants.BoatTween

return function(Params)
	local waterPalm = Resources.Effects.ArmTrailEffect:Clone()

	local lifeTime = Params.lifeTime

	if lifeTime then
		local limbName = Params and Params.limbName

		for i, v in next, Params.char:GetChildren() do
			if v:IsA("BasePart") then
				if v.Name == limbName then
					waterPalm.Parent = workspace.Thrown
					waterPalm.CFrame = v.CFrame

					local weld = Instance.new("Weld", waterPalm)

					weld.Part0 = waterPalm
					weld.Part1 = v
				end
			end
		end

		for i, v in next, waterPalm:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end

			if v:IsA("Trail") then
				v.Enabled = true
			end
		end

		task.delay(lifeTime, function()
			for i, v in next, waterPalm:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end

				if v:IsA("Trail") then
					BoatTween:Create(v, {
						Time = 0.55,
						EasingStyle = "EntranceExpressive",
						EasingDirection = "In",

						Reverses = false,
						DelayTime = 0,
						RepeatCount = 0,

						StepType = "Renderstepped",

						Goal = {
							Transparency = NumberSequence.new(1, 1),
						},
					}):Play()
				end
			end

			Debris:AddItem(waterPalm, 0.65)
		end)
	end
end
