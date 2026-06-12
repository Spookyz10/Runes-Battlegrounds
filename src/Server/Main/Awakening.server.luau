--Services
local SvSt = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

--Assets
local Assets = SvSt.Assets

local Animations = Assets.Animations
local Sounds = Assets.Sounds

local AwkAnims = Animations.Awakenings
local AwkSounds = Sounds.Awakenings

--Modules

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

local ServicesModule = require(RS.Shared.Services)
local BodyAuras = ServicesModule:GetService("BodyAuras")

--Remotes
local RpRemotes = RS.Remotes

local AwakeningRemotes = RpRemotes.Awakening

local AwakeningSet = AwakeningRemotes.Set

local ReplicateRemotes = RpRemotes.Replicate

local ReplicateSet = ReplicateRemotes.Set

local Comms = RpRemotes.Comunicator

local CommsSet = Comms.Set

--Events
local AwakeningSvEvent = AwakeningSet.OnServerEvent

--Functions
local function EndAwakening(Player, Awk0C, AwkTween, ByPass)
	if not Player or not Player.Parent then
		return
	end

	if not ByPass then
		if workspace.Configuration.InfiniteAwk.Value == true then
			return
		end
	end

	local Character = Player.Character

	local HumRP = Character.HumanoidRootPart

	for _, v in Character:GetChildren() do
		if v.Name == "OkarunMask" then
			v:Destroy()
		end
	end

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

	local CurrentMoveset = Player:GetAttribute("Moveset")

	if CurrentMoveset == "Black" then
		BodyAuras.ClearAura(Character, "BlackAWK_Aura")
	end

	Player:SetAttribute("Awakened", nil)

	Character:RemoveTag("Awakened")
	Character:SetAttribute("Awakened", nil)
	Character:SetAttribute("AwakeningAura", false)

	task.spawn(function()
		shared.AddAppareance(Player, Character)
	end)

	MovesetHandler:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))

	AwakeningSet:FireClient(Player, "ShowAwkBar")
	AwakeningSet:FireClient(Player, "ShowHotbar")
end

