local module = {}

function module:HasiFrame(Character, pierceLevel)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return false
	end

	local level = pierceLevel or 0

	return current > level
end

function module:AddBaseiFrames(Character)
	local current = Character:GetAttribute("iFrames") or 0
	if current >= 1 then
		return
	end
	Character:SetAttribute("iFrames", 1)
end

function module:AddStrongiFrames(Character)
	local current = Character:GetAttribute("iFrames") or 0
	if current >= 2 then
		return
	end
	Character:SetAttribute("iFrames", 2)
end

function module:AddAlliFrames(Character)
	Character:SetAttribute("iFrames", 3)
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
	elseif iFrameHandle == "Strong" then
		if current >= 2 then
			Character:SetAttribute("iFrames", 1)
		end
	elseif iFrameHandle == "Base" then
		if current <= 1 then
			Character:SetAttribute("iFrames", 0)
		end
	end
end

function module:GetLevel(Character)
	return Character:GetAttribute("iFrames") or 0
end

return module
