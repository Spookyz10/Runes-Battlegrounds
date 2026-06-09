--[[
	LaunchService
	src/modules/LaunchService.luau
]]

local LaunchService = {}

local Players = game:GetService("Players")
local RagdollService = require(script.Parent.RagdollService)
local StunService = require(script.Parent.StunService)

local LAUNCH_ATTR = "Launched"
local MIN_AIR_TIME = 0.25
local POLL_INTERVAL = 0.05

local activeThreads = {}

local DEFAULT_LANDING = { horizontal = 20, vertical = 6 }

local function applyLandingKnockback(character, landingImpact)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local vel = root.AssemblyLinearVelocity
	local horizontal = Vector3.new(vel.X, 0, vel.Z)
	local dir = horizontal.Magnitude > 0.1 and horizontal.Unit or root.CFrame.LookVector

	local impact = landingImpact or DEFAULT_LANDING

	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = Vector3.new(
				dir.X * impact.horizontal,
				impact.vertical,
				dir.Z * impact.horizontal
			)
		end
	end
end

local function pollUntilLanded(character, landingImpact)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	task.wait(MIN_AIR_TIME)

	while character and character.Parent and character:GetAttribute(LAUNCH_ATTR) do
		task.wait(POLL_INTERVAL)
		if not character.Parent then break end

		if humanoid.FloorMaterial ~= Enum.Material.Air then
			character:SetAttribute(LAUNCH_ATTR, false)
			activeThreads[character] = nil
			RagdollService.remove(character)
			StunService.clear(character)
			applyLandingKnockback(character, landingImpact)
			return
		end
	end

	activeThreads[character] = nil
end

function LaunchService.apply(character, velocity, landingImpact)
	LaunchService.clear(character)
	RagdollService.apply(character)

	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = velocity
		end
	end

	character:SetAttribute(LAUNCH_ATTR, true)
	StunService.apply(character, 999)

	local thread = task.spawn(pollUntilLanded, character, landingImpact)
	activeThreads[character] = thread
end

function LaunchService.isLaunched(character)
	return character:GetAttribute(LAUNCH_ATTR) == true
end

function LaunchService.clear(character)
	local thread = activeThreads[character]
	if thread then
		task.cancel(thread)
		activeThreads[character] = nil
	end
	if character and character.Parent then
		character:SetAttribute(LAUNCH_ATTR, false)
		StunService.clear(character)
		if RagdollService.isRagdolled(character) then
			RagdollService.remove(character)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		LaunchService.clear(character)
		activeThreads[character] = nil
	end)
end)

return LaunchService
