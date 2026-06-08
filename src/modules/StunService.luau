local StunService = {}

local stunTimers = {} -- { [character] = thread }

function StunService.apply(character, duration)
	-- Cancela timer anterior se existir
	if stunTimers[character] then
		task.cancel(stunTimers[character])
	end

	character:SetAttribute("Stunned", true)

	stunTimers[character] = task.delay(duration, function()
		stunTimers[character] = nil
		if character and character.Parent then
			character:SetAttribute("Stunned", false)
		end
	end)
end

function StunService.isStunned(character)
	return character:GetAttribute("Stunned") == true
end

function StunService.clear(character)
	if stunTimers[character] then
		task.cancel(stunTimers[character])
		stunTimers[character] = nil
	end
	if character and character.Parent then
		character:SetAttribute("Stunned", false)
	end
end

-- Limpeza ao remover personagem
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		stunTimers[character] = nil
	end)
end)

return StunService