local AwakeningAnimations = {

	["Martial Artist"] = function(Player)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesHandler:AddAlliFrames(Character)
		Character:AddTag("CantRotate")

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, AwkAnims.Suiryu.Start)

		ReplicateSet:FireAllClients("suiryuawakening", {
			Char = Character,
			cfr = HumRP.CFrame * CFrame.new(
				-0.0033507347106933594,
				0.000732421875,
				0.00286865234375,
				1.0000001192092896,
				-4.0216292518380214e-08,
				-0.000031771138310432434,
				4.021450550339978e-08,
				1,
				-5.632735877725281e-08,
				0.000031771138310432434,
				5.6326076247614765e-08,
				1.0000001192092896
			),
			sound = Instance.new("Sound"),
		})
		ReplicateSet:FireAllClients("PlayAwakeningMusic", {
			MusAtt = HumRP.AwakeningMusic,
			Id = AwkSounds.Suiryu.Music.SoundId,
			Volume = AwkSounds.Suiryu.Music.Volume,
		})

		task.wait(0.75)

		local OriginalTransparencies = {}
		for _, Part in Character:GetDescendants() do
			if Part:IsA("BasePart") or Part:IsA("Decal") then
				OriginalTransparencies[Part] = Part.Transparency
				Part.Transparency = 1
			end
		end

		task.wait(3.85)

		ReplicateSet:FireAllClients("suiryuawakeningaura", Character)

		for _, Part in Character:GetDescendants() do
			if Part:IsA("BasePart") or Part:IsA("Decal") then
				Part.Transparency = OriginalTransparencies[Part]
			end
		end

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, AwkAnims.Suiryu.End)

		HitboxHandler:SimpleOnce(
			HumRP,
			Vector3.new(100, 100, 100),
			CFrame.new(0, 47, 0),
			{ Character },
			nil,
			nil,
			function(EnemyCharacter)
				local EnemyHumRP = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid = EnemyCharacter.Humanoid

				if iFramesHandler:HasiFrame(EnemyCharacter, "Awakenings") then
					return
				end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 20, nil, nil, false, false, true, false, true)
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(100000, 100000, 100000),
					Velocity = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector * 50
						+ Vector3.new(0, 25, 0),
				})
			end
		)

		task.wait(1.4)

		StunHandler:Unstun(Character, Stun)
		iFramesHandler:RemoveAlliFrames(Character)
		Character:RemoveTag("CantRotate")
	end,

	["The Strongest Hero"] = function(Player)
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumRP = Character:FindFirstChild("HumanoidRootPart")

		if not Humanoid or not HumRP then
			return
		end
		local Ended = false

		iFramesHandler:AddAlliFrames(Character)
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local UserAnimation = AwkAnims["The Strongest Hero"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}

		UserEvents["start"] = UserTrack:GetMarkerReachedSignal("start"):Once(function()
			ReplicateSet:FireAllClients("baldAwakening", { Char = Character })
			ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 5 })

			Character:SetAttribute("BaldAwakenPassive", true)
		end)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			iFramesHandler:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
			Ended = true
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		repeat
			task.wait()
		until Ended == true
	end,

	["Hero Hunter"] = function(Player)
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumRP = Character:FindFirstChild("HumanoidRootPart")

		if not Humanoid or not HumRP then
			return
		end
		local Ended = false

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesHandler:AddAlliFrames(Character)

		local UserAnimation = AwkAnims["Hero Hunter"].User
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local function DistanceShake()
			if Player:DistanceFromCharacter(HumRP.Position) > 200 then
				return nil
			end

			return ReplicateSet:FireAllClients("ShakeCamera", { Intensity = 14 })
		end

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slam"):Once(function()
				DistanceShake()

				ReplicateSet:FireAllClients(
					"BigSlam",
					{ Seed = math.random(1, 2000000000), CFrame = HumRP.CFrame, Hunter = true }
				)

				HitboxHandler:SimpleOnce(
					HumRP,
					Vector3.new(200, 200, 200),
					CFrame.new(0, 0, 0),
					{ Character },
					nil,
					nil,
					function(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter.Humanoid
						local EnemyHumRP = EnemyCharacter.HumanoidRootPart

						if iFramesHandler:HasiFrame(EnemyCharacter, "Awakenings") then
							return
						end

						local damageMultiplier =
							math.clamp(1 + (200 - (HumRP.Position - EnemyHumRP.Position).Magnitude) / 200, 0.5, 2)
						local DamageUlt = 6 * damageMultiplier

						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							DamageUlt,
							nil,
							nil,
							false,
							false,
							false,
							false,
							true,
							nil,
							nil
						)
						RagdollHandler.ragdoll(EnemyHumanoid, 3)
						NewKnockback:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(1, 1, 1) * 40000,
							Velocity = EnemyHumRP.CFrame.UpVector * math.random(100, 150),
							Time = 0.2,
						})
					end
				)
			end)
		)

		UserTrack.Stopped:Once(function()
			Character:RemoveTag("CantRotate")
			iFramesHandler:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
			Ended = true
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		ReplicateSet:FireAllClients("HunterAwakening", { Char = Character })
		ReplicateSet:FireAllClients(
			"PlayAwakeningMusic",
			{ MusAtt = HumRP.AwakeningMusic, Id = AwkSounds["Hero Hunter"].Music.SoundId }
		)

		repeat
			task.wait()
		until Ended == true
	end,
}

--Connections
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

		local Awk0C: RBXScriptConnection
		Awk0C = AwkProgressObj:GetPropertyChangedSignal("Value"):Connect(function()
			if Ended == false and AwkProgressObj.Value <= 0 then
				Ended = true
				Awk0C:Disconnect()

				EndAwakening(Player, Awk0C, AwkTween, nil)
			end
		end)

		if not workspace.Configuration.InfiniteAwk.Value then
			AwkTween.Completed:Once(function()
				if Ended == false then
					Ended = true

					EndAwakening(Player, Awk0C, AwkTween, nil)
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
