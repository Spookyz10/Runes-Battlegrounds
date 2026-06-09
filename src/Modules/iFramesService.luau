local SvSt = game:GetService("ServerStorage")

local MovesetsFolder = SvSt.Movesets

local module = {}

function module:HasiFrame(Character, iFrameName)
	if not Character:GetAttribute("iFrames") then
		Character:SetAttribute("iFrames", 0)
	end

	local Tool = MovesetsFolder:FindFirstChild(iFrameName, true)
	if
		iFrameName == "Awakenings"
		or iFrameName == "M1"
		or iFrameName == "Throwables"
		or (Tool and Tool.Parent.Name ~= "Awakening")
	then
		return Character:GetAttribute("iFrames") >= 1
	elseif Tool and Tool.Parent.Name == "Awakening" then
		return Character:GetAttribute("iFrames") >= 2
	end
end

function module:AddBaseiFrames(Character)
	if Character:GetAttribute("iFrames") and Character:GetAttribute("iFrames") > 1 then
		return "All"
	end
	Character:SetAttribute("iFrames", 1)

	return "Base"
end

function module:AddAlliFrames(Character)
	Character:SetAttribute("iFrames", 2)

	return "All"
end

function module:RemoveAlliFrames(Character)
	Character:SetAttribute("iFrames", 0)
end

function module:RemoveiFrames(Character, iFrameHandle)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return
	end

	if iFrameHandle == "All" then
		Character:SetAttribute("iFrames", 0)
	elseif iFrameHandle == "Base" then
		if current <= 1 then
			Character:SetAttribute("iFrames", 0)
		end
	end
end

return module
