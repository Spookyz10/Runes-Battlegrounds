local TweenService = game:GetService("TweenService")
local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Position = Params.position
	if not Position then
		return
	end

	local Assets = CharacterAssets.Eclipse.Lunar
	local HandAsset = Assets:FindFirstChild("Hand")
	local VFXAsset = Assets:FindFirstChild("HandVFX")

	local Clone = HandAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Position + Vector3.new(0, 0, -3)

	local VFXClone = VFXAsset:Clone()
	VFXClone.Parent = workspace
	VFXClone.Position = Position + Vector3.new(0, 0, -3)

	local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(Clone, TweenInfo, { Position = Position + Vector3.new(0, 0, -30) }):Play()

	tween.Completed:Wait()
	Debris:AddItem(VFXClone, 1)
	Debris:AddItem(Clone, 1)
end
