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
local CharacterLifetime = require(SvModules.CharacterLifetime)
local AnimationService = require(SvModules.AnimationService)
local Awakenings

local function getAwakenings()
	if not Awakenings then
		Awakenings = require(SvModules.AwakeningAnimations)
	end
	return Awakenings
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
	Sound:SetAttribute("AwakeningMusic", true)
	ActiveAwakeningMusic[Player] = Sound
end

local function EndAwakening(
	Player: Player,
	Awk0C: RBXScriptConnection?,
	AwkTween: Tween?,
	DeathConn: RBXScriptConnection?,
	OriginalCharacter: Model?
)
	if Awk0C then
		Awk0C:Disconnect()
	end

	if DeathConn then
		DeathConn:Disconnect()
	end

	stopAwakeningMusic(Player)

	if AwkTween then
		if AwkTween.PlaybackState ~= Enum.PlaybackState.Completed then
			local Character = OriginalCharacter or Player.Character
			if Character then
				local HumRP = Character:FindFirstChild("HumanoidRootPart")
				if HumRP and HumRP:FindFirstChild("AwakeningMusic") then
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

	local Character = OriginalCharacter or Player.Character
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

	if Player.Parent and Player.Character == Character and Humanoid and Humanoid.Health > 0 then
		MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))
	end
end

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

	local State = { Ended = false }
	local Active = { State = State, Character = Character, Starting = true }
	ActiveAwakenings[Player] = Active
	local function finish()
		if State.Ended then
			return
		end
		State.Ended = true
		if ActiveAwakenings[Player] == Active then
			ActiveAwakenings[Player] = nil
		end
		if Active.DisconnectLifetime then
			Active.DisconnectLifetime()
		end
		if Active.Starting then
			AnimationService:stopAll(Character)
		end
		iFramesHandler:RemoveiFrames(Character, "All")
		EndAwakening(Player, Active.Awk0C, Active.AwkTween, nil, Character)
	end
	Active.Finish = finish
	Active.DisconnectLifetime = CharacterLifetime.Watch(Character, finish)

	AwkProgressObj.Value = 100

	local CurrentMoveset = Player:GetAttribute("Moveset")
	Character:AddTag("Awakened")
	Character:SetAttribute("Awakened", true)
	Player:SetAttribute("Awakened", true)

	iFramesHandler:AddiFrames(Character, "All")

	local UltimateName = InfoModule.Movesets[CurrentMoveset].UltimateName
	local AwakeningModule = getAwakenings()[CurrentMoveset]

	if AwakeningModule then
		playAwakeningMusic(Player, Character, UltimateName)
		local ok, err = xpcall(function()
			AwakeningModule:Activate(Player)
		end, debug.traceback)
		if not ok then
			finish()
			warn(err)
			return
		end
	else
		warn("[AwakeningService] Nenhum módulo de awakening registrado para o moveset:", CurrentMoveset)
	end

	Active.Starting = false
	if State.Ended or not Player.Parent or Player.Character ~= Character or not Character.Parent or Character.Humanoid.Health <= 0 then
		finish()
		return
	end

	MovesetHandler:AddAwakeningMoveset(Player, Player:GetAttribute("Moveset"))

	iFramesHandler:RemoveiFrames(Character, "All")

	local AwkTween = TS:Create(
		AwkProgressObj,
		TweenInfo.new(InfoModule.Movesets[Player:GetAttribute("Moveset")].UltimateTime, Enum.EasingStyle.Linear),
		{ Value = 0 }
	)

	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

	Active.AwkTween = AwkTween
	Active.Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
		if AwkProgressObj.Value <= 0 then
			finish()
		end
	end)
	if Humanoid then
		Humanoid.WalkSpeed = 25
	end

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

	Active.Finish()
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
	local Active = ActiveAwakenings[Player]
	if Active then
		Active.Finish()
	end
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

Players.PlayerRemoving:Connect(function(Player)
	local Active = ActiveAwakenings[Player]
	if Active then
		Active.Finish()
	end
	stopAwakeningMusic(Player)
end)

return AwakeningService
