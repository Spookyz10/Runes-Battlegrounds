local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InfoModule = require(RS.Shared.Info)
local Data = require(ReplicatedStorage.Shared.Data).server

local SvModules = SvSt.Modules

local iFramesHandler = require(SvModules.iFramesService)
local MovesetHandler = require(SvModules.MovesetHandler)

local AwakenAnimations = require(script.Parent.AwakeningAnimations)

local RpRemotes = RS.Remotes
local AwakeningRemotes = RpRemotes.Awakening
local AwakeningSet = AwakeningRemotes.Set
local ReplicateRemotes = RpRemotes.Replicate
local ReplicateSet = ReplicateRemotes.Set

local function EndAwakening(Player, Awk0C, AwkTween, DeathConn)
	if not Player or not Player.Parent then
		return
	end

	if Awk0C then
		Awk0C:Disconnect()
		Awk0C = nil
	end

	if DeathConn then
		DeathConn:Disconnect()
		DeathConn = nil
	end

	if AwkTween then
		if AwkTween.PlaybackState ~= Enum.PlaybackState.Completed then
			local Character = Player.Character
			if Character then
				local HumRP = Character:FindFirstChild("HumanoidRootPart")
				if HumRP then
					ReplicateSet:FireAllClients("StopAwakeningMusics", { MusAtt = HumRP.AwakeningMusic })
				end
			end
		end
		AwkTween:Cancel()
		AwkTween = nil
	end

	Player:SetAttribute("Awakened", nil)

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	Character:RemoveTag("Awakened")
	Character:SetAttribute("Awakened", nil)
	Character:SetAttribute("AwakeningAura", false)

	local moveset = Player:GetAttribute("Moveset")
	if moveset == "Eclipse" then
		local playerClass = Data[Player]
		local mode = playerClass and playerClass.MovesetModes("Eclipse")
		if mode == "Lunar" then
			ReplicateSet:FireAllClients("LunarAwakenEnd", { char = Character })
		elseif mode == "Solar" then
			ReplicateSet:FireAllClients("SolarAwakenEnd", { char = Character })
		end
	end

	if Character:FindFirstChild("Humanoid") then
		Character.Humanoid.WalkSpeed = 16
	end

	MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
end

local AwakeningAnimations = {
	["Astral Shift"] = function(Player)
		local Moveset = Player:GetAttribute("MovesetMode_Eclipse")
		if Moveset == "Solar" then
			AwakenAnimations["Solar Eclipse"]:Activate(Player)
		elseif Moveset == "Lunar" then
			AwakenAnimations["Lunar Eclipse"]:Activate(Player)
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
		local DeathConn
		local Humanoid = Character:FindFirstChild("Humanoid")

		Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
			if Ended == false and AwkProgressObj.Value <= 0 then
				Ended = true
				EndAwakening(Player, nil, AwkTween, DeathConn)
			end
		end)

		if Humanoid then
			DeathConn = Humanoid.Died:Connect(function()
				if Ended == false then
					Ended = true
					EndAwakening(Player, Awk0C, AwkTween, nil)
				end
			end)
		end

		if Humanoid then
			Humanoid.WalkSpeed = 25
		end

		AwkTween:Play()
	end)
end

AwakeningSet.OnServerEvent:Connect(function(Player)
	if Player.AwakeningProgress.Value < 100 then
		return
	end

	Awakening(Player)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		player:SetAttribute("Awakened", nil)
	end)
end)

for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(function()
		player:SetAttribute("Awakened", nil)
	end)
end

shared.ActivateAwakening = Awakening
