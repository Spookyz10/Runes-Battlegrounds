local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tasks = require(ReplicatedStorage.Shared.Modules.Functions.Tasks)
local LocalPlayer = Players.LocalPlayer

local Remote = {}

local function detectAir(Params)
	local Char = Params.Char
	local HumRP2 = Char.PrimaryPart
	if not HumRP2 then
		return
	end

	local clampDivider = Params.customClamp or 5.2
	local justdown, isRagdoll = Params.justdown, Params.ragdoll
	local hitparams = Params.customParams or RaycastParams.new()

	while
		task.wait()
		and HumRP2 ~= nil
		and (not isRagdoll or (Char:HasTag("Ragdolled") or Char:HasTag("Knockbacked")))
	do
		local Velocity = HumRP2.AssemblyLinearVelocity
		local dir
		if Velocity.Magnitude < 1 or justdown ~= nil then
			dir = Vector3.new(0, justdown, 0)
		else
			dir = Velocity.Unit * (math.clamp(Velocity.Magnitude, 0, math.huge) / clampDivider)
		end
		local ray = workspace:Raycast(HumRP2.Position, dir, hitparams)
		if ray then
			local rayInstance = ray.Instance
			local rayPosition = ray.Position
			local rayMaterial = ray.Material
			local rayNormal = ray.Normal
			if
				Params.destroyables == true
				and (rayInstance.Parent.Name == "Tree" or rayInstance.Parent.Parent.Name == "Tree")
			then
				if rayInstance:IsDescendantOf(workspace.Map.Destroyables) and not rayInstance:HasTag("Destroyed") then
					Tasks["destroyAmbient"]({
						Parts = { rayInstance },
						CFrame = CFrame.lookAt(HumRP2.Position, Velocity.Unit),
						Size = Vector3.new(18, 18, 18),
						Burn = false,
						Velocity = Velocity.Unit * Velocity.Magnitude,
					})
				end
			else
				return true,
					{ Instance = rayInstance, Position = rayPosition, Material = rayMaterial, Normal = rayNormal }
			end
		end
	end

	return nil
end

function Remote:Activate(Params)
	local Char = Params.Char
	if not Char then
		return
	end

	local Bridge = LocalPlayer:WaitForChild(Params.Bridge, 5)
	if not Bridge then
		return
	end

	local isRunning = true
	Bridge.Destroying:Once(function()
		isRunning = false
	end)

	task.spawn(function()
		local Detected = detectAir(Params)
		if isRunning and Detected and Bridge and Bridge.Parent then
			Bridge:FireServer()
		end
	end)
end

return Remote
