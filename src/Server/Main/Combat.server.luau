local RS = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Remotes = RS.Remotes

local CombatSet = Remotes.Combat.Set
local CombatSetEvent = CombatSet.OnServerEvent

local SvModules = SvSt.Modules

local AnimationService = require(SvModules.AnimationService)
local SoundsModule = require(SvModules.SoundsModule)
local M1Handler = require(SvModules.M1Handler)

local Assets = SvSt.Assets
local Animations = Assets.Animations
local Sounds = Assets.Sounds
local CombatSounds = Sounds.Combat
local ReplicateSet = Remotes.Replicate.Set

local function Block(Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doBlock") ~= true then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	if Character:HasTag("CantBlock") or Character:HasTag("Stunned") or Character:HasTag("Punching") then
		task.delay(0.1, function()
			Block(Player)
		end)
		return
	elseif Character:HasTag("Blocking") then
		return
	end

	local Actions = { "CantPunch", "CantDash", "CantBlock", "Blocking", "CantRun" }
	local Connections = {}
	local Stopped

	local Anim = Animations.Combat.Block
	SoundsModule:PlaySound(CombatSounds.Blocking.Start, HumRP)

	local function stopBlock()
		if Stopped then
			return
		end
		Stopped = true

		for _, v in Connections do
			v:Disconnect()
		end

		Character:SetAttribute("DefaultRunSpeed", 25)
		Character:SetAttribute("DefaultWalkSpeed", 16)
		Character:SetAttribute("DefaultJumpPower", 50)
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50

		for _, Action in ipairs(Actions) do
			Character:RemoveTag(Action)
		end

		SoundsModule:PlaySound(CombatSounds.Blocking.Stop, HumRP)

		ReplicateSet:FireAllClients("ActionHightlight", { char = Character, func = "BlockEnd" })
	end

	local BlockAnimTrack = AnimationService:getAnimationTrack(Character, Anim)

	Connections["Stopped"] = BlockAnimTrack.Stopped:Once(stopBlock)
	Connections["StopLoop"] = Character:GetAttributeChangedSignal("doBlock"):Connect(function()
		if not Character:GetAttribute("doBlock") then
			AnimationService:stopAnimation(Character, Anim)
			stopBlock()
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Anim)

	Character:SetAttribute("DefaultRunSpeed", 8)
	Character:SetAttribute("DefaultWalkSpeed", 8)
	Humanoid.WalkSpeed = 8
	Humanoid.JumpPower = 0

	for _, Action in ipairs(Actions) do
		Character:AddTag(Action)
	end

	ReplicateSet:FireAllClients("ActionHightlight", { char = Character, func = "BlockStart" })

	local Perfect = true
	local PC
	PC = Character.ChildAdded:Connect(function(Child)
		if Child.Name == "DamagedLog" and Child:HasTag("IsM1") and Perfect then
			if PC then
				PC:Disconnect()
				PC = nil
			end
			Character:AddTag("PerfectBlock")
			task.delay(1, function()
				Character:RemoveTag("PerfectBlock")
			end)
		end
	end)

	task.delay(0.25, function()
		if PC then
			PC:Disconnect()
			PC = nil
		end
		Perfect = false
	end)
end

CombatSetEvent:Connect(function(Player, Action, Params)
	if not Player:FindFirstChild("LoadedData") then
		return
	end

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not HumRP or not Humanoid then
		return
	end

	if Action == "PunchStart" then
		Character:SetAttribute("doPunch", true)
		M1Handler:Punch(Player)
	elseif Action == "PunchEnd" then
		Character:SetAttribute("doPunch", false)
	elseif Action == "Block" then
		if Params.Stage == true then
			Character:SetAttribute("doBlock", true)
			Block(Player)
		else
			Character:SetAttribute("doBlock", false)
		end
	end
end)
