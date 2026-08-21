local AnimationStorage = {}
local module = {}

module.playAnimation = function(Animator, AnimationId, BypassRagdoll)
	if
		not AnimationId
		or not Animator
		or not Animator.Parent
		or (Animator.Parent.Parent:HasTag("Ragdolled") and not BypassRagdoll)
	then
		return
	elseif rawget(AnimationStorage, AnimationId) then
		return AnimationStorage[AnimationId]
	else
		if typeof(AnimationId) == "string" and string.find(AnimationId, "rbxassetid") then
			AnimationId = tonumber((string.gsub(AnimationId, "rbxassetid://", ""):gsub("[^%-%d]", "")))
		end

		local Animation = Instance.new("Animation")
		if typeof(AnimationId) == "string" then
			Animation.AnimationId = AnimationId
		elseif typeof(AnimationId) == "number" then
			Animation.AnimationId = "rbxassetid://" .. AnimationId
		elseif typeof(AnimationId) == "Instance" and game:GetService("RunService"):IsStudio() then
			Animation.AnimationId = game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(AnimationId)
		end

		local AnimationTrack = Animator:LoadAnimation(Animation)
		AnimationStorage[AnimationId] = AnimationTrack
		AnimationTrack:AdjustWeight(0.001)

		return AnimationTrack
	end
end

module.GetStorage = function()
	return AnimationStorage
end

return module
