local WebhookURL = "https://discord.com/api/webhooks/1418564936157630598/mCrzdtqbmYBp5uLVb9uYoiuT73eezGAw1yxwi6QMy3-gHdgD3kma-MxX_jduPyZIIubz"

local MarketplaceService = game:GetService('MarketplaceService')
local Http = game:GetService('HttpService')


return function(Player: Player, msg: string)
	local username = Player.Name
	local userdisplay = Player.DisplayName
	local userid = Player.UserId

	local placename = "Unknown Place"
	pcall(function()
		local info = MarketplaceService:GetProductInfo(game.PlaceId)
		placename = info.Name or "Unknown Place"
	end)

	local parts = msg:split(" ")
	local commandName = parts[1]
	local targetUserId = tonumber(parts[2])

	local duration = parts[3] or ""
	local reason = ""
	if #parts > 3 then
		reason = table.concat(parts, " ", 4)
	end

	local timeStr = os.date("%H:%M:%S")
	local dateStr = os.date("%Y-%m-%d")

	local targetName, targetDisplay
	if targetUserId then
		pcall(function()
			targetName = game.Players:GetNameFromUserIdAsync(targetUserId)
			local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)
			if targetPlayer then
				targetDisplay = targetPlayer.DisplayName
			end
		end)
	end

	local punishCommands = {
		["/ban"] = true,
		["/gban"] = true,
		["/kick"] = true,
		["/unban"] = true,
		["/gunban"] = true
	}

	local function formatExecutor(name, display, id)
		return string.format("```diff\n+ %s\n```\nDisplay: `%s`\nID:\n```json\n%s\n```", name, display, tostring(id))
	end

	local function formatTarget(name, display, id)
		return string.format("```diff\n- %s\n```\nDisplay: `%s`\nID:\n```json\n%s\n```", name, display, tostring(id))
	end

	local content
	if punishCommands[commandName] then
		content = string.format(
			"**[%s] Command Log**\n\nExecutor:\n%s\nTarget:\n%s\nCommand: `%s`\nDuration: `%s`\nReason: `%s`\nTime: `%s` on %s",
			placename,
			formatExecutor(username, userdisplay, userid),
			formatTarget(targetName or "Unknown", targetDisplay or "Unknown", targetUserId or "N/A"),
			commandName,
			(duration ~= "" and duration or "N/A"),
			(reason ~= "" and reason or "N/A"),
			timeStr, dateStr
		)
	else
		content = string.format(
			"**[%s] Command Log**\n\nExecutor:\n%s\nCommand: `%s`\nTime: `%s` on %s",
			placename,
			formatExecutor(username, userdisplay, userid),
			commandName,
			timeStr, dateStr
		)
	end

	local body = Http:JSONEncode({["content"] = content})

	pcall(function()
		Http:PostAsync(WebhookURL, body, Enum.HttpContentType.ApplicationJson, false)
	end)
end