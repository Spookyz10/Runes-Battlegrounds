local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local FADE_DURATION = 1.2
local VISUAL_LIFETIME = 7.8

return function(params)
	local position = params.position
	if not position then
		return
	end

	local ExplosionAsset = CharacterAssets.Eclipse.Solar.Awaken:FindFirstChild("Explosion")
	if not ExplosionAsset then
		return
	end

	local ExplosionClone = ExplosionAsset:Clone()
	local currentCFrame = ExplosionClone:GetPivot()
	ExplosionClone:PivotTo(CFrame.new(position) * currentCFrame.Rotation)
	ExplosionClone.Parent = workspace

	Debris:AddItem(ExplosionClone, VISUAL_LIFETIME + FADE_DURATION + 1)

	task.delay(VISUAL_LIFETIME, function()
		if not ExplosionClone or not ExplosionClone.Parent then
			return
		end
		FadeOut.OutAndDestroy(ExplosionClone, FADE_DURATION)
	end)
end
