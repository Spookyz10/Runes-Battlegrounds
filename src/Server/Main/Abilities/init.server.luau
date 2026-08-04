local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

shared.AirDetect = SvSt.Bindables.AirDetector

local Assets = SvSt.Assets

shared.Assets = Assets

local SoundsFolder = Assets.Sounds
local AnimsFolder = Assets.Animations

shared.SoundsFolder = SoundsFolder
shared.AnimsFolder = AnimsFolder

shared.MoveSounds = SoundsFolder.Moves
shared.MoveAnims = AnimsFolder.Moves

local Remotes = RS.Remotes

local ComunicatorFolder = Remotes.Comunicator

shared.PlrSet = ComunicatorFolder.Set
shared.PlrGet = ComunicatorFolder.Get

local ReplicateAbilities = Remotes.AbilitiesHandler

shared.moveget = ReplicateAbilities.Get
shared.movefire = ReplicateAbilities.Set

local ReplicateEffects = Remotes.Replicate

shared.repget = ReplicateEffects.Get
shared.repfire = ReplicateEffects.Set

local ReplicatedModules = RS.Shared.Modules

shared.AnimationEvents = require(ReplicatedModules.AnimationEvents)
shared.Utility = require(ReplicatedModules.Utility)
shared.WeldSystem = require(ReplicatedModules.WeldSystem)

shared.rad = math.rad
shared.DefaultJoint = game.StarterPlayer.StarterCharacter.HumanoidRootPart.RootJoint

shared.Abilities = {}

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

for _, v in script:GetDescendants() do
	if v:IsA("ModuleScript") then
		shared.Abilities[v.Name] = require(v)
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

	shared.repfire:FireAllClients("ActionHightlight", { char = Character, func = "Hit" })

	if shared.Abilities[ToolName] and shared.Abilities[ToolName]["Start"] then
		coroutine.wrap(function()
			shared.Abilities[ToolName].Start(Player, Tool)
		end)()
	end

	return Tool
end
