local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local Resources = Constants.Resources

return function(Params)
	if Params.char then
		local Character = Params and Params.char

		local start = time()

		task.spawn(function()
			while time() - start < Params.time do
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Include
				params.FilterDescendantsInstances = { workspace.Map }

				local BodySmokez = Resources.Effects.DashSmoke:Clone()
				BodySmokez.Parent = workspace.Thrown
				BodySmokez.Smoke.Enabled = true

				task.delay(0.07, function()
					if BodySmokez.Parent then
						BodySmokez.Smoke.Enabled = false
					end
				end)

				Debris:AddItem(BodySmokez, 5)

				local raycast = workspace:Raycast(Character.PrimaryPart.Position, Vector3.new(0, -5, 0), params)

				if raycast then
					BodySmokez.CFrame = Character.PrimaryPart.CFrame
					BodySmokez.Position = raycast.Position + Vector3.new(0, 0.1, 0)
					BodySmokez.Smoke.Color = ColorSequence.new(raycast.Instance.Color)
				end

				task.wait(0.1)
			end
		end)
	end
end
