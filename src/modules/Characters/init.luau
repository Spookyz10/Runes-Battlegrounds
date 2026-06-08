local CharacterService = {}

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local CombatState = require(ServerStorage.Modules.Combat.CombatState)
local Skills = require(ServerStorage.Modules.Combat.Skills)

local configs = {}

for _, character in script:GetDescendants() do
	if character:IsA("ModuleScript") then
		local name = character.Name
		configs[name] = require(character)
	end
end

function CharacterService.getConfig(name)
	return configs[name]
end

function CharacterService.getSkillModule(name)
	return Skills[name]
end

local function clearTools(player)
	for _, tool in player.Backpack:GetChildren() do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end
	if player.Character then
		local tool = player.Character:FindFirstChildOfClass("Tool")
		if tool then
			tool:Destroy()
		end
	end
end

local function giveTools(player, characterName)
	local config = configs[characterName]
	if not config then
		print("Config not found for character:", characterName)
		return
	end
	for _, toolName in config.skills do
		local template = ServerStorage.Tools:FindFirstChild(toolName)

		if template then
			template:Clone().Parent = player.Backpack
		end
	end
end

function CharacterService.assign(player, characterName)
	if not configs[characterName] then
		print("Config not found for character:", characterName)
		return
	end
	CombatState.reset(player)
	CombatState.set(player, "characterName", characterName)
	clearTools(player)
	giveTools(player, characterName)
end

Players.PlayerAdded:Connect(function(player)
	CombatState.reset(player)

	local character = player.Character
	if character then
		giveTools(player, CombatState.get(player).characterName)
	end
	player.CharacterAdded:Connect(function()
		giveTools(player, CombatState.get(player).characterName)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	CombatState.clear(player)
end)

return CharacterService
