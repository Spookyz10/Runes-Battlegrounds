local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local InfoModule = require(RS.Shared.Info)
local RemoteManager = require(RS.Shared.Modules.RemoteManager)
local SFXModule = require(RS.Shared.Modules.SFXModule)

local SvModules = SvSt.Modules
local iFramesHandler = require(SvModules.iFramesService)
local MovesetHandler = require(SvModules.MovesetHandler)
local UltimateAnimations

local function getUltimateAnimations()
	if not UltimateAnimations then
		UltimateAnimations = require(SvModules.AwakeningAnimations)
	end
	return UltimateAnimations
end

local AwakeningMusicFolder = RS.Resources.Music.Awakenings

local AwakeningService = {}

local ActiveAwakenings = {}
local ActiveAwakeningMusic = {}

local function stopAwakeningMusic(Player)
	local Sound = ActiveAwakeningMusic[Player]
	if not Sound then
		return
	end

	ActiveAwakeningMusic[Player] = nil
	SFXModule:StopInstance(Sound)
end

local function playAwakeningMusic(Player, Character, MusicName)
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local MusicAsset = AwakeningMusicFolder:FindFirstChild(MusicName)
	if not MusicAsset then
		return
	end

	stopAwakeningMusic(Player)

	local Sound = SFXModule:PlayInstance(MusicAsset, HumRP)
	ActiveAwakeningMusic[Player] = Sound
end

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

	stopAwakeningMusic(Player)

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
		local mode = Player:GetAttribute("MovesetMode_Eclipse")
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
			getUltimateAnimations()["Solar Eclipse"]:Activate(Player)
		elseif Moveset == "Lunar" then
			getUltimateAnimations()["Lunar Eclipse"]:Activate(Player)
		end
	end,
}

local function doActivate(Player: Player, Bypass: boolean?)
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

	if ActiveAwakenings[Player] then
		return
	end

	if not Bypass then
		if
			Character:HasTag("Stunned")
			or Character:HasTag("Awakened")
			or Character:GetAttribute("Awakened") == true
		then
			return
		end
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
		playAwakeningMusic(Player, Character, UltimateName)
		Handler(Player)
	end

	MovesetHandler:AddAwakeningMoveset(Player, Player:GetAttribute("Moveset"))

	iFramesHandler:RemoveAlliFrames(Character)

	local State = { Ended = false }

	local AwkTween = TS:Create(
		AwkProgressObj,
		TweenInfo.new(InfoModule.Movesets[Player:GetAttribute("Moveset")].UltimateTime, Enum.EasingStyle.Linear),
		{ Value = 0 }
	)

	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

	local Awk0C: RBXScriptConnection
	local DeathConn: RBXScriptConnection?

	Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
		if not State.Ended and AwkProgressObj.Value <= 0 then
			State.Ended = true
			ActiveAwakenings[Player] = nil
			EndAwakening(Player, nil, AwkTween, DeathConn)
		end
	end)

	if Humanoid then
		DeathConn = Humanoid.Died:Connect(function()
			if not State.Ended then
				State.Ended = true
				ActiveAwakenings[Player] = nil
				EndAwakening(Player, Awk0C, AwkTween, nil)
			end
		end)

		Humanoid.WalkSpeed = 25
	end

	ActiveAwakenings[Player] = {
		State = State,
		Awk0C = Awk0C,
		AwkTween = AwkTween,
		DeathConn = DeathConn,
	}

	AwkTween:Play()
end

function AwakeningService:Activate(Player: Player)
	task.spawn(doActivate, Player, false)
end

function AwakeningService:ForceActivate(Player: Player)
	task.spawn(doActivate, Player, true)
end

function AwakeningService:EndEarly(Player: Player)
	local Active = ActiveAwakenings[Player]
	if not Active or Active.State.Ended then
		return
	end

	Active.State.Ended = true
	ActiveAwakenings[Player] = nil

	EndAwakening(Player, Active.Awk0C, Active.AwkTween, Active.DeathConn)
end

function AwakeningService:IsAwakened(Player: Player)
	return ActiveAwakenings[Player] ~= nil
end

function AwakeningService:GiveProgress(Player: Player, Amount: number)
	if not Amount or Amount == 0 then
		return
	end

	local AwkProgressObj = Player:FindFirstChild("AwakeningProgress") :: NumberValue?
	if not AwkProgressObj then
		return
	end

	if Player:GetAttribute("Awakened") == true then
		return
	end

	AwkProgressObj.Value = math.clamp(AwkProgressObj.Value + Amount, 0, 100)
end

function AwakeningService:DrainProgress(Player: Player, Amount: number)
	if not Amount or Amount == 0 then
		return
	end

	local AwkProgressObj = Player:FindFirstChild("AwakeningProgress") :: NumberValue?
	if not AwkProgressObj then
		return
	end

	AwkProgressObj.Value = math.clamp(AwkProgressObj.Value - Amount, 0, 100)
end

local function ClearAwakenedAttribute(Player: Player)
	Player:SetAttribute("Awakened", nil)
	ActiveAwakenings[Player] = nil
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

Players.PlayerRemoving:Connect(function(Player)
	stopAwakeningMusic(Player)
end)

return AwakeningService
