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

local AnimationEvents = shared.AnimationEvents
local Utility = shared.Utility
local WeldSystem = shared.WeldSystem


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = shared.MoveAnims
local MoveSounds = shared.MoveSounds


local PlrSet = shared.PlrSet
local PlrGet = shared.PlrGet


local ReplicateEffects_Set: RemoteEvent = shared.repfire


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector



return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid


		local IC0 = HumRP.RootJoint.C0
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		HumRP.Anchored = true
		Humanoid.AutoRotate = false
		Character:AddTag('CantRotate')
		
		task.delay(1.3, function()
			PlrSet:FireClient(Player, 'HideTopbar')
		end)

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
		rayParams.FilterDescendantsInstances = { workspace.Map }
		
		local StartupAnim = MoveAnims.KJ['5 Seasons'].Startup
		local EndAnim = MoveAnims.KJ['5 Seasons'].End

		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnim)
		local EndTrack = AnimationService:getAnimationTrack(Character, EndAnim)

		local StartupEvents = AnimationEvents.new(StartupTrack)
		
		EndTrack.Stopped:Once(function()
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
			HumRP.Anchored = false
			Humanoid.AutoRotate = true
			Character:RemoveTag('CantRotate')

			Character:SetAttribute("MuteMusic", false)


			Character.Torso.RootPriority = 1
			wait()
			Character.Torso.RootPriority = 0
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnim)
		StartupEvents:Play()

		ReplicateEffects_Set:FireAllClients('Five Season Startup',{
			char = Character,
			id = 133800199666145
		})
		
		SoundsModule:PlaySound(MoveSounds.KJ["Five Seasons"].Fly, Character.Torso, 1, 1)
		
		delay(3.15, function()
			SoundsModule:PlaySound(MoveSounds.KJ["Five Seasons"].Voice, Character.Torso, 1, 1)
			
		end)
		
		delay(7.38, function()
			SoundsModule:PlaySound(MoveSounds.KJ["Five Seasons"].TP, Character.Torso, 1, 1)
			ReplicateEffects_Set:FireAllClients("tpparticle",{ Torso = Character.Torso })
			
		end)
		
		Character:SetAttribute("MuteMusic", true)
		
		task.delay(7.9, function()
			Utility('TriggerTransparency')(Character, 1)
			
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			BodyPosition.Parent = Character
			
			local orbitTime = 5
			
			ReplicateEffects_Set:FireClient(Player, 'Five Season Camera',{ char = Character, id = 133800199666145, bp = BodyPosition })
			
			local Ended = false
			local function End()
				if Ended == true then return end
				Ended = true
				
				Character:SetAttribute('FiveSeasonsTwice', nil)
				
				local HurryUpFS = Instance.new("Folder")
				HurryUpFS.Name = "HurryUPFS"
				HurryUpFS.Parent = Character

				game.Debris:AddItem(HurryUpFS,1)

				task.delay(1, function()
					HurryUpFS:Destroy()
				end)


				local CameraCF: CFrame = PlrGet:InvokeClient(Player, { Func = 'GetCF'; Object = 'Camera'; })
				local TargetPoint = workspace:Raycast(CameraCF.Position, Vector3.new(0, -1000, 0), rayParams)
				
				ReplicateEffects_Set:FireAllClients('Five Season Atk',{ char = Character, id = 133800199666145, bp = BodyPosition })
				SoundsModule:PlaySound(MoveSounds.KJ["Five Seasons"].CutsceneTP, Character.Torso, 1, 1)
				
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, EndAnim)


				HumRP.Position = Vector3.new(CameraCF.Position.X, CameraCF.Position.Y, CameraCF.Position.Z - .5)
				HumRP.Orientation = Vector3.new(0, HumRP.Orientation.Y, 0)


				task.delay(.833, function()
					Utility('TriggerTransparency')(Character, 0)
				end)

				if not TargetPoint then return end

				task.wait(7.1)

				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new(TargetPoint.Position + Vector3.new(0, 100, 0))
				Hitbox.Size = Vector3.new(1, 1, 1) * 200
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(1, 1, 1) * 200 + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if EnemyCharacter ~= Character and not iFramesService:HasiFrame(EnemyCharacter, Tool.Name) and EnemyCharacter.Humanoid.Health > 0 then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, true, true, true, nil)


						local LookVector = -CFrame.lookAt(EnemyHumRP.Position, TargetPoint.Position).LookVector

						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = Vector3.new(LookVector.X * 150, 300, LookVector.Z * 150) })
						RagdollHandler.ragdoll(EnemyHumanoid, 3, false, nil, nil)
						StartAirDetect:Fire(EnemyCharacter)
					end
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
				
				local usinganyother = Instance.new("Accessory")
				usinganyother.Name = "usinganyother"
				usinganyother.Parent = Character

				game.Debris:AddItem(usinganyother,3.46)
				
				PlrSet:FireClient(Player, 'ShowTopbar')
				
				task.wait(3.2)
				Player.AwakeningProgress.Value = 0
				PlrSet:FireClient(Player, 'ShowAwkbar')
			end


			task.delay(orbitTime, function()
				End()
			end)

			task.wait(.75)
			
			
			local UsedTwice = false
			Character:SetAttribute("FiveSeasonsTwice", true)

			local Changed = Character:GetAttributeChangedSignal("FiveSeasonsTwice"):Once(function()
				UsedTwice = true
				
				End()
			end)

			task.delay(1.5, function()
				if UsedTwice then return end
				Changed:Disconnect()
				Character:SetAttribute("FiveSeasonsTwice", nil)
			end)
		end)
		
		StatesHandler.SkillText(Player, "FIVE SEASONS [USED]")
	end
}