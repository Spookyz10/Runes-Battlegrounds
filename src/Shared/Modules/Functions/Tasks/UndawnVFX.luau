local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)
local Particles = require(ReplicatedStorage.Shared.Modules.Utility.Particles)

local UndawnAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Solar.Undawn

local activeIndicators = {}

local Handlers = {}

function Handlers.Indicator(params)
	local char = params.char
	local beamPos = params.beamPos
	if not char or not beamPos then
		return
	end

	if not activeIndicators[char] then
		activeIndicators[char] = {}
	end

	local indicator = UndawnAssets.UndawnIndicator:Clone()
	indicator.Parent = workspace
	indicator.CFrame = CFrame.new(beamPos.X, beamPos.Y, beamPos.Z)

	table.insert(activeIndicators[char], indicator)
end

function Handlers.IndicatorRemove(params)
	local char = params.char
	if not char then
		return
	end

	local list = activeIndicators[char]
	if not list then
		return
	end

	for _, indicator in list do
		if not indicator or not indicator.Parent then
			continue
		end
		for _, desc in indicator:GetDescendants() do
			if desc:IsA("ParticleEmitter") or desc:IsA("Beam") then
				desc.Enabled = false
			end
		end
		Debris:AddItem(indicator, 3)
	end

	activeIndicators[char] = nil
end

function Handlers.Arms(params)
	local char = params.char
	if not char then
		return
	end

	local rightArm = char:FindFirstChild("Right Arm")
	local leftArm = char:FindFirstChild("Left Arm")
	if not rightArm or not leftArm then
		return
	end

	for _, emitter in UndawnAssets.SolarArm:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local rClone = emitter:Clone()
		rClone:SetAttribute("UndawnArm", true)
		rClone.Parent = rightArm

		local lClone = emitter:Clone()
		lClone:SetAttribute("UndawnArm", true)
		lClone.Parent = leftArm
	end
end

function Handlers.ArmsRemove(params)
	local char = params.char
	if not char then
		return
	end

	for _, limbName in { "Right Arm", "Left Arm" } do
		local limb = char:FindFirstChild(limbName)
		if not limb then
			continue
		end
		for _, child in limb:GetChildren() do
			if child:IsA("ParticleEmitter") and child:GetAttribute("UndawnArm") then
				FadeOut.OutAndDestroy(child, 0.5)
			end
		end
	end
end

function Handlers.Beam(params)
	local char = params.char
	local beamPositions = params.beamPositions
	if not char or not beamPositions or #beamPositions == 0 then
		return
	end

	for _, beamPos in beamPositions do
		local beamModel = UndawnAssets.UndawnExplosion:Clone()
		local originCF = CFrame.new(beamPos.X, beamPos.Y, beamPos.Z)
		beamModel:PivotTo(originCF)
		beamModel.Parent = workspace
		Particles.Emit(beamModel)

		Debris:AddItem(beamModel, 2)
	end
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
