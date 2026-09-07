local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

local ARM_OFFSET_POSITION = Vector3.new(0, 0, 0)
local ARM_OFFSET_ROTATION = Vector3.new(-90, 0, 0)

local ActiveArmVFX = {}

local function doStart(Char)
	local RightArm = Char:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end

	local ProwlAssets = CharacterAssets.Eclipse.Lunar:FindFirstChild("Prowl")
	if not ProwlAssets then
		return
	end

	local FinalImpact = ProwlAssets:FindFirstChild("FinalImpact")
	if not FinalImpact then
		return
	end

	-- caso ainda exista um clone ativo desse char, limpa antes de criar outro
	local Existing = ActiveArmVFX[Char]
	if Existing and Existing.Parent then
		Existing:Destroy()
	end

	local FIClone = FinalImpact:Clone()
	FIClone.Name = "FinalImpact"
	FIClone.Anchored = false

	FIClone.CFrame = RightArm.CFrame
		* CFrame.new(ARM_OFFSET_POSITION)
		* CFrame.Angles(
			math.rad(ARM_OFFSET_ROTATION.X),
			math.rad(ARM_OFFSET_ROTATION.Y),
			math.rad(ARM_OFFSET_ROTATION.Z)
		)

	FIClone.Parent = RightArm

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = RightArm
	Weld.Part1 = FIClone
	Weld.Parent = FIClone

	ActiveArmVFX[Char] = FIClone
	Debris:AddItem(FIClone, 8)
	FIClone.Destroying:Once(function()
		if ActiveArmVFX[Char] == FIClone then
			ActiveArmVFX[Char] = nil
		end
	end)
end

local function doEnd(Char)
	local FIClone = ActiveArmVFX[Char]
	if not FIClone or not FIClone.Parent then
		ActiveArmVFX[Char] = nil
		return
	end

	local VFX = FIClone:FindFirstChild("VFX")
	if VFX then
		local Impact = VFX:FindFirstChild("Impact")
		local Impact2 = VFX:FindFirstChild("Impact2")

		if Impact then
			ParticlesModule.Emit(Impact)
		end
		if Impact2 then
			ParticlesModule.Emit(Impact2)
		end
	end

	ActiveArmVFX[Char] = nil
	Debris:AddItem(FIClone, 0.3)
end

return function(Params)
	local Char = Params and Params.Char
	if not Char then
		return
	end

	if Params.func == "Start" and Char.Parent then
		doStart(Char)
	elseif Params.func == "End" then
		doEnd(Char)
	end
end
