local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local NotificationService = {}

function NotificationService.Send(player, success, message, itemId)
	RemoteManager.FireClient(player, "Notification", {
		Success = success,
		Message = message,
		ItemId = itemId,
	})
end

return NotificationService
