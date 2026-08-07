local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local RS = Constants.RS

return function(AnimationsList)
	local PreloadRig = workspace:WaitForChild("Preloader")
	local Animator = PreloadRig:WaitForChild("Humanoid"):WaitForChild("Animator")

	for _, AnimationId in
		{
			98691909912183,
			115733546570440,
		}
	do
		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://" .. AnimationId

		Animator:LoadAnimation(Animation)
		Animation:Destroy()
	end

	for _, AnimationId in AnimationsList do
		if not AnimationId or AnimationId == "" then
			continue
		end
		local Animation = Instance.new("Animation")
		Animation.AnimationId = AnimationId

		Animator:LoadAnimation(Animation)
		Animation:Destroy()
	end

	for _, Animation: Animation in RS:GetDescendants() do
		if Animation:IsA("Animation") and Animation.AnimationId ~= "" then
			Animator:LoadAnimation(Animation)
		end
	end

	Debris:AddItem(PreloadRig, 5)
end
