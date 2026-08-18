local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("KillSound")
local SoundBox = GUI:WaitForChild("SoundBox")
local Submit = GUI:WaitForChild("Submit")

local KillSound = {}

local function extractId(text)
	local digits = text:match("%d+")
	if not digits then
		return nil
	end

	local id = tonumber(digits)
	if not id or id <= 0 then
		return nil
	end

	return id
end

local function refreshBox()
	local currentId = Data.KillSoundId()
	SoundBox.Text = currentId and tostring(currentId) or ""
end

local function onSubmit()
	local id = extractId(SoundBox.Text)
	if not id then
		return
	end

	RemoteManager.FireServer("KillSound", "SetSoundId", { SoundId = id })
end

function KillSound.Init()
	refreshBox()

	Submit.Activated:Connect(onSubmit)

	Data.KillSoundId.Changed(function()
		refreshBox()
	end)
end

return KillSound
