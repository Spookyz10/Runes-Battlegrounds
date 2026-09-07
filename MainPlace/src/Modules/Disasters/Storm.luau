local Players = game:GetService("Players")
local Runtime = require(script.Parent.WeatherRuntime)
local Ragdoll = require(script.Parent.Parent.RagdollHandler)
local Knockback = require(script.Parent.Parent.BodymoverService)

return {
	Name = "Thunderstorm",
	Duration = 300,
	Start = function()
		local event = Runtime.new("Storm")
		local captured, cooldown = {}, setmetatable({}, { __mode = "k" })
		local tornadoes = {}
		local function release(character, data, launch)
			captured[character] = nil
			if data.Mover then
				data.Mover:Destroy()
			end
			cooldown[character] = os.clock() + 6
			if launch and data.Root.Parent and data.Hum.Health > 0 then
				local direction = data.Root.Position - data.Center
				direction = Vector3.new(direction.X, 0, direction.Z)
				direction = if direction.Magnitude > 0.01 then direction.Unit else Vector3.xAxis
				Ragdoll.ragdoll(data.Hum, 3, true, nil, { Damage = 10 })
				Knockback:Knockback(
					character,
					{ KnockbackType = "Velocity", Time = 0.35, Velocity = direction * 110 + Vector3.new(0, 65, 0) }
				)
			end
		end
		event:Loop(10, function()
			local players = {}
			for _, player in Players:GetPlayers() do
				local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					table.insert(players, player)
				end
			end
			for index = 1, 10 do
				local player
				if index <= 2 and #players > 0 then
					player = table.remove(players, event.Random:NextInteger(1, #players))
					if #players == 0 and index == 1 then
						table.insert(players, player)
					end
				end
				local target, normal = event:Target(player)
				if target then
					event:Warn(target, 14, 2, Color3.fromRGB(255, 222, 90), normal, function()
						local bolt = event:Part(
							"Lightning",
							target + Vector3.new(0, 100, 0),
							Vector3.new(1.5, 200, 1.5),
							Color3.fromRGB(215, 230, 255)
						)
						bolt.Material = Enum.Material.Neon
						task.delay(0.2, function()
							bolt:Destroy()
						end)
						event:Effect("ThunderExplosion", target, 5)
						event:Hit(target + Vector3.new(0, 5, 0), Vector3.new(14, 20, 14), function(character)
							event:Impact(character, target, 10, "Thunder")
						end)
					end)
				end
			end
		end)
		event:Loop(function()
			return event.Random:NextNumber(8, 15)
		end, function()
			local target, normal = event:Target()
			if target then
				event:Warn(target, 30, 3, Color3.fromRGB(160, 130, 255), normal, function()
					event:Effect("TornadoVFX", target, 18, true)
					table.insert(tornadoes, { Position = target, Ends = os.clock() + 18 })
				end)
			end
		end)
		local elapsed = 0
		event:Heartbeat(function(dt)
			local now = os.clock()
			for character, data in captured do
				if
					not data.Root.Parent
					or data.Hum.Health <= 0
					or now >= data.Ends
					or not data.Mover
					or not data.Mover.Parent
				then
					release(character, data, now >= data.Ends)
				else
					local angle = (now - data.Start) * 7
					data.Mover.Position = data.Center
						+ Vector3.new(math.cos(angle) * 10, 12 + (now - data.Start) * 4, math.sin(angle) * 10)
				end
			end
			elapsed += dt
			if elapsed < 0.1 then
				return
			end
			elapsed = 0
			for index = #tornadoes, 1, -1 do
				local tornado = tornadoes[index]
				if now >= tornado.Ends then
					table.remove(tornadoes, index)
					continue
				end
				event:Hit(
					tornado.Position + Vector3.new(0, 18, 0),
					Vector3.new(30, 40, 30),
					function(character, hum, root)
						if captured[character] or (cooldown[character] or 0) > now or root.Anchored then
							return
						end
						hum:TakeDamage(10)
						-- Start impact detection on release, after the orbit is finished.
						Ragdoll.ragdoll(hum, 6, false, nil, nil, nil, false)
						local mover = Knockback:Knockback(character, {
							KnockbackType = "Position",
							Position = root.Position,
							Time = 3.2,
							P = 18000,
							D = 900,
							MaxForce = Vector3.one * 100000,
						})
						captured[character] = {
							Root = root,
							Hum = hum,
							Mover = mover,
							Center = tornado.Position,
							Start = now,
							Ends = now + 3,
						}
					end
				)
			end
		end)
		return function()
			event:Destroy()
			for character, data in captured do
				release(character, data, false)
			end
		end
	end,
}
