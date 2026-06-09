local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


local RS_Modules = RS.Modules

local Utility = require(RS_Modules:WaitForChild("Utility"))
local ParticlesModule: particlesModule = Utility('Particles')



local function GetTweenInfoFromAttributes(object, duration, attributePrefix, defaultStyle)
	local tweenParamsString = object:GetAttribute(attributePrefix .. "_TweenParams")
	local defaultTweenSettings = {
		{ "TweenStyle", defaultStyle },
		{ "TweenDirection", Enum.EasingDirection.Out }
	}
	local tweenSettings = {}

	if typeof(tweenParamsString) == "string" then
		local parsedParams = { tweenParamsString:match("(%a+),(%a+)") }
		for i = 1, 2 do
			local param = parsedParams[i]
			local settingInfo = defaultTweenSettings[i]
			local settingName = settingInfo[1]
			local defaultValue = settingInfo[2]

			if param then
				if param == "Out" or param == "In" or param == "InOut" then
					tweenSettings[settingName] = Enum.EasingDirection[param]
				else
					tweenSettings[settingName] = Enum.EasingStyle[param]
				end
			else
				tweenSettings[settingName] = defaultValue
			end
		end
	else
		for _, settingInfo in defaultTweenSettings do
			tweenSettings[settingInfo[1]] = settingInfo[2]
		end
	end

	return TweenInfo.new(duration, tweenSettings.TweenStyle, tweenSettings.TweenDirection)
end

local function TweenParts(container: Instance)
	for _, visualObject in pairs(container:GetChildren()) do
		local endInstance = visualObject:FindFirstChild("End")
		if not endInstance then
			warn("Goal is not defined.")
			return
		end

		local startClone = visualObject.Start:Clone()
		local startTransparency = tonumber(visualObject:GetAttribute("StartTransparency")) or 0

		if startClone:IsA("MeshPart") then
			startClone.Transparency = startTransparency
		elseif startClone:IsA("BasePart") and startClone:FindFirstChildOfClass("Decal") then
			startClone.Transparency = 1
		end

		startClone.Parent = workspace.CurrentCamera
		local tweenDuration = tonumber(visualObject:GetAttribute("Duration")) or 0.1

		if startClone:FindFirstChildOfClass("Decal") then
			TweenService:Create(startClone, GetTweenInfoFromAttributes(visualObject, tweenDuration, "Part", Enum.EasingStyle.Cubic), {
				Size = endInstance.Size,
				CFrame = endInstance.CFrame
			}):Play()
		else
			TweenService:Create(startClone, GetTweenInfoFromAttributes(visualObject, tweenDuration, "Part", Enum.EasingStyle.Cubic), {
				Size = endInstance.Size,
				CFrame = endInstance.CFrame,
				Transparency = 1
			}):Play()
		end

		local startMesh = startClone:FindFirstChildOfClass("SpecialMesh")
		local endMesh = endInstance:FindFirstChildOfClass("SpecialMesh")

		if startMesh and endMesh then
			TweenService:Create(startMesh, GetTweenInfoFromAttributes(visualObject, tweenDuration, "Mesh", Enum.EasingStyle.Sine), {
				Scale = endMesh.Scale
			}):Play()
		end

		local startDecal = startClone:FindFirstChildOfClass("Decal")
		local endDecal = endInstance:FindFirstChildOfClass("Decal")

		if startDecal and endDecal then
			startDecal.Transparency = 0
			TweenService:Create(startDecal, GetTweenInfoFromAttributes(visualObject, tweenDuration, "Decal", Enum.EasingStyle.Cubic), {
				Transparency = endDecal.Transparency,
				Color3 = endDecal.Color3
			}):Play()
		end

		task.delay(tweenDuration, startClone.Destroy, startClone)
	end
end


return {
	[0.367] = function(target, _, _)
		ParticlesModule.Emit(target.PartHolder.TPStartOne)
	end,
	
	[1] = function(_, character, _)
		ParticlesModule.Enabled(character.Torso.Spin, true)
		
		ParticlesModule.Emit(character.Torso.Spin)
	end,
	
	[1.417] = function(character, _, _)
		ParticlesModule.EnableTrail(character["Left Leg"].Trails, true)
	end,
	
	[1.5] = function(_, character, _)
		ParticlesModule.Emit(character.HumanoidRootPart.Hits.One)
		
		ParticlesModule.Enabled(character.Torso.Spin, false)
	end,
	
	[1.7] = function(_, character, _)
		ParticlesModule.Emit(character.HumanoidRootPart.Hits.Two)
	end,
	
	[1.933] = function(_, character, _)
		ParticlesModule.Emit(character.HumanoidRootPart.Hits.Three)
	end,
	
	[2] = function(character, _, visualEffects)
		TweenParts(visualEffects.DashLand)
		ParticlesModule.EnableTrail(character["Left Leg"].Trails, false)
		ParticlesModule.Enabled(character["Dust Track"], true)
	end,
	
	[2.267] = function(character, _, _)
		ParticlesModule.Emit(character.Head.EyeFlash)
	end,
	
	[2.367] = function(character, _, _)
		ParticlesModule.Enabled(character["Dust Track"], false)
	end,
	
	[2.6] = function(_, character, visualEffects)
		ParticlesModule.Emit(character.HumanoidRootPart.End)
		TweenParts(visualEffects.End)
	end
}