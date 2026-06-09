local Players = game:GetService('Players')
local SvSt = game:GetService('ServerStorage')
local RS = game:GetService('ReplicatedStorage')
local TS = game:GetService('TweenService')
local Debris = game:GetService('Debris')


local Remotes = RS.Remotes
local SvModules = SvSt.Modules
local RpModules = RS.Modules


local ReplicateSet = Remotes.Replicate.Set
local ComunicatorSet = Remotes.Comunicator.Set


local AnimationEvents = require(RpModules.AnimationEvents)
local AnimationService = require(SvModules.AnimationService)
local StunHandler = require(SvModules.StunHandler)
local DamageService = require(SvModules.DamageHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local iFramesService = require(SvModules.iFramesService)
local NewKnockback = require(SvModules.BodymoverService)
local CollisionsHandler = require(SvModules.CollisionsModule)
local SoundsModule = require(SvModules.SoundsModule)
local StatesHandler = require(SvModules.StatesHandler)



local Assets = SvSt.Assets

local Models = Assets.Models
local WallcomboAnims = Assets.Animations.Wallcombos
local WallcomboSounds = Assets.Sounds.Wallcombos


local function treeShake(Char: Model)
	local ignoreContainer = {}
	local humanoidContainer = {}
	local partContainer = {}

	for _, part in pairs(workspace:GetPartBoundsInRadius(Char.PrimaryPart.Position, 20)) do
		if (part:GetAttribute("IsTree") or part.Name == "TreeRoot") and not table.find(ignoreContainer, part.Parent) then
			ReplicateSet:FireAllClients("shakeTree", { Tree = part.Parent, Intensity = Random.new():NextNumber(5, 10), From = Char.PrimaryPart.Position, Leaves = true })
		end

		local targetHumanoid = part.Parent:FindFirstChildOfClass("Humanoid")
		if targetHumanoid and targetHumanoid.Name ~= "FakeHumanoid" and not table.find(humanoidContainer, targetHumanoid) and targetHumanoid ~= Char.Humanoid then
			table.insert(partContainer, part.Parent)
		end
	end
end

return {
	Default = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid
		
		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
		
		
		local HitTrack, HitEvents = AnimationService:getAnimationTrack(Character, WallcomboAnims.Default.Player)
		local VicTrack = AnimationService:getAnimationTrack(EnemyCharacter, WallcomboAnims.Default.Victim)
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
		
		
		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.3, Limb = "Right Arm" })
		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.3, Limb = "Left Arm" })
		
		
		for i = 1, 6 do
			local EventName = "hit" .. tostring(i)

			table.insert(HitEvents, HitTrack:GetMarkerReachedSignal(EventName):Once(function()
				if i == 1 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)
					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 10, FadeInTime = 0, FadeOutTime = .25 })
					
				elseif i == 6 then
					if Weld then
						Weld:Destroy()
						Weld = nil
					end
					
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, true)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = (-HumRP.CFrame.LookVector * 40) + Vector3.new(0, 40, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 2, false, nil, nil)
					
					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 20, FadeInTime = 0, FadeOutTime = .25 })
				else
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)
					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 10, FadeInTime = 0, FadeOutTime = .25 })
				end
			end))
		end
		
		
		HitTrack.Stopped:Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end
			
			StunHandler:Unstun(Character, Stun)
			Character:RemoveTag('CantRotate')
			iFramesService:RemoveAlliFrames(Character)
			HumRP.Anchored = false
		end)
		
		VicTrack.Stopped:Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end
			
			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			EnemyCharacter:RemoveTag('CantRotate')
			iFramesService:RemoveAlliFrames(EnemyCharacter)
		end)
		
		
		AnimationService:playAnimation(Character, WallcomboAnims.Default.Player)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims.Default.Victim)
		
		SoundsModule:PlaySound(WallcomboSounds.Default.Sound, EnemyHumRP)
	end,
	
	["Hero Hunter"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		local HitTrack, HitEvents = AnimationService:getAnimationTrack(Character, WallcomboAnims.Default.Player)
		local VicTrack = AnimationService:getAnimationTrack(EnemyCharacter, WallcomboAnims.Default.Victim)


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.3, Limb = "Right Arm" })
		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.3, Limb = "Left Arm" })


		for i = 1, 6 do
			local EventName = "hit" .. tostring(i)

			table.insert(HitEvents, HitTrack:GetMarkerReachedSignal(EventName):Once(function()
				if i == 1 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)
					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 10, FadeInTime = 0, FadeOutTime = .25 })

				elseif i == 6 then
					if Weld then
						Weld:Destroy()
						Weld = nil
					end

					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, true)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = (-HumRP.CFrame.LookVector * 40) + Vector3.new(0, 40, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 2, false, nil, nil)

					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 20, FadeInTime = 0, FadeOutTime = .25 })
				else
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)
					ReplicateSet:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 10, FadeInTime = 0, FadeOutTime = .25 })
				end
			end))
		end


		HitTrack.Stopped:Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end

			StunHandler:Unstun(Character, Stun)
			Character:RemoveTag('CantRotate')
			iFramesService:RemoveAlliFrames(Character)
			HumRP.Anchored = false
		end)

		VicTrack.Stopped:Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end

			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			EnemyCharacter:RemoveTag('CantRotate')
			iFramesService:RemoveAlliFrames(EnemyCharacter)
		end)


		AnimationService:playAnimation(Character, WallcomboAnims.Default.Player)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims.Default.Victim)

		SoundsModule:PlaySound(WallcomboSounds.Default.Sound, EnemyHumRP)
	end,
	
	KJ = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')

		HumRP.CFrame *= CFrame.new(0, 0, 1)

		local HitTrack, HitEvn = AnimationService:getAnimationTrack(Character, WallcomboAnims.KJ.Player)
		local VicTrack = AnimationService:getAnimationTrack(EnemyCharacter, WallcomboAnims.KJ.Victim)


		HitEvn["hit1"] = HitTrack:GetMarkerReachedSignal("hit1"):Once(function()
			DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)
		end)

		HitEvn["hit2"] = HitTrack:GetMarkerReachedSignal("hit2"):Once(function()
			DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false)

			--ReplicateSet:FireAllClients('rockCircle',{ CF = Character['Right Leg'].CFrame; Radius = 2; Parts = 4; Reverse = false; flyRocks = false; SizeMult = .5; AdaptLength = false; Sound = false })
		end)

		HitEvn["hit3"] = HitTrack:GetMarkerReachedSignal("hit3"):Once(function()
			Weld:Destroy()

			task.spawn(function()
				VicTrack:Stop()
				EnemyCharacter:RemoveTag('CantRotate')

				iFramesService:RemoveAlliFrames(EnemyCharacter)

				EnemyHumanoid.AutoRotate = true
			end)

			DamageService:TakeDamage(Character, EnemyHumanoid, 16, nil, nil, false, false, true, true, true)
			ReplicateSet:FireClient(Player, 'ShakeCamera', { Preset = 'Explosion'; })
			NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = -HumRP.CFrame.RightVector * 70 })
			RagdollHandler.ragdoll(EnemyHumanoid, 2, false, nil, nil)
			
			treeShake(Character)
		end)

		HitTrack.Stopped:Once(function()
			Character:RemoveTag('CantRotate')

			iFramesService:RemoveAlliFrames(Character)

			CollisionsHandler:SetCollisionGroup(Character, 'Players')
			CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')

			Humanoid.AutoRotate = true
			HumRP.Anchored = false
		end)


		VicTrack.Stopped:Once(function()
			EnemyCharacter:RemoveTag('CantRotate')

			iFramesService:RemoveAlliFrames(EnemyCharacter)

			EnemyHumanoid.AutoRotate = true
		end)


		SoundsModule:PlaySound(WallcomboSounds.KJ.Player, Character.Torso, 1, 1)
		SoundsModule:PlaySound(WallcomboSounds.KJ.Hit, EnemyCharacter.Torso, 1, 1)


		AnimationService:playAnimation(Character, WallcomboAnims.KJ.Player)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims.KJ.Victim)

		ReplicateSet:FireAllClients('KJ Wall Combo', { char = Character, hit = EnemyCharacter })

		StunHandler:Stun(Character, HitTrack.Length, true)
		StunHandler:Stun(EnemyCharacter, VicTrack.Length, true)
	end,
	
	["Martial Artist"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld, RaycastResult: RaycastResult)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')


		local UserAnim = WallcomboAnims.Suiryu.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
		local UserEvents = {}

		for i = 1, 9 do
			local EventName = "hit" .. tostring(i)
			local Damage, Intensity
			if i == 1 or i == 2 then
				Damage = 1.5
				Intensity = 0.75

			elseif i == 9 then
				Damage = 3
				Intensity = 1.5

			else
				Damage = 0.5
				Intensity = 0.25

			end


			UserEvents[EventName] = UserTrack:GetMarkerReachedSignal(EventName):Once(function()
				DamageService:TakeDamage(Character, EnemyHumanoid, Damage, nil, nil, false, false, true, true, false, nil, nil)
				shared.fireTo(ReplicateSet, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = Intensity } })

				if i == 2 then
					ReplicateSet:FireAllClients("suiryuwallcombo", Character)
					
					treeShake(Character)
				end
			end)
		end

		UserEvents["hit10"] = UserTrack:GetMarkerReachedSignal("hit10"):Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end

			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			iFramesService:RemoveAlliFrames(EnemyCharacter)
			EnemyCharacter:RemoveTag('CantRotate')
			CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')


			DamageService:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, true, nil, nil)
			NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.RightVector * 65 + Vector3.new(0, 5, 0) })
			RagdollHandler.ragdoll(EnemyHumanoid, 2)
		end)

		UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end

			HumRP.Anchored = false
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)

			Character:RemoveTag('CantRotate')
			Humanoid.AutoRotate = true

			CollisionsHandler:SetCollisionGroup(Character, 'Players')
		end)


		AnimationService:playAnimation(Character, UserAnim)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims.Suiryu.Victim)

		SoundsModule:PlaySound(WallcomboSounds.Suiryu.User, Character.Torso)
		SoundsModule:PlaySound(WallcomboSounds.Suiryu.Victim, EnemyCharacter.Torso)
	end,
	
	["Finger Eater"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')


		local UserAnim = WallcomboAnims.Dawi.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
		local UserEvents = {}
		
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg", }
		
		
		for i = 1, 8 do
			local EventName = "hit" .. tostring(i)


			UserEvents[EventName] = UserTrack:GetMarkerReachedSignal(EventName):Once(function()
				treeShake(Character)
				
				if i == 1 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)
					
					ReplicateSet:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), amount = 4, size = 0.3, sizemulti = 0.1, start = EnemyHumRP.Position, ["end"] = HumRP.CFrame.LookVector * 25, })
					ReplicateSet:FireAllClients("Backhand", { CFrame = EnemyHumRP.CFrame, Origin = CFrame.new(EnemyHumRP.Position + HumRP.CFrame.LookVector * -5), Initial = 3.5, Size = 2.5, Time = 0.25, Down = Vector3.new(0, -1, 0), Add = 1.25 })
				elseif i == 2 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
					
					ReplicateSet:FireAllClients("Blood", { cframe = EnemyHumRP, times = 5, force = 0.6, delay = 0 })
					shared.fireTo(ReplicateSet, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2 } })
					
				elseif i == 3 or i == 4 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, nil)
					
				elseif i == 5 or i == 6 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, true, true, false, nil, nil)
					
				elseif i == 7 then
					DamageService:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
					
				elseif i == 8 then
					if Weld then
						Weld:Destroy()
						Weld = nil
					end

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag('CantRotate')
					CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')

					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.RightVector * -45 + Vector3.new(0, 15, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					DamageService:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
					
					
					ReplicateSet:FireAllClients("Backhand", { CFrame = EnemyHumRP.CFrame * CFrame.Angles(0, math.rad(90), 0) * CFrame.new(2, 0, 0), Origin = CFrame.new(EnemyHumRP.Position + HumRP.CFrame.RightVector * -5), Initial = 3.5, Size = 2.5, Time = 0.25, Down = Vector3.new(0, -1, 0), Add = 1.25 })
					ReplicateSet:FireAllClients("Blood", { cframe = EnemyHumRP, times = 8, force = 0.25, delay = 0.1 })
					shared.fireTo(ReplicateSet, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3 } })
				end
			end)
		end
		
		
		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end

			HumRP.Anchored = false
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)

			Character:RemoveTag('CantRotate')
			Humanoid.AutoRotate = true

			CollisionsHandler:SetCollisionGroup(Character, 'Players')
		end)
		
		
		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateSet:FireAllClients("armTrailEffect", { char = Character, lifeTime = 1.8, limbName = v.Name })
				end
			end
		end
		
		
		AnimationService:playAnimation(Character, UserAnim)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims.Dawi.Victim)
	end,
	
	["The Strongest Hero"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')
		
		
		if Character:HasTag("Awakened") and Character:GetAttribute("BaldAwakenPassive") then
			Character:SetAttribute("BaldAwakenPassive", nil)
			
			local UserAnim = WallcomboAnims["The Strongest Hero"].Awakened.User
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
			local UserEvents = {}
			
			
			UserEvents["hit1"] = UserTrack:GetMarkerReachedSignal("hit1"):Once(function()
				DamageService:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, nil)
			end)
			
			UserEvents["hit2"] = UserTrack:GetMarkerReachedSignal("hit2"):Once(function()
				DamageService:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)
				
				ReplicateSet:FireAllClients("seriousSneeze", { char = Character })
			end)
			
			UserEvents["hit3"] = UserTrack:GetMarkerReachedSignal("hit3"):Once(function()
				if Weld then
					Weld:Destroy()
					Weld = nil
				end

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				EnemyCharacter:RemoveTag('CantRotate')
				CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')

				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = HumRP.CFrame.LookVector * Vector3.new(500, 0, 500) + Vector3.new(0, 250, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				DamageService:TakeDamage(Character, EnemyHumanoid, 35, nil, nil, false, false, true, true, false, nil, nil)
			end)
			

			UserTrack.Stopped:Once(function()
				for _,v in UserEvents do
					v:Disconnect()
				end

				if Weld then
					Weld:Destroy()
					Weld = nil
				end

				HumRP.Anchored = false
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)

				Character:RemoveTag('CantRotate')
				Humanoid.AutoRotate = true

				CollisionsHandler:SetCollisionGroup(Character, 'Players')
			end)


			AnimationService:playAnimation(Character, UserAnim)
			AnimationService:playAnimation(EnemyCharacter, WallcomboAnims["The Strongest Hero"].Awakened.Victim)
		else
			local UserAnim = WallcomboAnims["The Strongest Hero"].User
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
			local UserEvents = {}


			UserEvents["hit1"] = UserTrack:GetMarkerReachedSignal("hit1"):Once(function()
				DamageService:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, false, nil, nil)
			end)

			UserEvents["hit2"] = UserTrack:GetMarkerReachedSignal("hit2"):Once(function()
				if Weld then
					Weld:Destroy()
					Weld = nil
				end

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				EnemyCharacter:RemoveTag('CantRotate')
				CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')
				
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = (-HumRP.CFrame.LookVector * 40) + Vector3.new(0, 40, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				DamageService:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, false, nil, nil)

				ReplicateSet:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), amount = 4, size = 0.3, sizemulti = 0.1, start = EnemyHumRP.Position, ["end"] = HumRP.CFrame.LookVector * 25, })
				shared.fireTo(ReplicateSet, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3 } })
			end)


			UserTrack.Stopped:Once(function()
				for _,v in UserEvents do
					v:Disconnect()
				end
				
				if Weld then
					Weld:Destroy()
					Weld = nil
				end

				HumRP.Anchored = false
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)

				Character:RemoveTag('CantRotate')
				Humanoid.AutoRotate = true

				CollisionsHandler:SetCollisionGroup(Character, 'Players')
			end)


			AnimationService:playAnimation(Character, UserAnim)
			AnimationService:playAnimation(EnemyCharacter, WallcomboAnims["The Strongest Hero"].Victim)
		end
	end,
	
	["Cursed Child"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')


		local UserAnim = WallcomboAnims["Cursed Child"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
		local UserEvents = {}
		
		
		UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
			DamageService:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
		end)
		
		UserEvents["big_stab"] = UserTrack:GetMarkerReachedSignal("big_stab"):Once(function()
			DamageService:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)
		end)
		
		UserEvents["stab"] = UserTrack:GetMarkerReachedSignal("stab"):Connect(function()
			DamageService:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, false, true, true, false, nil, nil)
		end)
		
		UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
			if Weld then
				Weld:Destroy()
				Weld = nil
			end
			
			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			iFramesService:RemoveAlliFrames(EnemyCharacter)
			EnemyCharacter:RemoveTag('CantRotate')
			CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')
			
			NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.RightVector * 65 + Vector3.new(0, 5, 0) })
			RagdollHandler.ragdoll(EnemyHumanoid, 2)
			DamageService:TakeDamage(Character, EnemyHumanoid, 3.6, nil, nil, false, false, true, true, true, nil, nil)
		end)
		
		
		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			if Weld then
				Weld:Destroy()
				Weld = nil
			end
			
			HumRP.Anchored = false
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			
			Character:RemoveTag('CantRotate')
			Humanoid.AutoRotate = true
			
			CollisionsHandler:SetCollisionGroup(Character, 'Players')
		end)
		
		
		AnimationService:playAnimation(Character, UserAnim)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims["Cursed Child"].Victim)
		
		
		SoundsModule:PlaySound(WallcomboSounds["Cursed Child"].Sound, Character.Torso)
	end,
	
	["Godly Highschooler"] = function(Character: Model, EnemyCharacter: Model, Weld: Weld)
		local Player = Players:GetPlayerFromCharacter(Character)
		local HumRP : BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
		local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

		CollisionsHandler:SetCollisionGroup(Character, 'GrabbedPlayers')
		CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'GrabbedPlayers')


		local UserAnim = WallcomboAnims["Godly Highschooler"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
		local UserEvents = {}
		
		
		local MarkerStage = 1
		
		
		UserEvents["dmg"] = UserTrack:GetMarkerReachedSignal("dmg"):Connect(function()
			if MarkerStage == 1 or MarkerStage == 2 or MarkerStage == 3 or MarkerStage == 4 or MarkerStage == 5 or MarkerStage == 6 or MarkerStage == 7 then
				MarkerStage += 1
				
			else
				if Weld then
					Weld:Destroy()
					Weld = nil
				end

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				EnemyCharacter:RemoveTag('CantRotate')
				CollisionsHandler:SetCollisionGroup(EnemyCharacter, 'Players')

				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = (-HumRP.CFrame.LookVector * 40) + Vector3.new(0, 40, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				DamageService:TakeDamage(Character, EnemyHumanoid, 3.6, nil, nil, false, false, true, true, true, nil, nil)
			end
		end)
		
		
		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			if Weld then
				Weld:Destroy()
				Weld = nil
			end
			
			HumRP.Anchored = false
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			
			Character:RemoveTag('CantRotate')
			Humanoid.AutoRotate = true
			
			CollisionsHandler:SetCollisionGroup(Character, 'Players')
		end)
		
		
		AnimationService:playAnimation(Character, UserAnim)
		AnimationService:playAnimation(EnemyCharacter, WallcomboAnims["Godly Highschooler"].Victim)
		
		
		SoundsModule:PlaySound(WallcomboSounds["Godly Highschooler"].Sound, Character.Torso)
	end
}