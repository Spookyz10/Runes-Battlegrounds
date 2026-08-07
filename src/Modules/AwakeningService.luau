local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local InfoModule = require(RS.Shared.Info)
local Data = require(RS.Shared.Data).server
local RemoteManager = require(RS.Shared.Modules.RemoteManager)

local SvModules = SvSt.Modules
local iFramesHandler = require(SvModules.iFramesService)
local MovesetHandler = require(SvModules.MovesetHandler)
local UltimateAnimations = require(SvModules.AwakeningAnimations)

local AwakeningService = {}

local function EndAwakening(
	Player: Player,
	Awk0C: RBXScriptConnection?,
	AwkTween: Tween?,
	DeathConn: RBXScriptConnection?
)
	if not Player or not Player.Parent then
		return
	end

	if Awk0C then
		Awk0C:Disconnect()
	end

	if DeathConn then
		DeathConn:Disconnect()
	end

	if AwkTween then
		if AwkTween.PlaybackState ~= Enum.PlaybackState.Completed then
			local Character = Player.Character
			if Character then
				local HumRP = Character:FindFirstChild("HumanoidRootPart")
				if HumRP then
					RemoteManager.FireAllClients(
						"ReplicateTask",
						"StopAwakeningMusics",
						{ MusAtt = HumRP.AwakeningMusic }
					)
				end
			end
		end
		AwkTween:Cancel()
	end

	Player:SetAttribute("Awakened", nil)

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	Character:RemoveTag("Awakened")
	Character:SetAttribute("Awakened", nil)
	Character:SetAttribute("AwakeningAura", false)

	RemoteManager.FireAllClients("ReplicateTask", "GivePlayerAura", { Char = Character })

	local moveset = Player:GetAttribute("Moveset")
	if moveset == "Eclipse" then
		local playerClass = Data[Player]
		local mode = playerClass and playerClass.MovesetModes("Eclipse")
		if mode == "Lunar" then
			RemoteManager.FireAllClients("ReplicateTask", "LunarAwakenEnd", { char = Character })
		elseif mode == "Solar" then
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenEnd", { char = Character })
		end
	end

	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end

	MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
end

local UltimateHandlers: { [string]: (Player: Player) -> () } = {
	["Astral Shift"] = function(Player: Player)
		local Moveset = Player:GetAttribute("MovesetMode_Eclipse")
		if Moveset == "Solar" then
			UltimateAnimations["Solar Eclipse"]:Activate(Player)
		elseif Moveset == "Lunar" then
			UltimateAnimations["Lunar Eclipse"]:Activate(Player)
		end
	end,
}

function AwakeningService:Activate(Player: Player)
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

		local AwkProgressObj = Player:FindFirstChild("AwakeningProgress") :: NumberValue?
		if not AwkProgressObj then
			return
		end

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

		local UltimateName = InfoModule.Movesets[CurrentMoveset].UltimateName
		local Handler = UltimateHandlers[UltimateName]
		if Handler then
			Handler(Player)
		end

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

		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

		local Awk0C: RBXScriptConnection
		local DeathConn: RBXScriptConnection?

		Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
			if not Ended and AwkProgressObj.Value <= 0 then
				Ended = true
				EndAwakening(Player, nil, AwkTween, DeathConn)
			end
		end)

		if Humanoid then
			DeathConn = Humanoid.Died:Connect(function()
				if not Ended then
					Ended = true
					EndAwakening(Player, Awk0C, AwkTween, nil)
				end
			end)

			Humanoid.WalkSpeed = 25
		end

		AwkTween:Play()
	end)
end

local function ClearAwakenedAttribute(Player: Player)
	Player:SetAttribute("Awakened", nil)
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function()
		ClearAwakenedAttribute(Player)
	end)
end)

for _, Player in Players:GetPlayers() do
	Player.CharacterAdded:Connect(function()
		ClearAwakenedAttribute(Player)
	end)
end

return AwakeningService
