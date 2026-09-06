local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Hitbox = require(script.Parent.Parent.HitboxHandler)
local Ragdoll = require(script.Parent.Parent.RagdollHandler)
local Knockback = require(script.Parent.Parent.BodymoverService)
local IFrames = require(script.Parent.Parent.iFramesService)
local Remote = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Volcano = { Name = "Volcanic eruption", Duration = 300 }
local random = Random.new()

function Volcano.Start()
	local source = workspace:FindFirstChild("VolcanoPart")
	local map = workspace:FindFirstChild("Map")
	local arena = map and map:FindFirstChild("Arena")

	if not source or not source:IsA("BasePart") or not arena then
		error("VolcanoPart and Map.Arena are required.")
	end

	local bounds, size

	if arena:IsA("BasePart") then
		bounds, size = arena.CFrame, arena.Size
	elseif arena:IsA("Model") then
		bounds, size = arena:GetBoundingBox()
	else
		local low, high = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, part in arena:GetDescendants() do
			if part:IsA("BasePart") then
				for x = -1, 1, 2 do
					for y = -1, 1, 2 do
						for z = -1, 1, 2 do
							local point = part.CFrame:PointToWorldSpace(part.Size * Vector3.new(x, y, z) / 2)
							low = low:Min(point)
							high = high:Max(point)
						end
					end
				end
			end
		end

		if low.X == math.huge then
			error("Arena has no ground parts.")
		end

		bounds, size = CFrame.new((low + high) / 2), high - low
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { arena }
	local collisionParams = RaycastParams.new()
	collisionParams.FilterType = Enum.RaycastFilterType.Include
	collisionParams.FilterDescendantsInstances = { map, workspace.Terrain }

	local function target(player)
		local preferred

		if player then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local hum = character and character:FindFirstChildOfClass("Humanoid")

			if root and hum and hum.Health > 0 then
				local localPos = bounds:PointToObjectSpace(root.Position)

				if math.abs(localPos.X) <= size.X / 2 and math.abs(localPos.Z) <= size.Z / 2 then
					preferred = root.Position
				end
			end
		end

		for attempt = 1, 12 do
			local point

			if preferred and attempt < 8 then
				point = preferred + Vector3.new(random:NextNumber(-18, 18), 0, random:NextNumber(-18, 18))
			else
				point = bounds:PointToWorldSpace(
					Vector3.new(
						random:NextNumber(-size.X / 2, size.X / 2),
						0,
						random:NextNumber(-size.Z / 2, size.Z / 2)
					)
				)
			end

			local top = math.max(bounds.Position.Y + size.Magnitude, point.Y + 200)
			local hit = workspace:Raycast(
				Vector3.new(point.X, top, point.Z),
				Vector3.new(0, -size.Magnitude - 2000, 0),
				rayParams
			)

			if hit then
				return hit.Position, hit.Normal
			end
		end
	end

	local active = true

	local rocks = {}
	local passive = source:FindFirstChild("Passive")

	if passive then
		for _, emitter in passive:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end

	local function impact(position)
		Hitbox:SimpleOnce(
			CFrame.new(position + Vector3.new(0, 5, 0)),
			Vector3.new(20, 20, 20),
			CFrame.identity,
			{},
			nil,
			nil,
			function(character)
				local hum = character:FindFirstChildOfClass("Humanoid")
				local root = character:FindFirstChild("HumanoidRootPart")

				if not hum or not root or hum.Health <= 0 or IFrames:HasiFrame(character, 1) then
					return
				end

				hum:TakeDamage(15)
				local direction = root.Position - position
				direction = Vector3.new(direction.X, 0, direction.Z)
				direction = if direction.Magnitude > 0.01 then direction.Unit else Vector3.new(1, 0, 0)
				Ragdoll.ragdoll(hum, 5)
				task.defer(function()
					if not active or not root.Parent then
						return
					end

					Knockback:Knockback(character, {
						KnockbackType = "Velocity",
						Velocity = direction * 90 + Vector3.new(0, 55, 0),
						MaxForce = Vector3.new(100000, 100000, 100000),
						Time = 0.3,
					})
				end)
			end
		)
	end

	local heartbeat = RunService.Heartbeat:Connect(function()
		local now = workspace:GetServerTimeNow()

		for id, rock in rocks do
			local elapsed = math.min(now - rock.Start, rock.Duration)
			local position = rock.Origin
				+ rock.Velocity * elapsed
				+ Vector3.new(0, -rock.Gravity * elapsed * elapsed / 2, 0)
			local delta = position - rock.Last
			local hit = if delta.Magnitude > 0.001
				then workspace:Spherecast(rock.Last, 10, delta, collisionParams)
				else nil
			if hit or elapsed >= rock.Duration then
				rocks[id] = nil
				local point = if hit then hit.Position else rock.Target
				Remote.FireAllClients("ReplicateTask", "Volcano", { Action = "Impact", Id = id, Position = point })
				impact(point)
			else
				rock.Last = position
			end
		end
	end)

	local function launch(player)
		local point, normal = target(player)

		if point then
			local origin = source.Position + Vector3.new(0, source.Size.Y / 2 + 12, 0)
			local gravity = math.max(workspace.Gravity, 1)
			local landingCenter = point + Vector3.new(0, 10, 0)
			local apex = math.max(origin.Y, landingCenter.Y) + random:NextNumber(100, 170)
			local up = math.sqrt(2 * gravity * (apex - origin.Y))
			local duration = up / gravity + math.sqrt(2 * (apex - landingCenter.Y) / gravity)
			local velocity = Vector3.new((point.X - origin.X) / duration, up, (point.Z - origin.Z) / duration)
			local id = HttpService:GenerateGUID(false)
			local rock = {
				Origin = origin,
				Velocity = velocity,
				Gravity = gravity,
				Duration = duration,
				Start = workspace:GetServerTimeNow(),
				Target = point,
				Normal = normal,
				Last = origin,
			}

			rocks[id] = rock
			Remote.FireAllClients("ReplicateTask", "Volcano", { Action = "Launch", Id = id, Rock = rock })
		end
	end

	task.spawn(function()
		while active do
			local players = Players:GetPlayers()

			for _, player in players do
				launch(player)
			end

			for _ = 1, #players * 4 do
				launch(nil)
			end

			task.wait(3)
		end
	end)

	return function()
		active = false
		heartbeat:Disconnect()
		table.clear(rocks)

		if passive then
			for _, emitter in passive:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		Remote.FireAllClients("ReplicateTask", "Volcano", { Action = "Clear" })
	end
end

return Volcano
