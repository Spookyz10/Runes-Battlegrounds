local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("KillSound"):WaitForChild("Main")
local SoundBox = GUI.BoxHolder.SoundBox
local Submit = GUI.Submit
local Feedback = GUI.Feedback

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

local function setFeedback(Success: boolean, Message: string)
	Feedback.Text = Message
	Feedback.TextColor3 = Success and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
end

local function onSubmit()
	local id = extractId(SoundBox.Text)
	if not id then
		setFeedback(false, "INVALID SOUND ID")
		return
	end

	Submit.Active = false

	local Result = RemoteManager.InvokeServer("KillSound", "SetSoundId", { SoundId = id })

	Submit.Active = true

	if typeof(Result) ~= "table" then
		setFeedback(false, "SERVER DIDN'T RESPOND, TRY AGAIN")
		return
	end

	setFeedback(Result.Success == true, Result.Message or (Result.Success and "OK" or "SOMETHING WENT WRONG"))

	if Result.Success then
		refreshBox()
	end
end

function KillSound.Init()
	refreshBox()

	Submit.Activated:Connect(onSubmit)

	Data.KillSoundId.Changed(function()
		refreshBox()
	end)
end

return KillSound
