local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local Loop = require(RS.Shared.Modules.Functions.Loop)
local Tasks = require(RS.Shared.Modules.Functions.Tasks)
local RemoteManager = require(RS.Shared.Modules.RemoteManager)

local Animations = RS.Resources.Animations

local DashResolver = {}

local __moduleId = tostring(math.random(1, 999999))

local LastSideDash = {}
local LastBackDash = {}
local LastDashRequest = {}

local DASH_INPUT_DEBOUNCE = 1
local CLIENT_COOLDOWN_BUFFER = 0.2

local AxisKey = {
	Front = "Dash_Z",
	Back = "Dash_Z",
	Left = "Dash_X",
	Right = "Dash_X",
}

local DirectionCooldown = {
	Front = 5,
	Back = 5,
	Left = 2,
	Right = 2,
}

local AxisCooldownExpiry = {}

local function isAxisOnCooldown(Character, Direction)
	local Axis = AxisKey[Direction]
	if not Axis then
		return false
	end

	local CharacterAxes = AxisCooldownExpiry[Character]
	if not CharacterAxes then
		return false
	end

	local Expiry = CharacterAxes[Axis]
	if not Expiry then
		return false
	end

	local onCooldown = tick() < Expiry

	return onCooldown
end

local function markAxisUsed(Character, Direction, Duration: number?, IsGuess: boolean?)
	local Axis = AxisKey[Direction]
	if not Axis then
		return
	end

	AxisCooldownExpiry[Character] = AxisCooldownExpiry[Character] or {}

	local BaseDuration = Duration or DirectionCooldown[Direction] or 2
	if IsGuess then
		BaseDuration += CLIENT_COOLDOWN_BUFFER
	end

	local NewExpiry = tick() + BaseDuration
	local CurrentExpiry = AxisCooldownExpiry[Character][Axis]

	if CurrentExpiry and CurrentExpiry > NewExpiry then
		return
	end

	AxisCooldownExpiry[Character][Axis] = NewExpiry
end

function DashResolver.IsTrapped(Character)
	if not Character then
		return false
	end

	if Character:HasTag("Ragdolled") then
		return true
	end

	local StunnedFolder = Character:FindFirstChild("Stunned")
	if not StunnedFolder then
		return false
	end

	return StunnedFolder:GetAttribute("Escapable") ~= false
end

function DashResolver.HasEvasiveCharge(Character)
	if not Character then
		return false
	end
	return (Character:GetAttribute("EvasivaCharges") or 0) > 0
end

function DashResolver.Resolve(Character, Humanoid, HumRP)
	local rotation

	if UIS.KeyboardEnabled and not UIS.TouchEnabled then
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			rotation = 0
		elseif UIS:IsKeyDown(Enum.KeyCode.S) then
			rotation = 180
		elseif UIS:IsKeyDown(Enum.KeyCode.D) then
			rotation = -90
		elseif UIS:IsKeyDown(Enum.KeyCode.A) then
			rotation = 90
		end
	else
		local baseCFrame = HumRP.CFrame
		local reference = HumRP.CFrame + Humanoid.MoveDirection * 15
		local referencePosition = reference.Position
		local lookVector = (
			Vector3.new(referencePosition.X, baseCFrame.Position.Y, referencePosition.Z) - baseCFrame.Position
		).Unit
		local lookVectorRotation = math.deg(math.acos(baseCFrame.LookVector:Dot(lookVector)))

		rotation = 0
		if lookVectorRotation > -45 and lookVectorRotation < 45 then
			rotation = 0
		elseif lookVectorRotation > 135 and lookVectorRotation < 215 then
			rotation = 180
		elseif lookVectorRotation >= 45 and lookVectorRotation <= 135 then
			local rightRef = HumRP.CFrame * CFrame.new(15, 0, 0)
			local leftRef = HumRP.CFrame * CFrame.new(-15, 0, 0)
			rotation = (reference.Position - rightRef.Position).Magnitude
						> (reference.Position - leftRef.Position).Magnitude
					and 90
				or -90
		end
	end

	local Direction
	if rotation == 0 then
		Direction = "Front"
	elseif rotation == 180 then
		Direction = "Back"
	elseif rotation == 90 then
		Direction = "Left"
	elseif rotation == -90 then
		Direction = "Right"
	else
		Direction = "Front"
	end

	local Trapped = DashResolver.IsTrapped(Character)
	local Escaping = false
	local CanAct = true

	if Trapped then
		if not DashResolver.HasEvasiveCharge(Character) then
			CanAct = false

			return Direction, Trapped, Escaping, CanAct
		end

		Escaping = true
		if Direction == "Front" then
			local Side = HumRP.CFrame.RightVector:Dot(Humanoid.MoveDirection)
			Direction = Side < 0 and "Left" or "Right"
		end
	end

	return Direction, Trapped, Escaping, CanAct
end

