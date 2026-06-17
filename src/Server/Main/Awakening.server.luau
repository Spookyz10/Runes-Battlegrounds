local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local TS = game:GetService("TweenService")

local InfoModule = require(RS.Shared.Info)

local SvModules = SvSt.Modules

local iFramesHandler = require(SvModules.iFramesService)
local MovesetHandler = require(SvModules.MovesetHandler)

local AwakenAnimations = require(script.Parent.AwakeningAnimations)

local RpRemotes = RS.Remotes
local AwakeningRemotes = RpRemotes.Awakening
local AwakeningSet = AwakeningRemotes.Set
local ReplicateRemotes = RpRemotes.Replicate
local ReplicateSet = ReplicateRemotes.Set

local function EndAwakening(Player, Awk0C, AwkTween)
	if not Player or not Player.Parent then
		return
	end

	local Character = Player.Character

	local HumRP = Character.HumanoidRootPart

	if AwkTween.PlaybackState ~= Enum.PlaybackState.Completed then
		ReplicateSet:FireAllClients("StopAwakeningMusics", { MusAtt = HumRP.AwakeningMusic })
	end

	if Awk0C then
		Awk0C:Disconnect()
		Awk0C = nil
	end

	if AwkTween then
		AwkTween:Cancel()
		AwkTween = nil
	end

	Player:SetAttribute("Awakened", nil)

	Character:RemoveTag("Awakened")
	Character:SetAttribute("Awakened", nil)
	Character:SetAttribute("AwakeningAura", false)

	if Character:FindFirstChild("Humanoid") then
		Character.Humanoid.WalkSpeed = 16
	end

	MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
end

local AwakeningAnimations = {
	["Astral Shift"] = function(Player)
		local Moveset = Player:GetAttribute("MovesetMode_Eclipse")
		if Moveset == "Solar" then
			ReplicateSet:FireAllClients("Solar Eclipse", { char = Player.Character })
		elseif Moveset == "Lunar" then
			task.spawn(function()
				AwakenAnimations["Lunar Eclipse"]:Activate(Player)
			end)
		end
	end,
}

local function Awakening(Player)
	task.spawn(function()
		local Character = Player.Character

		if
			Character == nil
			or Character.Parent == nil
			or not Character:FindFirstChild("Humanoid")
			or (Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0)
			or not Character:FindFirstChild("HumanoidRootPart")
		then
			return
		end

		local AwkProgressObj = Player.AwakeningProgress

		if
			Character:HasTag("Stunned")
			or Character:HasTag("Awakened")
			or Character:GetAttribute("Awakened") == true
		then
			return
		end

		AwkProgressObj.Value = 100

		local CurrentMoveset = Player:GetAttribute("Moveset")
		Character:AddTag("Awakened")
		Character:SetAttribute("Awakened", true)
		Player:SetAttribute("Awakened", true)

		iFramesHandler:AddAlliFrames(Character)

		AwakeningAnimations[InfoModule.Movesets[CurrentMoveset].UltimateName](Player)

		task.delay(0.5, function()
			MovesetHandler:AddAwakeningMoveset(Player, Player:GetAttribute("Moveset"))
		end)

		iFramesHandler:RemoveAlliFrames(Character)

		local Ended = false
		local AwkTween = TS:Create(
			AwkProgressObj,
			TweenInfo.new(InfoModule.Movesets[Player:GetAttribute("Moveset")].UltimateTime, Enum.EasingStyle.Linear),
			{ Value = 0 }
		)

		local Awk0C
		Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
			if Ended == false and AwkProgressObj.Value <= 0 then
				Ended = true
				Awk0C:Disconnect()

				EndAwakening(Player, Awk0C, AwkTween)
			end
		end)

		if Character:FindFirstChild("Humanoid") then
			Character.Humanoid.WalkSpeed = 25
		end
	end)
end

AwakeningSet.OnServerEvent:Connect(function(Player)
	if Player.AwakeningProgress.Value < 100 then
		return
	end

	Awakening(Player)
end)

shared.ActivateAwakening = Awakening
