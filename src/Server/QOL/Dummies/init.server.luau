--Services

local SvSt = game:GetService("ServerStorage")
local W = game:GetService("Workspace")
local RNS = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

--Bindables
local Bindables = SvSt.Bindables

local SpnDmy = Bindables.SpawnDummy

--Server Modules
local SvModules = SvSt.Modules

local AnimationService = require(SvModules.AnimationService)

--Variables
local LiveFolder = W.Live

--Functions
function HumanoidDied(Character, InitialHp)
	if Character:HasTag("Destroying") then
		return
	end
	Character:AddTag("Destroying")

	local Humanoid = Character:FindFirstChild("Humanoid")

	if not Humanoid then
		return
	else
		if not Character:HasTag("DontDoDieFunction") then
			if Humanoid.BreakJointsOnDeath then
				for _, v in Character:GetDescendants() do
					if v:IsA("Motor6D") or v:IsA("BallSocketConstraint") then
						v:Destroy()
					elseif v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") then
						v.AssemblyLinearVelocity =
							Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
						v.AssemblyAngularVelocity =
							Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
					end
				end

				require(SvModules.StunHandler):Stun(Character, 5)
			else
				Character:AddTag("CantRagdollCancel")

				require(SvModules.RagdollHandler).ragdoll(Humanoid)
			end
		end
	end

	require(SvModules.iFramesService):RemoveiFrames(Character, "All")
	workspace:SetAttribute("DummyDiedOnce", true)

	local respawnConnection
	local respawnStartTime = os.clock()
	local respawnDelay = 6

	local Attacking = Character:GetAttribute("AttackScript") and "AttackScript"
	local Blocking = Character:GetAttribute("BlockScript") and "BlockScript"

	respawnConnection = RNS.Heartbeat:Connect(function(deltaTime)
		if Character then
			if not Character.Parent or Character ~= Character then
				respawnConnection:Disconnect()
				return
			end
		end

		if not Character:GetAttribute("RespawnDisabled") then
			if (os.clock() - respawnStartTime) >= respawnDelay then
				Character:Destroy()
				spawnDummy(nil, InitialHp, Blocking or Attacking)

				respawnConnection:Disconnect()
				return
			end
		else
			respawnStartTime = os.clock()
			if respawnDelay ~= 2.5 then
				respawnDelay = 2.5
				return
			end
		end
	end)
end

function spawnDummy(CF, InitialHp, ScriptName)
	local dummyName = "Strongest Runester"
	local existingDummies = 0
	for _, v in workspace.Live:GetChildren() do
		if v:FindFirstChild("Dummy") then
			existingDummies += 1
		end
	end

	local DidDieFunction = false
	local Dummy = ServerScriptService["Strongest Runester"]:Clone()

	local Humanoid = Dummy.Humanoid

	if existingDummies > 0 then
		dummyName = "Strongest Runester " .. tostring(existingDummies)
		Humanoid.DisplayName = "Strongest Runester"
	end

	Dummy.Name = dummyName
	Dummy.Parent = LiveFolder
	CollectionService:AddTag(Dummy, "Character")

	Dummy.PrimaryPart:SetNetworkOwner(nil)

	if ScriptName and script.Scripts:FindFirstChild(ScriptName) then
		local Script: Script = script.Scripts[ScriptName]:Clone()
		Script.Parent = Dummy
		Script.Enabled = true

		Dummy:SetAttribute(ScriptName, true)
	end

	AnimationService:loadAnimations(Dummy)

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	Dummy.Humanoid.Died:Once(function()
		if DidDieFunction == true then
			return
		end
		DidDieFunction = true

		HumanoidDied(Dummy, InitialHp)
	end)

	Dummy.HumanoidRootPart:GetPropertyChangedSignal("Parent"):Connect(function()
		if DidDieFunction == true or not Dummy or not Dummy.Parent or not Dummy:FindFirstChild("HumanoidRootPart") then
			return
		end
		DidDieFunction = true

		HumanoidDied(Dummy, InitialHp)
	end)

	if CF then
		Dummy:PivotTo(CF)
	end

	if InitialHp then
		Dummy.Health.Enabled = false
		Humanoid.Health = InitialHp
	end

	task.spawn(function()
		if ScriptName then
			return
		end
	end)
end

--Events
SpnDmy.Event:Connect(function(CF, InitialHp, ScriptName)
	spawnDummy(CF, InitialHp, ScriptName)
end)

spawnDummy()
