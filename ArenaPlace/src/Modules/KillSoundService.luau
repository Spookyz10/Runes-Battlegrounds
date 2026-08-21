local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local KillSoundPass = require(ReplicatedStorage.Shared.KillSoundPass)

local SOUND_DURATION = 10

local KillSoundService = {}

local function playerOwnsKillSound(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	return table.find(playerData.OwnedPasses(), KillSoundPass.GamepassId)
end

function KillSoundService:PlaySound(Damager, Damaged)
	if not Damager or not Damaged or not Damaged.Parent then
		return
	end

	local DamagerPlayer = Players:GetPlayerFromCharacter(Damager)
	if not DamagerPlayer then
		return
	end

	if not playerOwnsKillSound(DamagerPlayer) then
		return
	end

	local playerData = Data.Service:waitForData(DamagerPlayer)
	local SoundId = playerData and playerData.KillSoundId()
	if not SoundId then
		return
	end

	local HumRP = Damaged:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local Sound = Instance.new("Sound")
	Sound.Name = "KillSound"
	Sound.SoundId = "rbxassetid://" .. tostring(SoundId)
	Sound.Volume = 1
	Sound.Parent = HumRP

	task.wait()
	Sound:Play()

	Debris:AddItem(Sound, SOUND_DURATION)
end

function KillSoundService:SetSoundId(Player: Player, Params)
	if not playerOwnsKillSound(Player) then
		return { Success = false, Message = "YOU DON'T OWN THE KILL SOUND GAMEPASS" }
	end

	if typeof(Params) ~= "table" then
		return { Success = false, Message = "INVALID REQUEST" }
	end

	local SoundId = Params.SoundId
	if typeof(SoundId) ~= "number" or SoundId <= 0 or SoundId % 1 ~= 0 then
		return { Success = false, Message = "INVALID SOUND ID" }
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return { Success = false, Message = "COULD NOT LOAD YOUR DATA, TRY AGAIN" }
	end

	playerData.KillSoundId(SoundId)

	return { Success = true, Message = "KILL SOUND UPDATED" }
end

return KillSoundService
