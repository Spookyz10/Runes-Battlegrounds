local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Remote = {}

function Remote:Activate(Player: Player)
	if not Player.Character or not Player.Character.Parent then
		return
	end

	local Character = Player.Character
	local Humanoid = Character.Humanoid

	local DamagedLog = Character:FindFirstChild("DamagedLog")
	local DamagerLog = Character:FindFirstChild("DamagerLog")

	if Character:HasTag("Stunned") then
		RemoteManager.FireClient(Player, "ReplicateTask", "SendNotification", {
			Title = "NOTIFICATION",
			Text = "YOU CAN'T RESET YOUR CHARACTER RIGHT NOW",
		})
	elseif (DamagedLog and not DamagedLog:HasTag("Dummy")) or (DamagerLog and not DamagerLog:HasTag("Dummy")) then
		local TimeUntilReset = 0
		if DamagedLog then
			TimeUntilReset = DamagedLog.TimeRemaining.Value
		end

		if DamagerLog then
			if DamagerLog.TimeRemaining.Value > TimeUntilReset then
				TimeUntilReset = DamagerLog.TimeRemaining.Value
			end
		end

		RemoteManager.FireClient(Player, "ReplicateTask", "SendNotification", {
			Title = "NOTIFICATION",
			Text = "WAIT " .. tostring(math.round(TimeUntilReset)) .. " SECONDS BEFORE RESETTING",
		})
	else
		Humanoid.Health = 0
	end
end

return Remote
