local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer
local Debris = Constants.Debris
local Resources = Constants.Resources

return function(Params)
	for _, v in workspace.Debris:GetChildren() do
		if v.Name == LocalPlayer.UserId .. " Hitbox" then
			v:Destroy()
		end
	end

	local Visualizer = Resources.Effects.Hitbox:Clone()
	Visualizer.CFrame = Params.CFrame * (Params.Offset or CFrame.new(0, 0, 0))

	if Params.Method == "Box" then
		Visualizer.Size = Params.Size
	else
		Visualizer.Shape = Enum.PartType.Ball
		Visualizer.Size = Vector3.one * Params.Size
	end

	Visualizer.Parent = workspace.Debris
	Debris:AddItem(Visualizer, 0.1)
end
