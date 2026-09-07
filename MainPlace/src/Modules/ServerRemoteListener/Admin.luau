local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Access = require(ReplicatedStorage.Shared.AdminAccess)
local Data = require(ReplicatedStorage.Shared.Data).server
local Cosmetics = require(ReplicatedStorage.Shared.Info.Cosmetics)
local Passes = require(ReplicatedStorage.Shared.Info.Store)
local VIP = require(ReplicatedStorage.Shared.VIPPass)
local Notify = require(script.Parent.Parent.NotificationService)
local Disaster = require(script.Parent.Parent.DisasterService)

local Admin = {}
local busy = {}
local last = {}

local function result(success, message)
	return { Success = success, Message = message }
end

local function validInteger(value, min, max)
	return typeof(value) == "number" and value == value and value % 1 == 0 and value >= min and value <= max
end

local function knownPass(id)
	for _, pass in Passes do
		if pass.Id == id then
			return true
		end
	end

	return false
end

local function grant(data, field, id)
	if not table.find(data[field](), id) then
		data[field].Insert(id)
	end
end

local function apply(player, message)
	if
		typeof(message) ~= "table"
		or not Access[message.Admin]
		or typeof(message.Id) ~= "string"
		or typeof(message.Expires) ~= "number"
	then
		return
	end

	if os.time() > message.Expires then
		return
	end

	local data = Data[player]

	if not data then
		return false
	end

	if data.AdminProcessed()[message.Id] then
		return
	end

	if message.Action == "Gold" then
		if not validInteger(message.Value, 1, 100000000) then
			return
		end

		data.Gold(function(value)
			return value + message.Value
		end)
	elseif message.Action == "Gamepass" then
		if not knownPass(message.Value) then
			return
		end

		grant(data, "OwnedPasses", message.Value)

		if message.Value == VIP.GamepassId then
			grant(data, "OwnedAuras", "VIP")
			grant(data, "OwnedRuneCosmetics", "Crown")
		end
	elseif message.Action == "Cosmetic" or message.Action == "Aura" then
		local category = if message.Action == "Aura" then "Auras" else "RuneCosmetics"

		if not Cosmetics[category][message.Value] then
			return
		end

		grant(data, if category == "Auras" then "OwnedAuras" else "OwnedRuneCosmetics", message.Value)
	elseif message.Action == "Skin" then
		if typeof(message.Value) ~= "string" or not message.Value:match("^[%w_%-]+$") or #message.Value > 80 then
			return
		end

		grant(data, "OwnedRuneSkins", message.Value)
	elseif message.Action ~= "Kick" then
		return
	end

	data.AdminProcessed(function(previous)
		local copy = {}

		for id, expiry in previous do
			if expiry >= os.time() then
				copy[id] = expiry
			end
		end

		copy[message.Id] = message.Expires

		return copy
	end)

	if message.Action == "Kick" then
		task.defer(function()
			player:Kick(message.Reason or "Removed by an administrator.")
		end)
	else
		Notify.Send(player, true, "An administrator granted you a reward.")
	end
end

Data.Service:addGlobalCallback("AdminAction_v1", apply)

local function execute(player, params)
	local action = params.Action

	if action == "Disaster" or action == "StopDisaster" or action == "StopAllDisasters" then
		if params.Scope ~= "Local" and params.Scope ~= "Global" then
			return result(false, "Invalid scope.")
		end

		local ok, message = Disaster.Command(
			if action == "Disaster" then "Start" else "Stop",
			params.Disaster or "Volcano",
			params.Scope == "Global"
		)

		return result(ok, message)
	end

	local target = params.Target

	if typeof(target) ~= "string" or #target > 80 then
		return result(false, "Enter a UserId or exact username.")
	end

	local id = tonumber(target)

	if not id then
		id = Players:GetUserIdFromNameAsync(target)
	end

	if not validInteger(id, 1, 2 ^ 53 - 1) then
		return result(false, "Invalid target.")
	end

	local reason = params.Reason

	if typeof(reason) ~= "string" or #reason > 300 then
		return result(false, "Reason must be at most 300 characters.")
	end

	if action == "Ban" then
		if not Players.BanningEnabled then
			return result(false, "Enable Players.BanningEnabled in Studio before using bans.")
		end

		local days = tonumber(params.Value)

		if not days or (days ~= -1 and not validInteger(days, 1, 3650)) then
			return result(false, "Ban days: 1-3650, or -1 for permanent.")
		end

		if #reason == 0 then
			return result(false, "A ban reason is required.")
		end

		Players:BanAsync({
			UserIds = { id },
			ApplyToUniverse = true,
			Duration = if days == -1 then -1 else days * 86400,
			DisplayReason = reason,
			PrivateReason = "Admin " .. player.UserId .. ": " .. reason,
			ExcludeAltAccounts = true,
		})

		return result(true, "Ban applied across the experience.")
	elseif action == "Unban" then
		Players:UnbanAsync({ UserIds = { id }, ApplyToUniverse = true })

		return result(true, "Ban removed.")
	end

	local value = params.Value

	if action == "Gold" then
		value = tonumber(value)

		if not validInteger(value, 1, 100000000) then
			return result(false, "Gold amount must be 1-100000000.")
		end
	elseif action == "Gamepass" then
		value = tonumber(value)

		if not knownPass(value) then
			return result(false, "Use a configured gamepass ID.")
		end
	elseif action == "Aura" or action == "Cosmetic" then
		local category = if action == "Aura" then "Auras" else "RuneCosmetics"

		if typeof(value) ~= "string" or not Cosmetics[category][value] then
			return result(false, "Unknown cosmetic ID.")
		end
	elseif action == "Skin" then
		if typeof(value) ~= "string" or #value > 80 or not value:match("^[%w_%-]+$") then
			return result(false, "Use a skin ID with letters, numbers, underscores or hyphens.")
		end
	elseif action ~= "Kick" then
		return result(false, "Unknown action.")
	end

	local message = {
		Id = HttpService:GenerateGUID(false),
		Admin = player.UserId,
		Action = action,
		Value = value,
		Reason = if #reason > 0 then reason else "Removed by an administrator.",
		Expires = os.time() + (if action == "Kick" then 60 else 86400),
	}

	local localPlayer = Players:GetPlayerByUserId(id)

	if localPlayer and Data.Service:getProfile(localPlayer) then
		apply(localPlayer, message)

		return result(true, "Command applied to " .. localPlayer.Name .. ".")
	end

	local sent = Data.Service:sendGlobalMessage("AdminAction_v1", id, message)

	return result(
		sent == true,
		if sent
			then "Command queued for the target server. Delivery is asynchronous."
			else "Could not send the command."
	)
end

function Admin:Invoke(player, params)
	if not Access[player.UserId] then
		return result(false, "Not authorized.")
	end

	if typeof(params) ~= "table" then
		return result(false, "Invalid request.")
	end

	if busy[player] or (last[player] and os.clock() - last[player] < 1) then
		return result(false, "Please wait before sending another command.")
	end

	busy[player] = true
	last[player] = os.clock()
	local ok, response = pcall(execute, player, params)
	busy[player] = nil

	if not ok then
		warn("[Admin] " .. tostring(response))

		return result(false, "Command failed. Check the server output and service permissions.")
	end

	return response
end

Players.PlayerRemoving:Connect(function(player)
	busy[player] = nil
	last[player] = nil
end)

return Admin
