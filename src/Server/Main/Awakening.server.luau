local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Assets = SvSt.Assets

local Animations = Assets.Animations

local AwkAnims = Animations.Awakenings

local InfoModule = require(RS.Shared.Info)

local SvModules = SvSt.Modules

local StunHandler = require(SvModules.StunHandler)
local HitboxHandler = require(SvModules.HitboxHandler)
local DamageHandler = require(SvModules.DamageHandler)
local AnimationService = require(SvModules.AnimationService)
local iFramesHandler = require(SvModules.iFramesService)
local MovesetHandler = require(SvModules.MovesetHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local NewKnockback = require(SvModules.BodymoverService)

local RpRemotes = RS.Remotes
local AwakeningRemotes = RpRemotes.Awakening
local AwakeningSet = AwakeningRemotes.Set
local ReplicateRemotes = RpRemotes.Replicate
local ReplicateSet = ReplicateRemotes.Set
local Comms = RpRemotes.Comunicator
local CommsSet = Comms.Set

local AwakeningSvEvent = AwakeningSet.OnServerEvent

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

	task.spawn(function()
		shared.AddAppareance(Player, Character)
	end)

	MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
end

local AwakeningAnimations = {

	["Eclipse"] = function(Player) end,
}

local function Awakening(Player)
	task.spawn(function()
		if Player.Commands.NoAwk.Value == true then
			return
		end

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

		local Humanoid = Character.Humanoid

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
		if CurrentMoveset ~= "Cursed Child" then
			Humanoid.Health = Humanoid.MaxHealth
		end

		iFramesHandler:AddAlliFrames(Character)

		CommsSet:FireClient(Player, "HideHotbar")
		CommsSet:FireClient(Player, "HideAwkbar")

		task.delay(0.5, function()
			MovesetHandler:AddAwakeningMoveset(Player, Player:GetAttribute("Moveset"))
		end)

		if AwakeningAnimations[CurrentMoveset] then
			AwakeningAnimations[CurrentMoveset](Player)

			CommsSet:FireClient(Player, "ShowHotbar")
		else
			task.delay(0.5, function()
				CommsSet:FireClient(Player, "ShowHotbar")
				CommsSet:FireClient(Player, "ShowAwkbar")
			end)
		end

		local playerClass = shared.playerClasses[Player.UserId]
		if playerClass then
			playerClass.TitlesProgress.Awakens += 1
			Player:SetAttribute("AwakensProgress", playerClass.TitlesProgress.Awakens)
		end

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

		if not workspace.Configuration.InfiniteAwk.Value then
			AwkTween.Completed:Once(function()
				if Ended == false then
					Ended = true

					EndAwakening(Player, Awk0C, AwkTween)
				end
			end)

			if CurrentMoveset ~= "KJ" and CurrentMoveset ~= "The Strongest Hero" then
				AwkTween:Play()
			end
		end
	end)
end

AwakeningSvEvent:Connect(function(Player)
	if Player.AwakeningProgress.Value < 100 then
		return
	end

	Awakening(Player)
end)

shared.ActivateAwakening = Awakening
