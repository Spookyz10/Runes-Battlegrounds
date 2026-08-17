local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModulesFolder = script.Parent

local StunHandler = require(ModulesFolder.StunHandler)
local iFramesService = require(ModulesFolder.iFramesService)
local PerfectKnockback = require(ModulesFolder.PerfectKnockback)

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local CombatEvents = require(ModulesFolder.CombatEvents)

local THRESHOLD = 30
local MAX_CHARGES = 1
local ESCAPE_IFRAME_TIME = 1

local RagdollHandler

local function getRagdollHandler()
	if not RagdollHandler then
		RagdollHandler = require(ModulesFolder.RagdollHandler)
	end
	return RagdollHandler
end

local function sendUpdate(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end

	local Progress = Character:GetAttribute("EvasivaProgress") or 0
	local Charges = Character:GetAttribute("EvasivaCharges") or 0

	RemoteManager.FireClient(Player, "Evasive", Progress, THRESHOLD, Charges)
end

function module:AddProgress(Character, Amount)
	if not Character or not Character.Parent or not Amount or Amount <= 0 then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 then
		return
	end

	local Charges = Character:GetAttribute("EvasivaCharges") or 0
	if Charges >= MAX_CHARGES then
		return
	end

	local Progress = (Character:GetAttribute("EvasivaProgress") or 0) + Amount

	while Progress >= THRESHOLD and Charges < MAX_CHARGES do
		Progress -= THRESHOLD
		Charges += 1
	end

	if Charges >= MAX_CHARGES then
		Progress = 0
	end

	Character:SetAttribute("EvasivaProgress", Progress)
	Character:SetAttribute("EvasivaCharges", Charges)

	sendUpdate(Character)
end

function module:GetCharges(Character)
	return Character:GetAttribute("EvasivaCharges") or 0
end

function module:IsTrapped(Character)
	if Character:HasTag("Ragdolled") then
		return true
	end

	if StunHandler:IsStunned(Character) then
		return true
	end

	if PerfectKnockback.Active[Character] then
		return true
	end

	return false
end

function module:CanEscape(Character)
	if not Character then
		return false
	end

	if module:GetCharges(Character) <= 0 then
		return false
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end

	if Character:HasTag("Ragdolled") and not Character:HasTag("CantRagdollCancel") then
		return true
	end

	if StunHandler:CanEscape(Character) then
		return true
	end

	if PerfectKnockback:CanEscape(Character) then
		return true
	end

	return false
end

function module:Escape(Character)
	if not module:CanEscape(Character) then
		return false
	end

	local Charges = module:GetCharges(Character)
	local Escaped = false

	if Character:HasTag("Ragdolled") and not Character:HasTag("CantRagdollCancel") then
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			getRagdollHandler().cancelRagdoll(Humanoid, nil, false, nil, true, true)
			Escaped = true
		end
	end

	if StunHandler:CanEscape(Character) then
		StunHandler:EscapeStun(Character)
		Escaped = true
	end

	if PerfectKnockback:CanEscape(Character) then
		PerfectKnockback:Escape(Character)
		Escaped = true
	end

	if not Escaped then
		return false
	end

	Character:SetAttribute("EvasivaCharges", Charges - 1)

	iFramesService:AddBaseiFrames(Character)
	task.delay(ESCAPE_IFRAME_TIME, function()
		iFramesService:RemoveiFrames(Character, "Base")
	end)

	sendUpdate(Character)

	RemoteManager.FireAllClients("ReplicateTask", "Evasive", { Char = Character })

	return true
end

function module:HandleGetRequest(Player)
	local Character = Player.Character
	if not Character then
		return 0, THRESHOLD, 0
	end

	local Progress = Character:GetAttribute("EvasivaProgress") or 0
	local Charges = Character:GetAttribute("EvasivaCharges") or 0

	return Progress, THRESHOLD, Charges
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		Character:SetAttribute("EvasivaProgress", 0)
		Character:SetAttribute("EvasivaCharges", 0)
		module:AddProgress(Character, THRESHOLD)
	end)
end)

CombatEvents.DamageDealt:Connect(function(Damager, Damaged, Damage)
	module:AddProgress(Damaged, Damage)
	module:AddProgress(Damager, Damage)
end)

return module
