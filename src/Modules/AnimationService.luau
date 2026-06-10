local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local Animations = SvSt.Assets.Animations
local Resources = RS.Resources

local AnimationsContainers = {
	Animations,
	Resources,
}

local AnimationService = {}
AnimationService.Loaded = {}

function AnimationService:getAnimationTrack(Character, Animation)
	if not Character or not Character.Parent then
		return
	end
	local AnimationTable = AnimationService:getLoadedAnimations(Character)[Animation]

	return AnimationTable[1], AnimationTable[2]
end

function AnimationService:playAnimation(Character, Animation, Speed, TimePosition, FadeInTime)
	if not Character or not Character.Parent or Character:HasTag("Ragdolled") then
		return
	end

	local loadedAnims = AnimationService:getLoadedAnimations(Character)

	local anim = loadedAnims[Animation][1]

	if Animation.Parent.Name ~= "Spawn Animations" then
		for _, Anim in AnimationsContainers[1]["Spawn Animations"]:GetDescendants() do
			if Anim:IsA("Animation") then
				AnimationService:stopAnimation(Character, Anim)
			end
		end
	end

	if Animation.Parent.Name ~= "Emotes" then
		for _, Anim in AnimationsContainers[2]:GetDescendants() do
			if Anim:IsA("Animation") then
				AnimationService:stopAnimation(Character, Anim)
			end
		end
	else
		for _, Track in loadedAnims do
			if Track[1].IsPlaying == true and Track[1].Animation.Parent.Name == "Emotes" then
				AnimationService:stopAnimation(Character, Track[1].Animation)
			end
		end
	end

	anim:AdjustWeight(0.001, 0)
	anim:Play(FadeInTime)

	if Speed then
		anim:AdjustSpeed(Speed)
	end

	if
		Animation.Parent == Animations.Throwables
		or Animation:IsDescendantOf(Animations.Moves)
		or Animation:IsDescendantOf(Animations.Awakenings)
		or Animation:IsDescendantOf(Animations.Combat.Punches)
	then
		anim:AdjustSpeed((Speed or 1))
	end

	if TimePosition then
		anim.TimePosition = TimePosition
	end

	return anim
end

function AnimationService:adjustSpeed(Character, Animation, Speed)
	if not Character or not Character.Parent then
		return
	end
	AnimationService:getLoadedAnimations(Character)[Animation][1]:AdjustSpeed(Speed)
end

function AnimationService:stopAnimation(Character, Animation, FadeTime)
	if not Character or not Character.Parent then
		return
	end

	local playingAnims = AnimationService:getLoadedAnimations(Character)

	if not playingAnims[Animation] then
		return
	end
	local anim = playingAnims[Animation][1]

	if anim then
		if anim.IsPlaying == true then
			anim:Stop(FadeTime)
		end
	end
end

function AnimationService:stopAll(Character, FadeTime)
	if
		not Character
		or not Character.Parent
		or not Character:FindFirstChild("Humanoid")
		or not Character.Humanoid:FindFirstChild("Animator")
	then
		return
	end

	for _, animation in pairs(Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
		animation:Stop(FadeTime)
	end
end

function AnimationService:getLoadedAnimations(Character)
	if not Character or not Character.Parent then
		return
	end
	if not AnimationService.Loaded[Character] then
		AnimationService:loadAnimations(Character)
	end

	return AnimationService.Loaded[Character]
end

function AnimationService:loadAnimations(Character)
	if not Character or not Character.Parent then
		return
	end
	game:GetService("AnimationClipProvider")
	self.Loaded[Character] = {}

	local Animator = Character.Humanoid.Animator

	for _, Container in AnimationsContainers do
		for _, animation in pairs(Container:GetDescendants()) do
			if not animation:IsA("Animation") then
				continue
			end
			if animation.AnimationId == "" then
				continue
			end

			self.Loaded[Character][animation] = {}
			self.Loaded[Character][animation][1] = Animator:LoadAnimation(animation)
			self.Loaded[Character][animation][1].Priority = Enum.AnimationPriority.Action
			self.Loaded[Character][animation][2] = {}

			self.Loaded[Character][animation][1].Stopped:Connect(function()
				for i, v in self.Loaded[Character][animation][2] do
					if typeof(v) ~= "RBXScriptConnection" then
						continue
					end

					v:Disconnect()
					self.Loaded[Character][animation][2][i] = nil
				end
			end)
		end
	end
end

return AnimationService
