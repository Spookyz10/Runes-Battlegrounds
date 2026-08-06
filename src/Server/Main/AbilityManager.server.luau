local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Abilities = require(ServerStorage.Modules.Abilities)
local RemoteManager = require(RS.Shared.Modules.RemoteManager)

local Remotes = RS.Remotes

local ReplicateAbilities = Remotes.AbilitiesHandler

shared.moveget = ReplicateAbilities.Get

local function addToolCDS(Player, Tool)
	local toolCooldowns = Tool:GetAttribute("Cooldowns")

	if not toolCooldowns then
		Tool:SetAttribute("Cooldowns", 1)
	else
		Tool:SetAttribute("Cooldowns", toolCooldowns + 1)
	end

	Tool:SetAttribute("onCDS", true)
	if Tool:GetAttribute("CDS") > -1 then
		task.delay(Tool:GetAttribute("CDS"), function()
			Tool:SetAttribute("Cooldowns", Tool:GetAttribute("Cooldowns") - 1)

			if Tool:GetAttribute("Cooldowns") <= 0 then
				Tool:SetAttribute("Cooldowns", 0)

				Tool:SetAttribute("onCDS", false)
			end
		end)
	end
end

shared.moveget.OnServerInvoke = function(Player, ToolName)
	local Character = Player.Character
	if not Character then
		return false
	end

	local Tool = Player.Moveset:FindFirstChild(ToolName)
	if not Tool then
		return
	end

	local Stunned = Character:HasTag("Stunned")
		or Character:FindFirstChild("Stunned")
		or Character:GetAttribute("Stunned") == true
	if Stunned or Character:HasTag("Blocking") or Tool:GetAttribute("onCDS") then
		return
	end

	addToolCDS(Player, Tool)

	RemoteManager.FireAllClients("Replicate", "ActionHightlight", { char = Character, func = "Hit" })

	if Abilities[ToolName] and Abilities[ToolName]["Start"] then
		coroutine.wrap(function()
			Abilities[ToolName].Start(Player, Tool)
		end)()
	end

	return Tool
end
