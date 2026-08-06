local module = {}

local getCF = {
	["CFrame"] = function(Value)
		return Value.Position
	end,

	["Vector3"] = function(Value)
		return Value
	end,
}

local soundAttachments = setmetatable({}, { __mode = "k" })

function module:PlaySound(OriginalSound, Part, PlaybackSpeed, _, FadeOutParams, TimePosition)
	local partType = typeof(Part)
	local ParentPart = nil

	local Sound = OriginalSound:Clone()
	task.spawn(function()
		Sound.SoundGroup = game.SoundService.Sounds

		if partType == "CFrame" or partType == "Vector3" then
			local soundAttachment = Instance.new("Attachment")
			soundAttachment.Parent = workspace
			soundAttachment.WorldPosition = getCF[partType](Part)

			ParentPart = soundAttachment
			soundAttachments[Sound] = soundAttachment
		else
			ParentPart = Part
		end

		Sound.Parent = ParentPart
		Sound.PlaybackSpeed = PlaybackSpeed or OriginalSound.PlaybackSpeed or 1
		Sound.TimePosition = TimePosition or OriginalSound.TimePosition or 0
		Sound:Play()

		if Sound.Looped == false then
			task.delay(Sound.TimeLength + 5, function()
				module:StopSound(Sound)
			end)

			if FadeOutParams then
				task.delay(FadeOutParams.DelayTime, function()
					game.TweenService:Create(Sound, FadeOutParams.TweenInfo, { Volume = 0 }):Play()
				end)
			end
		end
	end)

	return Sound
end

function module:StopSound(Sound)
	if not Sound then
		return
	end

	local attachment = soundAttachments[Sound]
	soundAttachments[Sound] = nil

	if Sound.Parent then
		Sound:Stop()
		Sound:Destroy()
	end

	if attachment and attachment.Parent then
		attachment:Destroy()
	end
end

return module
