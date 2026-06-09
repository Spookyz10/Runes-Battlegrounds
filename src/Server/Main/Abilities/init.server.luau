--Services
local SvSt = game:GetService('ServerStorage')
local RS = game:GetService('ReplicatedStorage')
local TS = game:GetService('TweenService')
local Debris = game:GetService('Debris')
local Players = game:GetService('Players')



--Bindables
shared.AirDetect = SvSt.Bindables.AirDetector



--Assets
local Assets = SvSt.Assets

shared.Assets = Assets


local SoundsFolder = Assets.Sounds
local AnimsFolder = Assets.Animations

shared.SoundsFolder = SoundsFolder
shared.AnimsFolder = AnimsFolder

shared.MoveSounds = SoundsFolder.Moves
shared.MoveAnims = AnimsFolder.Moves


local Remotes = RS.Remotes



--Comunicator
local ComunicatorFolder = Remotes.Comunicator

shared.PlrSet = ComunicatorFolder.Set
shared.PlrGet = ComunicatorFolder.Get



--ReplicateAbilities
local ReplicateAbilities = Remotes.AbilitiesHandler

shared.moveget = ReplicateAbilities.Get
shared.movefire = ReplicateAbilities.Set



--ReplicateEffects
local ReplicateEffects = Remotes.Replicate

shared.repget = ReplicateEffects.Get
shared.repfire = ReplicateEffects.Set



--ReplicatedModules
local ReplicatedModules = RS.Shared.Modules

shared.AnimationEvents = require(ReplicatedModules.AnimationEvents)
shared.Utility = require(ReplicatedModules.Utility)
shared.WeldSystem = require(ReplicatedModules.WeldSystem)


--Variables
local specialUseMoves = {
	["Vanishing Kick"] = "VanishingKickStomp",
	["Body Splitter"] = "BodySplitterSlash",
	["Rewind Clock"] = "RewindClockCombine"
}

local doubleUseMoves = {
	["Five Seasons"] = "FiveSeasonsTwice",
	["Doom Dive"] = "DoomDiveTwice"
}

shared.rad = math.rad
shared.DefaultJoint = game.StarterPlayer.StarterCharacter.HumanoidRootPart.RootJoint

shared.Abilities = {}



--Functions
local function addToolCDS(Player: Player, Tool: Tool)
	if Player.Commands.NoCooldown.Value == false then
		local toolCooldowns = Tool:GetAttribute('Cooldowns')
		
		if not toolCooldowns then
			Tool:SetAttribute('Cooldowns', 1)
		else
			Tool:SetAttribute('Cooldowns', toolCooldowns + 1)
		end
		if Tool.Name == "Thorny Release" and Player.Configuration.Mod.Value == 3 then
			Tool:SetAttribute("CDS", 28.5)
		elseif Tool.Name == "Thorny Release" and Player.Configuration.Mod.Value ~= 3 then
			Tool:SetAttribute("CDS", 1)
		end

		Tool:SetAttribute('onCDS', true)
		if Tool:GetAttribute("CDS") > -1 then
			task.delay(Tool:GetAttribute('CDS'), function()
				Tool:SetAttribute('Cooldowns', Tool:GetAttribute('Cooldowns') - 1)

				if Tool:GetAttribute('Cooldowns') <= 0 then
					Tool:SetAttribute('Cooldowns', 0)

					Tool:SetAttribute('onCDS', false)
				end
			end)
		end
	end
end



--Runtime
for _,v in script:GetDescendants() do
	if v:IsA('ModuleScript') then
		shared.Abilities[v.Name] = require(v)
	end
end

shared.moveget.OnServerInvoke = function(Player: Player, ToolName)
	local Character = Player.Character
	if not Character then return false end
	
	local Tool: Tool = Player.Moveset:FindFirstChild(ToolName)
	if not Tool then return end
	
	if ToolName == "Vanishing Kick" then
		if Character:GetAttribute("VanishingKickStomp") == true and not Character:HasTag("Stunned") and not Character:HasTag("Blocking") then
			Character:SetAttribute("VanishingKickStomp", nil)
			
			return Tool, false
		end
		
	elseif ToolName == "Body Splitter" then
		if Character:GetAttribute("BodySplitterSlash") == true and not Character:HasTag("Stunned") and not Character:HasTag("Blocking") then
			Character:SetAttribute("BodySplitterSlash", nil)

			return Tool, false
		end
		
	else
		local doubleUseName, specialUseName = doubleUseMoves[ToolName], specialUseMoves[ToolName]
		if doubleUseName ~= nil then
			if Character:GetAttribute(doubleUseName) == true then
				Character:SetAttribute(doubleUseName, nil)
				
				return Tool, false
			end
			
		elseif specialUseName ~= nil then
			if Character:GetAttribute(specialUseName) == true and not Tool:GetAttribute('onCDS') then
				Character:SetAttribute(specialUseName, nil)
				
				addToolCDS(Player, Tool)
				
				return Tool, false
			end
			
		end
	end
	
	local Stunned = Character:HasTag('Stunned') or Character:FindFirstChild("Stunned") or Character:GetAttribute("Stunned") == true
	if Stunned or Character:HasTag("Blocking") or Tool:GetAttribute('onCDS') then return end
	
	addToolCDS(Player, Tool)
	
	
	if shared.Abilities[ToolName] and shared.Abilities[ToolName]["Start"] then
		coroutine.wrap(function()
			shared.Abilities[ToolName].Start(Player, Tool)
		end)()
	end
	
	
	return Tool
end