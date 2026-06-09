--// Services \\--

local SvSt = game:GetService('ServerStorage')



--// Movesets \\--

local MovesetsFolder = SvSt.Movesets



--// Module \\--

local module = {}



--// Functions \\--

function module:HasiFrame(Character: Model, iFrameName)
	if not Character:GetAttribute("iFrames") then
		Character:SetAttribute("iFrames", 0)
	end

	local Tool = MovesetsFolder:FindFirstChild(iFrameName, true)
	if iFrameName == "Awakenings" or iFrameName == "M1" or iFrameName == "Throwables" or (Tool and Tool.Parent.Name ~= "Awakening") then
		return Character:GetAttribute("iFrames") >= 1
	elseif Tool and Tool.Parent.Name == "Awakening" then
		return Character:GetAttribute("iFrames") >= 2
	end
end

function module:AddBaseiFrames(Character: Model)
	if Character:GetAttribute("iFrames") and Character:GetAttribute("iFrames") > 1 then return "All" end
	Character:SetAttribute("iFrames", 1)

	return "Base"
end

function module:AddAlliFrames(Character: Model)
	Character:SetAttribute("iFrames", 2)

	return "All"
end

function module:RemoveAlliFrames(Character: Model)
	Character:SetAttribute("iFrames", 0)
end



return module