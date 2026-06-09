local Sounds = game.ServerStorage.Assets.Sounds
local module = {}

local getCF = {
	["CFrame"] = function(Value)
		return Value.Position
	end,

	["Vector3"] = function(Value)
		return Value
	end,
}

function module:PlaySound(OriginalSound, Part, PlaybackSpeed, _, FadeOutParams, TimePosition)
	local partType = typeof(Part)
	local ParentPart = nil
	local destroyParentPart = false

	local Sound = OriginalSound:Clone()
	task.spawn(function()
		if
			OriginalSound:IsDescendantOf(Sounds.Emotes)
			or OriginalSound:IsDescendantOf(game.ServerStorage.Modules.Emotes)
		then
			Sound.SoundGroup = game.SoundService["Emote Music"]
		else
			Sound.SoundGroup = game.SoundService.Sounds
		end

		if partType == "CFrame" or partType == "Vector3" then
			local soundAttachment = Instance.new("Attachment")
			soundAttachment.Parent = workspace.Terrain
			soundAttachment.WorldPosition = getCF[partType](Part)

			ParentPart = soundAttachment
			destroyParentPart = true
		else
			ParentPart = Part
		end

		Sound.Parent = ParentPart
		Sound.PlaybackSpeed = PlaybackSpeed or OriginalSound.PlaybackSpeed or 1
		Sound.TimePosition = TimePosition or OriginalSound.TimePosition or 0
		Sound:Play()

		local AttackSMult = workspace.Configuration.AttackSMult.Value
		if
			AttackSMult ~= 1
			and (
				OriginalSound.Name == "TrashDmg"
				or OriginalSound.Name == "TrashGrab"
				or OriginalSound:IsDescendantOf(Sounds.Wallcombos)
				or OriginalSound:IsDescendantOf(Sounds.Moves)
				or OriginalSound:IsDescendantOf(Sounds.Awakenings)
				or OriginalSound:IsDescendantOf(Sounds.Combat.Swings)
				or OriginalSound:IsDescendantOf(Sounds.Combat.Hits)
			)
		then
			Sound.PlaybackSpeed *= AttackSMult
		end

		if Sound.Looped == false then
			task.delay(Sound.TimeLength + 5, function()
				Sound:Destroy()
				if destroyParentPart == true then
					ParentPart:Destroy()
				end
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

return module
