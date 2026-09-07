local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Remote = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local ApplyLighting = require(script.Parent.DisasterLighting)
local Catalog = {
	Volcano = require(script.Parent.Disasters.Volcano),
	Storm = require(script.Parent.Disasters.Storm),
	Blizzard = require(script.Parent.Disasters.Blizzard),
	MeteorShower = require(script.Parent.Disasters.MeteorShower),
}
local names = { "Volcano", "Storm", "Blizzard", "MeteorShower" }
local random = Random.new()
local nextName = names[random:NextInteger(1, #names)]

local Service = {}
local active
local nextStart = os.time() + 600

local notified = {}
local seen = {}
local lastGlobalCommand = 0
local TOPIC = "NaturalDisasters_v1"

local function notify(message)
	Remote.FireAllClients("Notification", {
		Success = false,
		Message = message,
		Title = "NATURAL DISASTER",
		ReplaceKey = "Disaster",
		Instant = true,
	})
end

local function resetTimer(prefix)
	nextName = names[random:NextInteger(1, #names)]
	nextStart = os.time() + 600
	notified = {}
	workspace:SetAttribute("NextDisasterAt", nextStart)
	notify((prefix or "") .. Catalog[nextName].Name .. " will begin in 10 minutes.")
end

function Service.Stop(replacing)
	local endedName = active and active.Name
	if active then
		active.Cleanup()
		active.Restore()
		active = nil
	end

	workspace:SetAttribute("ActiveDisaster", nil)
	workspace:SetAttribute("DisasterEndsAt", nil)
	if not replacing then
		-- One notification keeps the end announcement from being replaced immediately.
		resetTimer(if endedName then endedName .. " has ended! " else nil)
	end
end

function Service.Start(name, endsAt)
	local disaster = Catalog[name]

	if not disaster then
		return false, "Unknown disaster."
	end

	if endsAt and endsAt <= os.time() then
		return false, "Expired event."
	end

	if active then
		Service.Stop(true)
	end

	local ok, cleanup = pcall(disaster.Start)

	if not ok then
		resetTimer()
		return false, tostring(cleanup)
	end

	local lightingOk, restore = pcall(ApplyLighting, name)

	if not lightingOk then
		cleanup()
		resetTimer()

		return false, tostring(restore)
	end

	local finish = endsAt or os.time() + disaster.Duration
	active = {
		Name = disaster.Name,
		Cleanup = cleanup,
		Restore = restore,
		EndsAt = finish,
		RemainingMinutes = math.ceil((finish - os.time()) / 60),
	}
	workspace:SetAttribute("ActiveDisaster", name)
	workspace:SetAttribute("DisasterEndsAt", active.EndsAt)
	workspace:SetAttribute("NextDisasterAt", nil)
	notify(
		disaster.Name .. " has begun! Ends in " .. active.RemainingMinutes .. " minutes. Avoid the marked impact zones."
	)

	return true, "Disaster started on this server."
end

local function receive(data)
	if typeof(data) ~= "table" or typeof(data.Id) ~= "string" or typeof(data.Sent) ~= "number" then
		return
	end

	if seen[data.Id] or os.time() - data.Sent > 60 or data.Sent <= lastGlobalCommand then
		return
	end

	lastGlobalCommand = data.Sent
	seen[data.Id] = os.time()

	if data.Action == "Start" then
		local ok, reason = Service.Start(data.Name, data.EndsAt)

		if not ok then
			warn("[Disaster] " .. reason)
		end
	elseif data.Action == "Stop" then
		Service.Stop()
	end
end

function Service.Command(action, name, global)
	if action == "Start" and (typeof(name) ~= "string" or not Catalog[name]) then
		return false, "Unknown disaster."
	end
	if not global then
		if action == "Stop" then
			Service.Stop()

			return true, "All events stopped on this server. Random events resume in 10 minutes."
		end

		return Service.Start(name)
	end

	local data = {
		Id = HttpService:GenerateGUID(false),
		Action = action,
		Name = name,
		Sent = workspace:GetServerTimeNow(),
		EndsAt = os.time() + 300,
	}

	local ok, err = pcall(function()
		MessagingService:PublishAsync(TOPIC, data)
	end)

	if not ok then
		return false, "Global delivery failed: " .. tostring(err)
	end

	receive(data)

	return true, "Command broadcast to active servers."
end

task.spawn(function()
	while true do
		local ok, result = pcall(function()
			return MessagingService:SubscribeAsync(TOPIC, function(message)
				receive(message.Data)
			end)
		end)

		if ok then
			break
		end

		warn("[Disaster] Global subscription failed: " .. tostring(result))
		task.wait(30)
	end
end)

local function welcome(player)
	task.delay(10, function()
		if player.Parent ~= Players then
			return
		end

		local message = if active
			then active.Name
				.. " is active! Ends in "
				.. math.max(1, math.ceil((active.EndsAt - os.time()) / 60))
				.. " minutes."
			else Catalog[nextName].Name
				.. " in "
				.. tostring(math.max(1, math.ceil((nextStart - os.time()) / 60)))
				.. " minutes."
		Remote.FireClient(
			player,
			"Notification",
			{ Success = false, Title = "NATURAL DISASTER", Message = message, Instant = true }
		)
	end)
end

Players.PlayerAdded:Connect(welcome)

for _, player in Players:GetPlayers() do
	welcome(player)
end

task.spawn(function()
	resetTimer()

	while true do
		local now = os.time()

		if active then
			if now >= active.EndsAt then
				Service.Stop()
			else
				local minutes = math.ceil((active.EndsAt - now) / 60)
				if minutes < active.RemainingMinutes then
					active.RemainingMinutes = minutes
					notify(active.Name .. " ends in " .. minutes .. (if minutes == 1 then " minute!" else " minutes."))
				end
			end
		else
			local remaining = nextStart - now

			if remaining <= 0 then
				local ok, reason = Service.Start(nextName)

				if not ok then
					warn("[Disaster] " .. reason)
				end
			elseif remaining <= 10 and not notified[remaining] then
				notified[remaining] = true
				notify(Catalog[nextName].Name .. " in " .. tostring(remaining) .. " seconds!")
			elseif remaining > 10 and remaining <= 60 and not notified.One then
				notified.One = true
				notify(Catalog[nextName].Name .. " will begin in 1 minute.")
			elseif remaining > 60 and remaining <= 300 and not notified.Five then
				notified.Five = true
				notify(Catalog[nextName].Name .. " will begin in 5 minutes.")
			end
		end

		for id, timestamp in seen do
			if now - timestamp > 600 then
				seen[id] = nil
			end
		end

		task.wait(0.2)
	end
end)

return Service
