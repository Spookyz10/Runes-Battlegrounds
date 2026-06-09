--// VARIABLES
local Module = {}

--// MODULE FUNCTIONS
function Module.Load(
	target: Model | Humanoid | AnimationController | Animator,
	animation: Animation,
	dontAutoClean: boolean?
)
	local animator
	if target:IsA("Model") then
		local controller = target:FindFirstChild("Humanoid") or target:FindFirstChild("AnimationController")
		if controller then
			animator = controller:FindFirstChild("Animator")
		end
	elseif target:IsA("Humanoid") or target:IsA("AnimationController") then
		animator = target:FindFirstChild("Animator")
	elseif target:IsA("Animator") then
		animator = target :: Animator
	end

	local animationTrack = animator:LoadAnimation(animation)
	if not dontAutoClean then
		animationTrack.Ended:Connect(function()
			animationTrack:Destroy()
		end)
	end

	return animationTrack
end

function Module.Play(
	target: Model | Humanoid | AnimationController | Animator,
	animation: Animation,
	dontAutoClean: boolean?
)
	local animationTrack = Module.Load(target, animation, dontAutoClean)
	animationTrack:Play()
	return animationTrack
end

return Module
