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
local ReplicatedHitboxes = require(game.ServerStorage.Modules.ReplicatedHitboxes)
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)


local Utility = shared.Utility
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = game.ServerStorage.Assets.Animations.Moves
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


		local Stun = StunHandler:Stun(Character, nil, true)
		local Hit = false
		local DashTime = 3.017
		local iFrames = { Tool.Name }

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(500000, 0, 500000)
		BodyVelocity.Name = "moveme"
		BodyVelocity:SetAttribute("End", 1)
		BodyVelocity:SetAttribute("Fallout", 0.91)
		BodyVelocity:SetAttribute("Goto", 200)
		BodyVelocity:SetAttribute("Speed", 1000)


		local SFX


		local StartupAnimation: AnimationTrack = AnimationService:getAnimationTrack(Character, MoveAnims.KJ['20-20-20 Dropkick'].Startup)
		local AnimEvents = {}

		AnimEvents['StartHitbox'] = StartupAnimation:GetMarkerReachedSignal('StartHitbox'):Once(function()
			iFramesService:AddBaseiFrames(Character)
			Character:RemoveTag("cancelHitboxes")

			local Hitbox = ReplicatedHitboxes.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(7, 7, 21)
			Hitbox.Offset = CFrame.new(0, 0, -10.5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				if Hit == true then return end

				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				if ((EnemyHumRP.Position - HumRP.Position).Magnitude * Player:GetNetworkPing()) >= 50 then return end

				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyTorso = EnemyCharacter.Torso
				local EnemyAnimator: Animator = EnemyHumanoid.Animator

				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:HasTag('Ragdolled') or Hit == true or EnemyCharacter.Humanoid.Health <= 0 then return end
				Player.AwakeningProgress.Value = 0

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, nil, false, false, 'Dropkick', 25)

				if HitInfo.Countered == true then
					SFX:Destroy() 

					return
				end
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.8, Last = nil, Instance = 45 }})

				Hitbox:Destroy()

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true)
				
				
				iFramesService:AddAlliFrames(Character)
				AnimationService:stopAll(EnemyCharacter, 0)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				HumRP.Anchored = true
				Hit = true

				AnimationService:stopAll(Character, 0)

				EnemyCharacter:AddTag('CantRotate')
				Character:AddTag('CantRotate')

				if SFX then
					SFX:Destroy()
				end

				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = false }})

				ReplicateEffects_Set:FireAllClients('20 Dropkick', { Stage = 'StopDash', Char = Character, EChar = EnemyCharacter })


				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -10) * CFrame.Angles(0, rad(180), 0), 18)


				local HitAnimTrack: AnimationTrack = AnimationService:getAnimationTrack(Character, MoveAnims.KJ['20-20-20 Dropkick'].Hit)
				local HitEvents = {}

				HitEvents['End'] = HitAnimTrack:GetMarkerReachedSignal('End'):Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					HumRP.CFrame = HumRP.CFrame * CFrame.new(0, 0.15, -174.531)
					HumRP.Anchored = false
					HumRP.AssemblyLinearVelocity = Vector3.zero
					Character.Torso.AssemblyLinearVelocity = Vector3.zero

					EnemyHumRP.CFrame = HumRP.CFrame * CFrame.new(0, 0.15, -184.531)
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
					EnemyCharacter.Torso.AssemblyLinearVelocity = Vector3.zero

					StunHandler:Unstun(EnemyCharacter, EnemyStun)


					EnemyCharacter:AddTag("NoHeadFollow")
					RagdollHandler.ragdoll(EnemyHumanoid, 2, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 400, 200, HumRP.CFrame.LookVector.Z * 400) })
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, nil, true, true, nil)

					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
				end)

				HitAnimTrack.Stopped:Once(function()
					for _,v in HitEvents do
						v:Disconnect()
					end

					iFramesService:RemoveAlliFrames(Character)

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					ReplicateEffects_Set:FireClient(Player, 'fixspeedbug')

					StunHandler:Unstun(Character, Stun)

					Humanoid.AutoRotate = true
					Character:RemoveTag('CantRotate')


					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
				end)


				AnimationService:playAnimation(Character, MoveAnims.KJ['20-20-20 Dropkick'].Hit)
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.KJ["20-20-20 Dropkick"].Victim)

				SoundsModule:PlaySound(MoveSounds.KJ["20 Dropkick"].Hit, EnemyCharacter.Torso, 1, 1)

				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
				
				StatesHandler.SkillText(Player, "20-20-20 DROPKICK [HIT]")
			end

			Hitbox:Start(DashTime, true)
		end)

		AnimEvents['SpeedLinesStart'] = StartupAnimation:GetMarkerReachedSignal('SpeedLinesStart'):Once(function()
			ReplicateEffects_Set:FireClient(Player, '20 Dropkick', { Stage = 'Dash', Char = Character, Time = DashTime, DashSpeed = 300 })

			BodyVelocity.Parent = HumRP
		end)

		AnimEvents["StartSlowdown"] = StartupAnimation:GetMarkerReachedSignal("StartSlowdown"):Once(function()
			BodyVelocity:SetAttribute("Fallout", 0.98)
			BodyVelocity:SetAttribute("Goto", nil)
		end)

		StartupAnimation.Stopped:Once(function()
			Character:AddTag("cancelHitboxes")

			for _,v in AnimEvents do
				v:Disconnect()
			end

			BodyVelocity:Destroy()

			if Hit == false then
				ReplicateEffects_Set:FireClient(Player, '20 Dropkick', { Stage = 'Destroy', Char = Character, })
				iFramesService:RemoveAlliFrames(Character)

				StunHandler:Unstun(Character, Stun)
				Character:SetAttribute("MuteMusic", false)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.KJ['20-20-20 Dropkick'].Startup)

		SFX = SoundsModule:PlaySound(MoveSounds.KJ["20 Dropkick"].Run, HumRP, 1, 1)
		ReplicateEffects_Set:FireClient(Player, '20 Dropkick', { Stage = 'Start', })
		Character:SetAttribute("MuteMusic", true)
		
		StatesHandler.SkillText(Player, "20-20-20 DROPKICK [USED]")
	end
}