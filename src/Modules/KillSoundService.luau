local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local KillSoundPass = require(ReplicatedStorage.Shared.KillSoundPass)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local SOUND_DURATION = 10

local KillSoundService = {}

local function playerOwnsKillSound(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	return playerData.OwnedPasses()[KillSoundPass.GamepassId] == true
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

local KillSoundRemote = RemoteManager.GetRemote("KillSound", "Server")
if KillSoundRemote then
	KillSoundRemote.OnServerEvent:Connect(function(Player, Action, Params)
		if Action ~= "SetSoundId" then
			return
		end

		if not playerOwnsKillSound(Player) then
			return
		end

		if typeof(Params) ~= "table" then
			return
		end

		local SoundId = Params.SoundId
		if typeof(SoundId) ~= "number" or SoundId <= 0 or SoundId % 1 ~= 0 then
			return
		end

		local playerData = Data.Service:waitForData(Player)
		if not playerData then
			return
		end

		playerData.KillSoundId(SoundId)
	end)
end

return KillSoundService
