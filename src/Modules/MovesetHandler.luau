--// Services \\--

local RS = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")

--// Movesets \\--

local Movesets = SvSt.Movesets

--// Modules \\--

local SvModules = script.Parent

local WeaponsHandler = require(SvModules.WeaponsHandler)

--// Remotes \\--

local Remotes = RS.Remotes

--// Module \\--

local module = {}
module.__index = module

--// Local Functions \\--

local function Shuffle(TableToShuffle: table): table
	local ShuffledTable = {}

	for Index = 1, #TableToShuffle do
		local RandomIndex = math.random(#TableToShuffle)
		table.insert(ShuffledTable, TableToShuffle[RandomIndex])
		table.remove(TableToShuffle, RandomIndex)
	end

	return ShuffledTable
end

local function GetTableLength(Table)
	local Length = 0

	for _, _ in Table do
		Length += 1
	end

	return Length
end

local function AddBaseMoveset(Player, Moveset)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	local MovesetFolder: Folder = Movesets:FindFirstChild(Moveset) or Movesets["The Strongest Hero"]

	if MovesetFolder:GetAttribute("Has_Weapon") == true then
		WeaponsHandler:AddWeapon(Player.Character, Moveset)
	end

	local StartIndex = #Player.Moveset:GetChildren()

	for _, v in MovesetFolder:GetChildren() do
		if not v:IsA("Tool") then
			continue
		end

		local vClone = v:Clone()
		vClone:SetAttribute("Base", true)
		vClone:SetAttribute("Index", StartIndex + vClone:GetAttribute("Index"))
		vClone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
		vClone.Parent = Player.Moveset
	end
end

--// Module Functions \\--

function module:AddDualMoveset(Player: Player)
	local MovesetFolder: Folder = Movesets:FindFirstChild(Player:GetAttribute("Moveset"))
		or Movesets["The Strongest Hero"]

	for _, v in Player.Moveset:GetChildren() do
		if not v:IsA("Tool") then
			continue
		end

		v:Destroy()
	end

	for _, v in MovesetFolder:GetChildren() do
		if not v:IsA("Tool") then
			continue
		end

		local vClone = v:Clone()
		vClone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
		vClone.Parent = Player.Moveset
	end

	if MovesetFolder:FindFirstChild("Awakening") then
		for _, v in MovesetFolder.Awakening:GetChildren() do
			if not v:IsA("Tool") then
				continue
			end

			local vClone = v:Clone()
			vClone:SetAttribute("Awakening", true)
			vClone:SetAttribute("Index", vClone:GetAttribute("Index") + 4)
			vClone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
			vClone.Parent = Player.Moveset
		end
	end
end

function module:AddBaseMoveset(Player: Player, Moveset, RandomMoves)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	for _, v in Player.Moveset:GetChildren() do
		v:Destroy()
	end

	AddBaseMoveset(Player, Moveset)
end

function module:AddAwakeningMoveset(Player: Player, MovesetName)
	MovesetName = MovesetName or Player:GetAttribute("Moveset")

	local MovesetFolder = Movesets[MovesetName]:FindFirstChild("Awakening")
	if not MovesetFolder then
		return
	end

	for _, Tool: Tool in pairs(Player.Moveset:GetChildren()) do
		if Tool:IsA("Tool") then
			Tool:Destroy()
		end
	end

	local StartIndex = #Player.Moveset:GetChildren()

	for _, v: Tool in pairs(MovesetFolder:GetChildren()) do
		if v:IsA("Tool") then
			local vClone = v:Clone()
			vClone:SetAttribute("Awakening", true)
			vClone:SetAttribute("Index", StartIndex + vClone:GetAttribute("Index"))
			vClone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
			vClone.Parent = Player.Moveset
		end
	end
end

function module:AddCustomMoveset(Player, Moves: { string })
	local StartIndex = #Player.Moveset:GetChildren()

	for ToolIndex, ToolName in Moves do
		local Tool = Movesets:FindFirstChild(ToolName, true)

		if Tool then
			local ToolClone = Tool:Clone()
			ToolClone:SetAttribute("Index", StartIndex + ToolIndex)
			ToolClone:SetAttribute("originalCDS", Tool:GetAttribute("CDS"))
			ToolClone.Parent = Player.Moveset
		end
	end
end

return module
