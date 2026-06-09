local ServerStorage = game:GetService('ServerStorage') 


local StunHandler = require(game.ServerStorage.Modules.StunHandler)
local HitboxHandler = require(game.ServerStorage.Modules.HitboxHandler)
local DamageHandler = require(game.ServerStorage.Modules.DamageHandler)
local RagdollHandler = require(game.ServerStorage.Modules.RagdollHandler)
local NewKnockback = require(game.ServerStorage.Modules.BodymoverService)
local AnimationService = require(game.ServerStorage.Modules.AnimationService)
local iFramesService = require(game.ServerStorage.Modules.iFramesService)
local WeaponsHandler = require(game.ServerStorage.Modules.WeaponsHandler)
local CollisionsModule = require(game.ServerStorage.Modules.CollisionsModule)
local SoundsModule = require(game.ServerStorage.Modules.SoundsModule)
local KnockbackModule = require(game.ServerStorage.Modules.KnockbackModule)
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)


local Utility = shared.Utility
local WeldSystem = shared.WeldSystem


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = shared.MoveAnims
local MoveSounds = shared.MoveSounds


local PlrSet = shared.PlrSet
local PlrGet = shared.PlrGet


local ReplicateEffects_Set = shared.repfire


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector



return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid
		local Animator: Animator = Humanoid.Animator

		HumRP.Anchored = false
		Humanoid.AutoRotate = false
		Player.AwakeningProgress.Value = 0
		PlrSet:FireClient(Player, 'ShowAwkbar')
		Character:SetAttribute("MuteMusic", true)

		Character:AddTag('CantRotate')

		ReplicateEffects_Set:FireAllClients("stoicBomb", { Char = Character, Seed = 1986794466 })

		local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, MoveAnims.KJ["Stoic Bomb"].Player)

		AnimEvents["ChargingSound"] = AnimTrack:GetMarkerReachedSignal("ChargingSound"):Once(function()

			SoundsModule:PlaySound(MoveSounds.KJ["Stoic Bomb"].StoicCharge, Character.Torso, 1, 1)
		end)

		AnimEvents["Voiceline"] = AnimTrack:GetMarkerReachedSignal("Voiceline"):Once(function()

			SoundsModule:PlaySound(MoveSounds.KJ["Stoic Bomb"].StoicVoiceline, Character.Torso, 1, 1)
		end)


		AnimEvents["FinalBoarExplosion"] = AnimTrack:GetMarkerReachedSignal("FinalBoarExplosion"):Once(function()

			SoundsModule:PlaySound(MoveSounds.KJ["Stoic Bomb"].StoicExploded, Character.Torso, 1, 1)
		end)

		AnimEvents["HitboxExplosion?"] = AnimTrack:GetMarkerReachedSignal("HitboxExplosion?"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Method = 'Radius'
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = 100
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * 100 + Vector3.new(0, 25, 0) }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if EnemyCharacter ~= Character and not iFramesService:HasiFrame(EnemyCharacter, Tool.Name) and EnemyCharacter.Humanoid.Health > 0 then
					local Dmg = 100

					if (EnemyHumRP.Position - HumRP.Position).Magnitude <= 15 then
						Dmg = Dmg
					elseif (EnemyHumRP.Position - HumRP.Position).Magnitude >= 35 then
						Dmg = Dmg / 1.1
					elseif (EnemyHumRP.Position - HumRP.Position).Magnitude >= 50 then
						Dmg = Dmg / 1.3
					elseif (EnemyHumRP.Position - HumRP.Position).Magnitude >= 60 then
						Dmg = Dmg / 1.35
					elseif (EnemyHumRP.Position - HumRP.Position).Magnitude >= 70 then
						Dmg = Dmg / 1.4
					end
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, Dmg, nil, nil, false, false, true, true, true, nil)


					local LookVector = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector

					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = Vector3.new(LookVector.X * 150, 300, LookVector.Z * 150) })
					RagdollHandler.ragdoll(EnemyHumanoid, 3, false, true, Character)
					StartAirDetect:Fire(EnemyCharacter)
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()
			
			local ignoreContainer = {}
			local humanoidContainer = {}
			local partContainer = {}

			for _, part in pairs(workspace:GetPartBoundsInRadius(Character.PrimaryPart.Position, 250)) do
				if (part:GetAttribute("IsTree") or part.Name == "TreeRoot") and not table.find(ignoreContainer, part.Parent) then
					ReplicateEffects_Set:FireAllClients("shakeTree", { Tree = part.Parent, Intensity = Random.new():NextNumber(5, 10), From = Character.PrimaryPart.Position })
				end

				local targetHumanoid = part.Parent:FindFirstChildOfClass("Humanoid")
				if targetHumanoid and targetHumanoid.Name ~= "FakeHumanoid" and not table.find(humanoidContainer, targetHumanoid) and targetHumanoid ~= Humanoid then
					table.insert(partContainer, part.Parent)
				end
			end
		end)

		AnimTrack.Stopped:Once(function()
			for _,v in AnimEvents do
				v:Disconnect()
			end

			Humanoid.AutoRotate = true
			Character:RemoveTag('CantRotate')

			iFramesService:RemoveAlliFrames(Character)

			Character:SetAttribute("MuteMusic", false)

			Character.Torso.RootPriority = 1
			wait()
			Character.Torso.RootPriority = 0
		end)

		SoundsModule:PlaySound(MoveSounds.KJ["Stoic Bomb"].StoicTP, Character.Torso, 1, 1)
		SoundsModule:PlaySound(MoveSounds.KJ["Stoic Bomb"].StoicGoDown, Character.Torso, 1, 1)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.KJ["Stoic Bomb"].Player)

		iFramesService:AddAlliFrames(Character)
		StunHandler:Stun(Character, AnimTrack.Length, true)

		local usinganyother = Instance.new("Accessory")
		usinganyother.Name = "usinganyother"
		usinganyother.Parent = Character
		game.Debris:AddItem(usinganyother,5.46)
		
		StatesHandler.SkillText(Player, "STOIC BOMB [USED]")
	end
}