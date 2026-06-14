local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")
local InfoModule = require(ReplicatedStorage.Shared.Info)

local Movesets = SvSt.Movesets
local module = {}
module.__index = module

local function resolveFolder(Player, Moveset)
	local movesetInfo = InfoModule.Movesets[Moveset]

	-- Se o moveset tem modos, entra na sub-pasta do modo atual
	if movesetInfo and movesetInfo.Modes then
		local playerClass = shared.playerClasses[Player.UserId]
		local currentMode = (playerClass and playerClass.MovesetModes[Moveset]) or movesetInfo.DefaultMode

		local root = Movesets:FindFirstChild(Moveset)
		return root and root:FindFirstChild(currentMode)
	end

	return Movesets:FindFirstChild(Moveset)
end

local function addTools(Player, folder, attributeName)
	if not folder then
		warn("MovesetHandler: pasta não encontrada para", Player.Name)
		return
	end

	local startIndex = #Player.Moveset:GetChildren()

	for _, v in folder:GetChildren() do
		if not v:IsA("Tool") then
			continue
		end

		local clone = v:Clone()
		clone:SetAttribute(attributeName, true)
		clone:SetAttribute("Index", startIndex + clone:GetAttribute("Index"))
		clone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
		clone.Parent = Player.Moveset
	end
end

function module:AddBaseMoveset(Player, Moveset)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	for _, v in Player.Moveset:GetChildren() do
		v:Destroy()
	end

	addTools(Player, resolveFolder(Player, Moveset), "Base")
end

function module:AddAwakeningMoveset(Player, Moveset)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	for _, v in Player.Moveset:GetChildren() do
		if v:IsA("Tool") then
			v:Destroy()
		end
	end

	local movesetInfo = InfoModule.Movesets[Moveset]
	local folder

	if movesetInfo and movesetInfo.Modes then
		-- Awakening também tem sub-pastas: Eclipse/Lunar/Awakening
		local playerClass = shared.playerClasses[Player.UserId]
		local currentMode = (playerClass and playerClass.MovesetModes[Moveset]) or movesetInfo.DefaultMode

		local root = Movesets:FindFirstChild(Moveset)
		local modeFolder = root and root:FindFirstChild(currentMode)
		folder = modeFolder and modeFolder:FindFirstChild("Awakening")
	else
		local root = Movesets:FindFirstChild(Moveset)
		folder = root and root:FindFirstChild("Awakening")
	end

	addTools(Player, folder, "Awakening")
end

return module
