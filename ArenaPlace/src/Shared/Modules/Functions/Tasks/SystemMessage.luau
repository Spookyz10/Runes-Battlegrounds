local TextChatService = game:GetService("TextChatService")

local function getGeneralChannel()
	local TextChannels = TextChatService:FindFirstChild("TextChannels")
	if not TextChannels then
		return nil
	end

	return TextChannels:FindFirstChild("RBXGeneral")
end

return function(Message)
	local GeneralChannel = getGeneralChannel()

	if not GeneralChannel then
		return
	end

	GeneralChannel:DisplaySystemMessage(Message)
end
