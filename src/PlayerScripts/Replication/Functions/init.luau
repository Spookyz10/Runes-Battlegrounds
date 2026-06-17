--Services
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
--Player
local LocalPlayer = game.Players.LocalPlayer
--Remotes
local Remotes = RS.Remotes
local Comunicator = Remotes.Comunicator
local ComSet = Comunicator.Set
local Replicate = Remotes.Replicate
local Replicate_Set = Replicate.Set
local Replicate_Get = Replicate.Get
--Interface Handler
local Interface = {}
Interface.__index = Interface

function Interface.new()
	local metatable = setmetatable({}, Interface)
	return metatable
end

--Runtime
function Interface:Start()
	while true do
		if game:IsLoaded() then
			break
		end
		task.wait()
	end

	local ClientTasks = require(script.Tasks)

	local function repfire(replicateName, params)
		local ReplicateFunc = ClientTasks[replicateName]

		if ReplicateFunc then
			coroutine.wrap(function()
				ReplicateFunc(params)
			end)()
		else
			warn(replicateName .. " does not exist for replication.")
		end
	end

	Replicate_Set.OnClientEvent:Connect(repfire)
	Replicate_Get.OnClientInvoke = function(GoalName, Parameters)
		if GoalName == "IsPartDestroyed" then
			return table.find(shared.DestroyedParts, Parameters.Part) ~= nil
		end
	end
	shared.repfire = repfire

	local ResetBindable = Instance.new("BindableEvent")
	ResetBindable.Event:Connect(function()
		if workspace.Configuration.NoReset.Value == true or LocalPlayer.Commands.NoReset.Value == true then
			return
		end
		ComSet:FireServer("ResetCharacter")
	end)

	task.spawn(function()
		while task.wait(0.2) do
			local Status = pcall(function()
				game.StarterGui:SetCore("ResetButtonCallback", ResetBindable)
			end)
			if Status then
				break
			end
		end
	end)

	local Clouds = workspace.Terrain:FindFirstChild("Clouds")
	local function UpdateClouds()
		if not Clouds then
			return
		end
		task.wait()
		local Gone = Clouds:FindFirstChild("Gone")
		local CloudTime = Gone and 0 or 0.714
		local Speed = 6
		local IsSlow = false
		if Gone and Gone:GetAttribute("Slow") then
			Speed = 10
			IsSlow = true
		end
		if Clouds.Cover ~= CloudTime then
			TS:Create(
				Clouds,
				TweenInfo.new(
					CloudTime == 0 and Speed or 30,
					Enum.EasingStyle.Quad,
					IsSlow and Enum.EasingDirection.InOut or Enum.EasingDirection.Out
				),
				{ Cover = CloudTime }
			):Play()
		end
	end

	if Clouds then
		Clouds.ChildAdded:Connect(UpdateClouds)
		Clouds.ChildRemoved:Connect(UpdateClouds)
		UpdateClouds()
	end
	ComSet:FireServer("replicationLoaded")

	shared.clearVelocities = function(Part: Part, Ignore: BodyVelocity?)
		for _, Velocity in Part:GetDescendants() do
			if
				Velocity ~= Ignore
				and (
					Velocity:IsA("BodyVelocity")
					or Velocity:IsA("LinearVelocity")
					or Velocity:IsA("BodyPosition")
					or Velocity:IsA("BodyGyro")
					or Velocity:IsA("BodyAngularVelocity")
					or Velocity:IsA("BodyMover")
					or Velocity:IsA("BodyForce")
					or Velocity:IsA("BodyThrust")
					or Velocity:IsA("AngularVelocity")
					or Velocity:IsA("VelocityMotor")
				)
			then
				Velocity:Destroy()
			end
		end
	end

	script:Destroy()
end

return Interface
