local module = {}

local Active = {}

function module:StartCounter(Character, Tier, Duration)
	if not Character or not Character.Parent then
		return nil
	end

	local Token = {}
	Active[Character] = { Tier = Tier, Token = Token }

	Character:AddTag("Countering")
	Character:SetAttribute("CounterTier", Tier)

	if Duration then
		task.delay(Duration, function()
			if Active[Character] and Active[Character].Token == Token then
				module:StopCounter(Character)
			end
		end)
	end

	return Token
end

function module:StopCounter(Character, Token)
	if not Character then
		return
	end

	if Token and Active[Character] and Active[Character].Token ~= Token then
		return
	end

	Active[Character] = nil

	if Character.Parent then
		Character:RemoveTag("Countering")
		Character:SetAttribute("CounterTier", nil)
	end
end

function module:IsCountering(Character)
	return Active[Character] ~= nil
end

function module:GetTier(Character)
	local Data = Active[Character]
	return Data and Data.Tier
end

function module:TryCounter(Character, AttackTier)
	if not AttackTier then
		return false
	end

	local Data = Active[Character]
	if not Data then
		return false
	end

	return Data.Tier >= AttackTier
end

return module