function DashResolver.PerformLocalDash(Character, Humanoid, HumRP, Camera, Animator, Direction, Escaping)
	local gameSettings = UserSettings().GameSettings

	if Direction == "Left" or Direction == "Right" then
		LastSideDash[Character] = LastSideDash[Character] or 0
		if tick() - LastSideDash[Character] < 2 then
			return
		end

		if not Escaping then
			if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
				if
					Character:HasTag("SideDashCD")
					or Character:HasTag("CantSideDash")
					or Character:HasTag("Stunned")
				then
					return
				end
			elseif Character:HasTag("CantRagdollCancel") or Character:GetAttribute("RagdollCancel") ~= true then
				return
			end
		end

		LastSideDash[Character] = tick()
		Tasks["ClearVelocities"](HumRP)
		Character:SetAttribute("SideDashing", true)

		if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
			Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		if Humanoid.PlatformStand then
			Humanoid.PlatformStand = false
		end

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		task.delay(0.6, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end)

		local dashAnim = Direction == "Left" and Animations.Dashes.DashLeft or Animations.Dashes.DashRight
		local dashTrack = Animator:LoadAnimation(dashAnim)

		local speed = 200
		local sideMultiplier = Direction == "Right" and 1 or -1

		gameSettings.RotationType = Enum.RotationType.CameraRelative

		local stopLoop = nil

		local dashVelocity = Instance.new("BodyVelocity")
		dashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000)
			or Vector3.new(50000, 0, 50000)
		dashVelocity.Parent = HumRP

		dashTrack.Stopped:Once(function()
			if stopLoop then
				stopLoop()
			end
			if dashVelocity.Parent then
				dashVelocity:Destroy()
			end

			HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
			gameSettings.RotationType = Enum.RotationType.MovementRelative
		end)

		task.delay(0.325, function()
			Character:SetAttribute("SideDashing", false)
		end)

		dashTrack:Play()

		stopLoop = Loop.new(function(stop)
			if speed > 5 and dashVelocity.Parent then
				speed *= 0.91
				HumRP.CFrame = CFrame.lookAlong(HumRP.Position, Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
				dashVelocity.Velocity = (HumRP.CFrame.RightVector * sideMultiplier) * speed
			else
				stop()
				if dashVelocity.Parent then
					dashVelocity:Destroy()
				end

				HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
				gameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end)
	elseif Direction == "Back" then
		LastBackDash[Character] = LastBackDash[Character] or 0
		if tick() - LastBackDash[Character] < 5 then
			return
		end

		if not Escaping then
			if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
				if Character:HasTag("DashCD") or Character:HasTag("CantDash") or Character:HasTag("Stunned") then
					return
				end
			elseif Character:HasTag("CantRagdollCancel") or Character:GetAttribute("RagdollCancel") ~= true then
				return
			end
		end

		LastBackDash[Character] = tick()
		Tasks["ClearVelocities"](HumRP)
		Character:SetAttribute("Dashing", true)

		if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
			Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		if Humanoid.PlatformStand then
			Humanoid.PlatformStand = false
		end

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Character:AddTag("CantSideDash")
		task.delay(1.051, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			Character:RemoveTag("CantSideDash")
		end)

		local dashAnim = Animations.Dashes.DashBack
		local dashTrack = Animator:LoadAnimation(dashAnim)

		gameSettings.RotationType = Enum.RotationType.CameraRelative

		local speed = 260

		local dashVelocity = Instance.new("BodyVelocity")
		dashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000)
			or Vector3.new(50000, 0, 50000)
		dashVelocity.Parent = HumRP

		dashTrack.Stopped:Once(function()
			Character:SetAttribute("Dashing", false)
			if dashVelocity.Parent then
				dashVelocity:Destroy()
			end
			gameSettings.RotationType = Enum.RotationType.MovementRelative
		end)

		dashTrack:Play()

		local stopLoop = nil
		stopLoop = Loop.new(function(stop)
			if dashVelocity.Parent then
				speed *= 0.91
				if speed <= 10 then
					dashVelocity:Destroy()
				end
				HumRP.CFrame = CFrame.lookAlong(HumRP.Position, Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
				dashVelocity.Velocity = -HumRP.CFrame.LookVector * speed
			else
				stop()
				gameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end)
	end
end

function DashResolver.PerformDash(Character, Humanoid, HumRP, Camera, Animator)
	local Now = tick()
	local LastRequest = LastDashRequest[Character]

	if LastRequest and (Now - LastRequest) < DASH_INPUT_DEBOUNCE then
		return
	end

	LastDashRequest[Character] = Now

	local Direction, Trapped, Escaping, CanAct = DashResolver.Resolve(Character, Humanoid, HumRP)

	if not CanAct then
		return Direction, Trapped, Escaping, CanAct
	end

	if not Escaping and isAxisOnCooldown(Character, Direction) then
		return Direction, Trapped, Escaping, false
	end

	if not Escaping then
		markAxisUsed(Character, Direction, nil, true)
	end

	RemoteManager.FireServer("Keypress", { Key = Enum.KeyCode.Q, Direction = Direction, ClientCFrame = HumRP.CFrame })

	if Direction ~= "Front" then
		DashResolver.PerformLocalDash(Character, Humanoid, HumRP, Camera, Animator, Direction, Escaping)
	end

	return Direction, Trapped, Escaping, CanAct
end

function DashResolver.ConfirmAxisCooldown(SkillName: string, Cooldown: number)
	local Direction = (SkillName:gsub("Dash$", ""))
	local Axis = AxisKey[Direction]
	if not Axis then
		return
	end

	local Character = Players.LocalPlayer.Character
	if not Character then
		return
	end

	markAxisUsed(Character, Direction, Cooldown, false)
end

function DashResolver.Cleanup(Character)
	if not Character then
		return
	end

	LastSideDash[Character] = nil
	LastBackDash[Character] = nil
	LastDashRequest[Character] = nil
	AxisCooldownExpiry[Character] = nil
end

return DashResolver
