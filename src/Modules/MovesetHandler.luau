--// Services \\--
local SvSt = game:GetService("ServerStorage")

--// Movesets \\--

local Movesets = SvSt.Movesets

--// Module \\--

local module = {}
module.__index = module

--// Local Functions \\--

local function AddBaseMoveset(Player, Moveset)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	local MovesetFolder: Folder = Movesets:FindFirstChild(Moveset) or Movesets["Lunar"]

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

function module:AddBaseMoveset(Player, Moveset, RandomMoves)
	Moveset = Moveset or Player:GetAttribute("Moveset")

	for _, v in Player.Moveset:GetChildren() do
		v:Destroy()
	end

	AddBaseMoveset(Player, Moveset)
end

function module:AddAwakeningMoveset(Player, MovesetName)
	MovesetName = MovesetName or Player:GetAttribute("Moveset")

	local MovesetFolder = Movesets[MovesetName]:FindFirstChild("Awakening")
	if not MovesetFolder then
		return
	end

	for _, Tool in pairs(Player.Moveset:GetChildren()) do
		if Tool:IsA("Tool") then
			Tool:Destroy()
		end
	end

	local StartIndex = #Player.Moveset:GetChildren()

	for _, v in pairs(MovesetFolder:GetChildren()) do
		if v:IsA("Tool") then
			local vClone = v:Clone()
			vClone:SetAttribute("Awakening", true)
			vClone:SetAttribute("Index", StartIndex + vClone:GetAttribute("Index"))
			vClone:SetAttribute("originalCDS", v:GetAttribute("CDS"))
			vClone.Parent = Player.Moveset
		end
	end
end

return module
