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
	[1.383] = function(character, _, _)
		ParticlesModule.Emit(character["Right Arm"].ChargeUp)
	end,
	
	[1.667] = function(_, character, _)
		ParticlesModule.Emit(character.HumanoidRootPart.BroHENEVADIDTHIS)
	end,
	
	[2.45] = function(_, character, _)
		ParticlesModule.Emit(character.HumanoidRootPart.KRATOSOROKURAN)
	end,
	
	[3.25] = function(_, character, visuals)
		ParticlesModule.Emit(character.HumanoidRootPart.HAYMAKERS)
		TweenParts(visuals.EndPunch)
	end,
	
	[3.633] = function(_, character, visuals)
		ParticlesModule.Emit(character.HumanoidRootPart.End)
		
		ParticlesModule.Enabled(character.HumanoidRootPart.End, true)
		TweenParts(visuals.End)
	end,
	
	[4.167] = function(_, character, _)
		ParticlesModule.Enabled(character.HumanoidRootPart.End, false)
	end
}