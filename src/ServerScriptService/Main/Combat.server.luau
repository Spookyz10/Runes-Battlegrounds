--Services
local TS = game:GetService('TweenService')
local RS = game:GetService('ReplicatedStorage')
local SvSt = game:GetService('ServerStorage')
local Players = game:GetService('Players')
local Debris = game:GetService('Debris')



--Remotes
local Remotes = RS.Remotes

local CombatRemotes = Remotes.Combat

local CombatGet = CombatRemotes.Get
local CombatSet = CombatRemotes.Set

local CombatSetEvent = CombatSet.OnServerEvent


local ReplicateRemotes = Remotes.Replicate

local ReplicateGet = ReplicateRemotes.Get
local ReplicateSet = ReplicateRemotes.Set


local CommsFolder = Remotes.Comunicator

local Comunicator = CommsFolder.Set
local Getter = CommsFolder.Get



--Server Modules
local SvModules = SvSt.Modules

local DamageHandler = require(SvModules.DamageHandler)
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local StunHandler = require(SvModules.StunHandler)
local AnimationService = require(SvModules.AnimationService)
local NewKnockback = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)
local StatesHandler = require(SvModules.StatesHandler)
local WeaponsHandler = require(SvModules.WeaponsHandler)
local KnockbackModule = require(SvModules.KnockbackModule)
local ReplicatedHitboxes = require(SvModules.ReplicatedHitboxes)
local SoundsModule = require(SvModules.SoundsModule)



--Replicated Modules
local InfoModule = require(RS.Info)



--Assets
local Assets = SvSt.Assets

local Animations = Assets.Animations
local CombatAnims = Animations.Combat


local Sounds = Assets.Sounds
local CombatSounds = Sounds.Combat



--Variables
local LastPunch = {}
local MaxCombo = 4
local M1Damage = {
	[1] = 2,
	[2] = 2,
	[3] = 2,
	[4] = 4
}



--Functions
function ChangeCombo(Char: Model)
	if not Char:GetAttribute('Combo') then
		Char:SetAttribute('Combo', 0)
	end


	if Char:GetAttribute('TrueComboCount') then
		Char:SetAttribute('Combo', Char:GetAttribute('TrueComboCount'))
		Char:SetAttribute('TrueComboCount', nil)
	else
		if LastPunch[Char] then
			if (time() - LastPunch[Char]) >= 1.5 then
				Char:SetAttribute('Combo', 1)
			else
				if Char:GetAttribute('Combo') >= MaxCombo then
					Char:SetAttribute('Combo', 1)
				else
					Char:SetAttribute('Combo', Char:GetAttribute('Combo') + 1)
				end
			end
		else
			Char:SetAttribute('Combo', Char:GetAttribute('Combo') + 1)
		end
	end

	LastPunch[Char] = time()

	return Char:GetAttribute('Combo')
end

function GetPunchAnim(Char: Model, Uppercut, Downslam)
	local CurrentCombo = Char:GetAttribute('Combo')


	local PunchesFolder = CombatAnims.Punches.Default
	local Player = Players:GetPlayerFromCharacter(Char)
	if Player and CombatAnims.Punches:FindFirstChild(Player:GetAttribute("Moveset")) then
		PunchesFolder = CombatAnims.Punches[Player:GetAttribute("Moveset")]
	end
	
	local Hum: Humanoid = Char.Humanoid
	local Animator: Animator = Hum.Animator
	local Animation = nil
	
	if CurrentCombo < MaxCombo then
		Animation = PunchesFolder[tostring(CurrentCombo)]
	else
		if not Uppercut and not Downslam then
			Animation = PunchesFolder[tostring(MaxCombo)]
		else
			if Downslam then
				Animation = CombatAnims.Punches.Downslam
			else
				if Uppercut then
					if Char:HasTag('HasSword') then
						Animation = CombatAnims.Punches.SwordUppercut
					else
						Animation = CombatAnims.Punches.Uppercut
					end
				end
			end
		end
	end
	
	return Animation, PunchesFolder[tostring(CurrentCombo - 1 > 0 and CurrentCombo - 1 or 4)]
end

local function M1(Player: Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doPunch") ~= true or Character:GetAttribute("ThrowingPart") == true then return end
	local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then return end
	local Humanoid: Humanoid = Character.Humanoid
	

	if Character:FindFirstChild("ThrowablePart") and Character.ThrowablePart:FindFirstChild("Weld") then
		if Character:GetAttribute("GrabbingThrowable") then return end
		
		
		local ThrowablePart: MeshPart = Character.ThrowablePart
		local ThrowableWeld: Weld = ThrowablePart.Weld

		ThrowablePart:SetAttribute("BeingThrowed", true)
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local ThrowAnim = AnimationService:getAnimationTrack(Character, Animations.Throwables.Throw)
		local ThrowAnimEvents = {}

		ThrowAnimEvents["throw"] = ThrowAnim:GetMarkerReachedSignal("throw"):Once(function()
			if ThrowableWeld then
				ThrowableWeld:Destroy()
				ThrowableWeld = nil
			end


			ThrowablePart.CanCollide = true
			ThrowablePart:SetAttribute("BeingThrowed", nil)
			ThrowablePart:SetNetworkOwner(Player)
			ReplicateSet:FireAllClients("trashcanFloorHit", { ThrowablePart, Player })

			
			local Hitbox = ReplicatedHitboxes.new(Player)
			Hitbox.Instance = ThrowablePart
			Hitbox.Size = ThrowablePart.Size * 2.25
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if ThrowablePart.AssemblyLinearVelocity.Magnitude <= 10 or EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag('Ragdolled') or iFramesService:HasiFrame(EnemyCharacter, 'Throwables') then return end


				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 16, nil, nil, false, true, false, true)
				if HitInfo.Countered == true then return end

				RagdollHandler.ragdoll(EnemyHumanoid, 2, false)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 0, 100000), Velocity = ThrowablePart.AssemblyLinearVelocity.Unit * 50 })
				SoundsModule:PlaySound(Sounds.Other.TrashDmg, EnemyHumRP)
			end
			
			Hitbox:Start(5, true)
			
			
			task.delay(5, function()
				ThrowablePart:Destroy()
			end)
			
			ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 3 })
		end)

		ThrowAnim.Stopped:Once(function()
			for _,v in ThrowAnimEvents do
				v:Disconnect()
			end

			StunHandler:Unstun(Character, Stun)

			ThrowablePart:SetAttribute("BeingThrowed", nil)
			Character:SetAttribute("ThrowingPart", nil)

			if not ThrowablePart.CanCollide then
				ThrowablePart.CanCollide = true
				Debris:AddItem(ThrowablePart, 5)
			end

			if ThrowableWeld then
				ThrowableWeld:Destroy()
				ThrowableWeld = nil
			end
			
			ThrowablePart.Parent = workspace.Thrown
		end)


		Character:SetAttribute("ThrowingPart", true)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, Animations.Throwables.Throw)


		if ThrowableWeld then
			TS:Create(ThrowableWeld, TweenInfo.new(0.533, Enum.EasingStyle.Linear), { C0 = CFrame.new(0, 2, 2) * CFrame.Angles(math.rad(140), 0, 0) }):Play()

			task.delay(0.533, function()
				TS:Create(ThrowableWeld, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { C0 = CFrame.new(0, 3.25, -1.25) * CFrame.Angles(math.rad(70), 0, 0) }):Play()
			end)
		end

	else
		local canGrab = not Character:HasTag("CantThrowable")

		local liveOverlapParams = OverlapParams.new()
		liveOverlapParams.FilterType = Enum.RaycastFilterType.Include
		liveOverlapParams.FilterDescendantsInstances = { workspace.Live }

		local hitPartsCheck = workspace:GetPartBoundsInBox(HumRP.CFrame * CFrame.new(0, 0, -3.5), Vector3.new(1, 1, 1) * 7, liveOverlapParams)
		if #hitPartsCheck > 0 then
			for _, Part: Part in hitPartsCheck do
				if Part and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
					local EnemyCharacter: Model = Part.Parent
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if EnemyCharacter == Character or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") or iFramesService:HasiFrame(EnemyCharacter, 'M1') then
						continue
					end

					canGrab = false

					break
				end
			end
		end

		if canGrab then
			local ThrowablePart: Part

			local hitparts = workspace:GetPartBoundsInBox(HumRP.CFrame * CFrame.new(0, 0, -3.5), Vector3.new(1, 1, 1) * 7)
			if #hitparts > 0 then
				for _, Part: Part in hitparts do
					if Part and Part.Parent and Part:IsDescendantOf(workspace) and Part:HasTag('Throwable') then
						ThrowablePart = Part:Clone()
						ThrowablePart.Name = "ThrowablePart"
						ThrowablePart.CanCollide = false
						ThrowablePart.CanQuery = false
						ThrowablePart:RemoveTag('Throwable')


						local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
						local ThrowableWeld
						
						ThrowablePart.Parent = Character


						local PickupAnim = AnimationService:getAnimationTrack(Character, Animations.Throwables.Pickup)
						local PickupAnimEvents = {}

						PickupAnimEvents["grab"] = PickupAnim:GetMarkerReachedSignal("grab"):Once(function()
							ThrowablePart.Anchored = false
							ThrowablePart.Massless = true

							ThrowableWeld = Instance.new("Weld")
							ThrowableWeld.Part0 = HumRP
							ThrowableWeld.Part1 = ThrowablePart
							ThrowableWeld.Name = "Weld"
							ThrowableWeld.C0 = CFrame.new(0, -1, -3) * CFrame.Angles(math.rad(-30), 0, 0)
							ThrowableWeld.C1 = CFrame.new(0, 0.5, 0)
							ThrowableWeld.Parent = ThrowablePart


							SoundsModule:PlaySound(Sounds.Other.TrashGrab, ThrowablePart)
						end)

						PickupAnimEvents["lift"] = PickupAnim:GetMarkerReachedSignal("lift"):Once(function()
							if ThrowableWeld then
								TS:Create(ThrowableWeld, TweenInfo.new(0.217/2, Enum.EasingStyle.Linear), { C0 = CFrame.new(0, 3.5, 0) * CFrame.Angles(math.rad(90), 0, 0), C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0) }):Play()
							end
						end)

						PickupAnim.Stopped:Once(function()
							task.delay(0.5, function()
								Character:SetAttribute("GrabbingThrowable", nil)
							end)
							
							for _,v in PickupAnimEvents do
								v:Disconnect()
							end

							StunHandler:Unstun(Character, Stun)
							
							if Character:HasTag("Stunned") then
								ThrowablePart.CanCollide = true
								Debris:AddItem(ThrowablePart, 5)
								
								if ThrowableWeld then
									ThrowableWeld:Destroy()
								end

								return
							end

							Stun = StunHandler:Stun(Character, nil, true, 16, 0, true, true)


							local IdleAnimation = Animations.Throwables.Idle
							local IdleTrack = AnimationService:getAnimationTrack(Character, IdleAnimation)

							IdleTrack.Stopped:Once(function()
								Stun:SetAttribute("WalkSpeed", 0)
								StunHandler:Unstun(Character, Stun)


								if Character:GetAttribute("ThrowingPart") == true then return end
								
								ThrowableWeld:Destroy()
								ThrowablePart.CanCollide = true
								Debris:AddItem(ThrowablePart, 5)
							end)

							AnimationService:playAnimation(Character, IdleAnimation)
						end)

						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, Animations.Throwables.Pickup, 2)
						
						Character:SetAttribute("GrabbingThrowable", true)


						Part.Transparency = 1
						Part:RemoveTag("Throwable")
						Part.CanCollide = false
						Part.CanQuery = false

						task.delay(30, function()
							Part.Transparency = 0
							Part:AddTag("Throwable")
							Part.CanCollide = true
							Part.CanQuery = true
						end)


						return
					end
				end
			end
		end
	end

	if (Character:GetAttribute("NoAttack") or Character:HasTag('CantPunch') or Character:HasTag('Stunned')) and not (Character:HasTag("PunchCDS") and Character:HasTag('ThrowableGrabbed')) then
		task.spawn(function()
			task.wait(0.1)
			
			M1(Player)
		end)
		
		return
	elseif Character:HasTag('PunchCDS') or Character:HasTag('ThrowableGrabbed') then
		return
	end
	
	for _, Anim in RS.Resources.Emotes.Animations:GetDescendants() do
		if Anim:IsA("Animation") then
			AnimationService:stopAnimation(Character, Anim)
		end
	end
	
	
	Character:AddTag('Punching')
	Character:AddTag('PunchCDS')


	local PerfectBlock = Character:HasTag('PerfectBlock')
	Character:RemoveTag('PerfectBlock')
	local Hit = false
	local VelVector: Vector3, KnockData: { any }
	local CurrentCombo = ChangeCombo(Character)
	local CurrentType


	Character:SetAttribute('DefaultJumpPower', 0)
	Humanoid.JumpPower = 0
	
	local Params = {}
	Params.Downslam = Humanoid:GetState() == Enum.HumanoidStateType.Freefall
	Params.Uppercut = Humanoid.Jump
	
	
	Character:SetAttribute('DefaultRunSpeed', 16)
	Character:SetAttribute('DefaultWalkSpeed', 16)
	
	Humanoid.WalkSpeed = 16
	
	local VoxelParameters = nil
	local Size, Offset = Vector3.new(7, 5, 7), CFrame.new(0, 0, -3.5)
	
	if CurrentCombo >= MaxCombo then
		if Params.Downslam then
			CurrentType = 'Downslam'
			Size, Offset = Vector3.new(7, 14, 7), CFrame.new(0, -7, -3.5)
			VoxelParameters = { Velocity = HumRP.CFrame.UpVector, Multiplier = { 15, 50 }, Size = Size, CFrame = HumRP.CFrame * Offset }

		elseif Params.Uppercut then
			CurrentType = 'Uppercut'
			Size, Offset = Vector3.new(7, 14, 7), CFrame.new(0, -7, -3.5)
			VoxelParameters = { Velocity = HumRP.CFrame.UpVector, Multiplier = { 15, 50 }, Size = Size, CFrame = HumRP.CFrame * Offset }

		else
			CurrentType = tostring(CurrentCombo)
			VoxelParameters = { Velocity = HumRP.CFrame.LookVector, Multiplier = { 15, 50 }, Size = Size, CFrame = HumRP.CFrame * Offset }

		end
	else
		CurrentType = tostring(CurrentCombo)
	end

	Character:SetAttribute('LastM1Type', CurrentType)
	Character:SetAttribute('LastM1Time', tick())
	Character:SetAttribute("LastM1Position", HumRP.Position)


	local PunchAnim: Animation, PreviousAnimation: Animation = GetPunchAnim(Character, Params.Uppercut, Params.Downslam)
	local PunchAnimTrack: AnimationTrack, PunchEvents: RBXScriptConnection = AnimationService:getAnimationTrack(Character, PunchAnim)
	
	table.insert(PunchEvents, PunchAnimTrack:GetMarkerReachedSignal('swing'):Once(function()
		if Player:GetAttribute("Moveset") == "Cursed Child" then
			if CurrentType == "Uppercut" then
				ReplicateSet:FireAllClients("SpecialCombat", { Target = Character, Moveset = "Cursed Child", Stage = "CustomSpecialSwings", Combo = CurrentCombo, Type = "Up" })
			else
				if CurrentType ~= "Downslam" then
					ReplicateSet:FireAllClients("SpecialCombat", { Target = Character, Moveset = "Cursed Child", Stage = "CustomSwings", Combo = CurrentCombo })
				end
			end
			
		elseif Player:GetAttribute("Moveset") == "Hero Hunter" or Player:GetAttribute("Moveset") == "Monster Form" then
			local Effect = Player:GetAttribute("Moveset") == "Monster Form" and "RedPalm" or "waterpalm"
			
			if CurrentCombo == 1 then
				ReplicateSet:FireAllClients(Effect, { Char = Character, Time = 0.23, Limb = "Right Arm" })
				
			elseif CurrentCombo == 2 then
				ReplicateSet:FireAllClients(Effect, { Char = Character, Time = 0.20, Limb = "Left Arm" })
				
			end
		end
	end))
	
	local HitCount = 0
	table.insert(PunchEvents, PunchAnimTrack:GetMarkerReachedSignal('hit'):Connect(function()
		HitCount += 1
		
		HitboxHandler:SimpleOnce(HumRP, Size, Offset, { Character }, nil, nil, function(EnemyCharacter: Model)
			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyAnimator: Animator = EnemyHumanoid.Animator
			
			if EnemyCharacter == Character or (CurrentType ~= 'Downslam' and (EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag('Ragdolled'))) or iFramesService:HasiFrame(EnemyCharacter, 'M1') then return end
			
			local Blockable = true
			if CurrentType == 'Downslam' then
				Blockable = false
			end

			local Dmg = M1Damage[CurrentCombo] or 4
			if PerfectBlock == true then
				Dmg *= 2
			end

			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, Dmg, 1, Assets.Animations.Combat.Hits[tostring(CurrentCombo)], Blockable, true, false, true, true, 'M1')
			if HitInfo.Countered == true then return end


			if HitInfo.Blocked == true then
				local SFX: Sound
				if EnemyCharacter:HasTag('PerfectBlock') == true then
					SoundsModule:PlaySound(CombatSounds.Hits.PerfectBlocked, EnemyHumRP)
				else
					SoundsModule:PlaySound(CombatSounds.Blocking.Hits:GetChildren()[math.random(1, #CombatSounds.Blocking.Hits:GetChildren())], EnemyHumRP)
				end
			else
				Hit = true
				
				if Character:GetAttribute("MEAmplify") then
					if CurrentType ~= "Uppercut" and CurrentType ~= "Downslam" then
						ReplicateSet:FireAllClients("MeleeEffectAmplify", { Char = Character, EChar = EnemyCharacter })

						shared.fireTo(ReplicateSet, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1, Last = nil } })
					end
				end
				
				if Player:GetAttribute("Moveset") == "The Dark Lord" then
					if CurrentType ~= "Uppercut" and CurrentType ~= "Downslam" then
						if CurrentCombo == 1 or CurrentCombo == 2 then
							ReplicateSet:FireAllClients("DarkLordCombat", { Action = "Slash", Char = Character, EChar = EnemyCharacter })
							
						elseif CurrentCombo == 3 or CurrentCombo == 4 then
							ReplicateSet:FireAllClients("DarkLordCombat", { Action = "Punch", Char = Character, EChar = EnemyCharacter })
							
						end
					end
					
				elseif Player:GetAttribute("Moveset") == "Frozen Warrior" then
					ReplicateSet:FireAllClients("frozenm1", { Char = Character, Stage = "Hit", EChar = EnemyCharacter })
					
				elseif Player:GetAttribute("Moveset") == "Cursed Child" then
					if CurrentType == "Uppercut" then
						ReplicateSet:FireAllClients("SpecialCombat", { Target = EnemyCharacter, Moveset = "Cursed Child", Stage = "CustomSpecialHits", Combo = CurrentCombo, Type = "Up" })
					else
						if CurrentType ~= "Downslam" then
							ReplicateSet:FireAllClients("SpecialCombat", { Target = EnemyCharacter, Moveset = "Cursed Child", Stage = "CustomHits", Combo = CurrentCombo })
						end
						
					end
				end

				Character:SetAttribute('LastM1Hit', EnemyCharacter.Name)

				local HitsFolder = CombatSounds.Hits:FindFirstChild(Player:GetAttribute("Moveset")) or CombatSounds.Hits.Default

				if CurrentType == "Uppercut" then
					SoundsModule:PlaySound(Sounds.Combat.Hits.Uppercut, EnemyHumRP)
					SoundsModule:PlaySound(Sounds.Combat.Hits.UppercutExtra, EnemyHumRP)
					
				elseif CurrentType == "Downslam" then
					SoundsModule:PlaySound(Sounds.Combat.Hits.Downslam, EnemyHumRP)
					
				else
					SoundsModule:PlaySound(HitsFolder[tostring(CurrentCombo)], EnemyHumRP)
				end

				if PerfectBlock == true then
					ReplicateSet:FireAllClients('PerfectHit', { MainPart = EnemyHumRP; })
					
					SoundsModule:PlaySound(CombatSounds.Hits.PerfectHit, EnemyHumRP)
				end


				if CurrentCombo >= MaxCombo then
					local FirstProps = { Size = Vector3.new(.6, .6, .6), Transparency = 0 }
					local FinalProps = { Size = Vector3.new(12, .6, 12), Transparency = 1 }
					local TN_Info = { Time = .25, Style = 'Quad', Direction = 'Out' }
					local checkAir = true
					local AddRagdoll = true

					if CurrentType == 'Downslam' then
						checkAir = false
						ReplicateSet:FireAllClients('Ring',{ FirstProps = FirstProps, CF = EnemyHumRP.CFrame, TN_Info = TN_Info, FinalProps = FinalProps } )
						ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 2 })

						local MovesetName = Player:GetAttribute("Moveset")
						
						ReplicateSet:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
						
						EnemyHumRP.CFrame *= CFrame.Angles(math.pi/2, 0, 0)

						if HitInfo.Finisher == true then
							local Stun = StunHandler:Stun(Character, nil, true)
							Humanoid.AutoRotate = false
							iFramesService:AddAlliFrames(Character)
							Character:AddTag('CantRotate')
							
							task.delay(.084, function()
								local Unstunned = false
								
								
								local function FinisherHit()
									local KnockbackHitbox = HitboxHandler.new()
									KnockbackHitbox.Instance = HumRP.CFrame
									KnockbackHitbox.Size = Vector3.new(1, 1, 1) * 14
									KnockbackHitbox.onTouch = function(EChar)
										if EChar == Character or iFramesService:HasiFrame(EChar, 'M1') then return end

										NewKnockback:Knockback(EChar, { KnockbackType = 'Velocity'; MaxForce = Vector3.new(1, 1, 1) * 40000; Velocity = Vector3.new(0, 100, 0) })
										RagdollHandler.ragdoll(EChar.Humanoid, 2, false, nil, nil)
									end

									KnockbackHitbox:Once()
									KnockbackHitbox:Destroy()


									ReplicateSet:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 9,nosound = false, size = 1.4 })
									ReplicateSet:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 6, nosound = true, size = 0.3 })

									ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 8 })


									Unstunned = true

									Humanoid.AutoRotate = true
									iFramesService:RemoveAlliFrames(Character)
									StunHandler:Unstun(Character, Stun)
									Character:RemoveTag('CantRotate')
								end
								
								
								if MovesetName == "The Dark Lord" then
									local FinisherAnim = CombatAnims.Punches.DownslamFinishers.Special["The Dark Lord"].User
									local FinisherVictimAnim = CombatAnims.Punches.DownslamFinishers.Special["The Dark Lord"].Victim
									
									local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnim)
									local FinisherVictimTrack, FinisherEvents = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnim)
									
									
									if EnemyCharacter:HasTag("Ragdolled") then
										RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
									end
									
									
									local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true)
									EnemyHumanoid.AutoRotate = false
									iFramesService:AddAlliFrames(EnemyCharacter)
									EnemyCharacter:AddTag('CantRotate')
									
									
									local Weld
									
									
									table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("Grab"):Once(function()
										Weld = require(RS.Modules.WeldSystem).new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
										Weld:Start(nil, EnemyPlayer or Player)
									end))
									
									table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("Slam"):Once(function()
										FinisherHit()
										
										if Weld then
											pcall(function()
												Weld:Stop()
											end)
											Weld = nil
										end
										
										EnemyHumanoid.AutoRotate = true
										iFramesService:RemoveAlliFrames(EnemyCharacter)
										StunHandler:Unstun(EnemyCharacter, EnemyStun)
										EnemyCharacter:RemoveTag('CantRotate')
										
										RagdollHandler.ragdoll(EnemyHumanoid, 2)
									end))
									
									
									FinisherVictimTrack.Stopped:Once(function()
										if Weld then
											pcall(function()
												Weld:Stop()
											end)
											Weld = nil
										end
										
										EnemyHumanoid.AutoRotate = true
										iFramesService:RemoveAlliFrames(EnemyCharacter)
										StunHandler:Unstun(EnemyCharacter, EnemyStun)
										EnemyCharacter:RemoveTag('CantRotate')
									end)
									
									FinisherTrack.Stopped:Once(function()
										if Weld then
											pcall(function()
												Weld:Stop()
											end)
											Weld = nil
										end

										if not Unstunned then
											Humanoid.AutoRotate = true
											iFramesService:RemoveAlliFrames(Character)
											StunHandler:Unstun(Character, Stun)
											Character:RemoveTag('CantRotate')
										end
									end)


									AnimationService:stopAll(EnemyCharacter)
									AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnim)
									
									AnimationService:stopAll(Character)
									AnimationService:playAnimation(Character, FinisherAnim)
									
									ReplicateSet:FireAllClients("DarkLordCombat", { Action = "DownslamFinisher", Char = Character, EChar = EnemyCharacter })
								else
									local FinisherAnim = CombatAnims.Punches.DownslamFinishers['Variation'..tostring(math.random(1, 4))]
									local FinisherTrack, FinisherEvents = AnimationService:getAnimationTrack(Character, FinisherAnim)

									table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("hit"):Once(function()
										FinisherHit()
									end))

									FinisherTrack.Stopped:Once(function()
										if not Unstunned then
											Humanoid.AutoRotate = true
											iFramesService:RemoveAlliFrames(Character)
											StunHandler:Unstun(Character, Stun)
											Character:RemoveTag('CantRotate')
										end
									end)


									AnimationService:stopAll(Character)
									AnimationService:playAnimation(Character, FinisherAnim, 1.25)
								end
							end)
						end
					else
						if CurrentType == 'Uppercut' then
							ReplicateSet:FireAllClients('Ring',{ FirstProps = FirstProps, CF = EnemyHumRP.CFrame, TN_Info = TN_Info, FinalProps = FinalProps } )
							ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 3 })


							local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
							BodyAngularVelocity.MaxTorque = Vector3.new(50000, 50000, 50000)
							BodyAngularVelocity.AngularVelocity = Vector3.new(math.random(2.5, 5), math.random(2.5, 5), math.random(2.5, 5))
							BodyAngularVelocity.Parent = EnemyHumRP
							Debris:AddItem(BodyAngularVelocity, 0.1)

							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(0, 1, 0) * 10000, Velocity = Vector3.new(0, 1, 0) * 70 })


							if Player:GetAttribute("Moveset") == "Martial Artist" and (Character:GetAttribute("PurpleFinisher") or Character:HasTag("Awakened")) then
								AddRagdoll = false
								Character:SetAttribute("PurpleFinisher", nil)


								local StartCF = HumRP.CFrame
								local Stun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
								iFramesService:AddAlliFrames(EnemyCharacter)


								task.delay(0.133, function()
									EnemyCharacter:AddTag("CantRotate")

									DamageHandler:TakeDamage(Character, EnemyHumanoid, 12.5, nil, nil, false, false, true, true, false, nil, nil)
								end)

								task.delay(1.167, function()
									if not EnemyPlayer then
										EnemyHumRP:SetNetworkOwnershipAuto()
									end


									StunHandler:Unstun(Character, Stun)
									EnemyCharacter:RemoveTag("CantRotate")
									iFramesService:RemoveAlliFrames(EnemyCharacter)


									DamageHandler:TakeDamage(Character, EnemyHumanoid, 4.5, nil, nil, false, false, true, true, true, nil, nil)
									NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = -StartCF.RightVector * 100 + Vector3.new(0, 50, 0) })
									RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
								end)

								if not EnemyPlayer then
									EnemyHumRP:SetNetworkOwner(Player)
								end

								ReplicateSet:FireAllClients("suiryupassive", { StartCF = StartCF, Char = Character, EChar = EnemyCharacter })

							end

						else
							local FinalKnockback = Player:GetAttribute("Moveset") == "Hero Hunter" and Vector3.new(35, 0, 35) or Vector3.new(30, 0, 30)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(10000, 10000, 10000), Velocity = HumRP.CFrame.LookVector * FinalKnockback + Vector3.new(0, 20, 0) })
						end

						SvSt.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)
					end


					if AddRagdoll then
						RagdollHandler.ragdoll(EnemyHumanoid, 2, nil, nil, nil, nil, checkAir)
					end
					
				else
					local Velocity = HumRP.CFrame.LookVector * 13
					
					NewKnockback:Knockback(Character, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, 0, math.huge), Velocity = Velocity })
					if not EnemyCharacter:HasTag("Knockbacked") then
						NewKnockback:Knockback(EnemyHumRP, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, 0, math.huge), Velocity = Velocity })
					end
				end
			end
		end, nil, VoxelParameters)

		if Hit == true then
			if CurrentType == 'Uppercut' then
				
			end
		else
			if CurrentCombo >= MaxCombo then
				Character:SetAttribute('DefaultRunSpeed', 0)
				Character:SetAttribute('DefaultWalkSpeed', 0)

				Humanoid.WalkSpeed = 0
			end
		end
	end))

	local ended = false
	local function EndFunction()
		if ended == true then return end
		ended = true

		Character:RemoveTag('Punching')

		task.spawn(function()
			for _,v in PunchEvents do
				v:Disconnect()
			end
			
			local Stun
			if Hit == false and CurrentCombo >= 4 then
				Stun = StunHandler:Stun(Character, 0.7, false, 0, 0, false)
			end

			local WaitTime = 0.15
			
			if CurrentCombo >= MaxCombo and Hit == false then
				WaitTime *= 2
			end

			Character:AddTag("CantBlock")
			task.delay(WaitTime, function()
				if not Character:HasTag('Punching') then
					Character:SetAttribute('DefaultRunSpeed', 25)
					Character:SetAttribute('DefaultWalkSpeed', 16)
					Character:SetAttribute('DefaultJumpPower', 50)

					Character:RemoveTag("CantBlock")

					Humanoid.JumpPower = 50
					Humanoid.WalkSpeed = 16
				end
			end)
		end)

		if CurrentCombo >= MaxCombo then
			task.delay(1.5, function()
				Character:RemoveTag('PunchCDS')
				if Character:GetAttribute("doPunch") == true then
					M1(Player)
				end
			end)
		else
			Character:RemoveTag('PunchCDS')
			
			if Character:GetAttribute("doPunch") == true then
				M1(Player)
			end
		end
	end

	table.insert(PunchEvents, PunchAnimTrack:GetMarkerReachedSignal('end'):Once(EndFunction))
	PunchAnimTrack.Stopped:Once(EndFunction)

	AnimationService:stopAnimation(Character, PreviousAnimation)
	AnimationService:playAnimation(Character, PunchAnim)
	
	local MovesetName = Player:GetAttribute("Moveset")
	if MovesetName == "KJ" or MovesetName == "Martial Artist" or MovesetName == "Hero Hunter" or MovesetName == "Monster Form" then
		PunchAnimTrack:AdjustSpeed(1.15 * workspace.Configuration.AttackSMult.Value)
		
	elseif MovesetName == "Black" or MovesetName == "The Dark Lord" then
		PunchAnimTrack:AdjustSpeed(1.35 * workspace.Configuration.AttackSMult.Value)
		
	elseif MovesetName == "Cursed Child" then
		PunchAnimTrack:AdjustSpeed(1.5 * workspace.Configuration.AttackSMult.Value)
		
	elseif MovesetName == "Frozen Warrior" then
		PunchAnimTrack:AdjustSpeed(1.15 * workspace.Configuration.AttackSMult.Value)
		
		ReplicateSet:FireAllClients("frozenm1", { Char = Character, Stage = "Swing", Combo = CurrentCombo, Type = CurrentType })
		
	end
	
	
	
	if CurrentType ~= "Uppercut" and CurrentType ~= "Downslam" then
		if MovesetName == "Martial Artist" then
			ReplicateSet:FireAllClients("suiryum1", { Stage = "M" .. CurrentCombo, Char = Character })
			
		elseif MovesetName == "Turbo Kun" then
			local Part = Character["Right Leg"]
			if CurrentCombo == 2 or CurrentCombo == 4 then
				Part = Character["Left Leg"]
			elseif CurrentCombo == 3 then
				Part = Character["Right Arm"]
			end

			ReplicateSet:FireAllClients("okarunm1", { Part = Part, Lifetime = PunchAnimTrack.Length })
		end
	end

	task.spawn(function()
		local SwingSFX: Sound

		if CurrentType == 'Downslam' then
			SwingSFX = CombatSounds.Swings.Downslam
		else
			SwingSFX = (CombatSounds.Swings:FindFirstChild(MovesetName) or CombatSounds.Swings.Default)[tostring(CurrentCombo)]
		end

		SoundsModule:PlaySound(SwingSFX, HumRP)
	end)
end

local function Block(Player: Player)
	local Character = Player.Character
	if not Character or Character:GetAttribute("doBlock") ~= true then return end
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then return end
	local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then return end
	
	if Character:HasTag('CantBlock') or Character:HasTag('Stunned') or Character:HasTag('Punching') then 
		task.delay(0.1, function()
			Block(Player)
		end)
		
		for _, Anim in Animations.Throwables:GetDescendants() do
			if Anim:IsA("Animation") and Anim.Name == 'Idle' then
				AnimationService:stopAnimation(Character, Anim)
			end
		end
		
		return
	elseif Character:HasTag('ThrowableGrabbed') or Character:HasTag('Blocking') then
		return
	end
	
	local Actions = {
		'CantPunch',
		'CantDash',
		'CantSideDash',
		'CantBlock',
		'Blocking',
		'CantRun'
	}

	local Connections = {}
	local Anim, Stopped
	if Character:HasTag('HasKnife') then
		Anim = Animations.Combat.BlockKnife
		
	else
		Anim = Animations.Combat.Block
	end
	
	SoundsModule:PlaySound(CombatSounds.Blocking.Start, HumRP)
	
	local function stopBlock()
		if Stopped then return end
		Stopped = true
		
		
		for _,v in Connections do
			v:Disconnect()
		end
		
		
		Character:SetAttribute('DefaultRunSpeed', 25)
		Character:SetAttribute('DefaultWalkSpeed', 16)
		Character:SetAttribute('DefaultJumpPower', 50)

		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50

		for _, Action in ipairs(Actions) do
			Character:RemoveTag(Action)
		end
		
		SoundsModule:PlaySound(CombatSounds.Blocking.Stop, HumRP)
	end


	local BlockAnimTrack: AnimationTrack = AnimationService:getAnimationTrack(Character, Anim)

	Connections["Stopped"] = BlockAnimTrack.Stopped:Once(function()
		if Character:GetAttribute("DivineForm") then return end
		
		stopBlock()
	end)
	Connections["StopLoop"] = Character:GetAttributeChangedSignal("doBlock"):Connect(function()
		if not Character:GetAttribute("doBlock") then
			AnimationService:stopAnimation(Character, Anim)
			
			stopBlock()
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Anim)


	Character:SetAttribute('DefaultRunSpeed', 8)
	Character:SetAttribute('DefaultWalkSpeed', 8)

	Humanoid.WalkSpeed = 8
	Humanoid.JumpPower = 0


	for _, Action in ipairs(Actions) do
		Character:AddTag(Action)
	end


	local Perfect = true
	local PC: RBXScriptConnection
	PC = Character.ChildAdded:Connect(function(Child)
		if Child.Name == 'DamagedLog' and Child:HasTag('IsM1') and Perfect == true then
			if PC then
				PC:Disconnect()
				PC = nil
			end

			Character:AddTag('PerfectBlock')
			task.delay(1, function()
				Character:RemoveTag('PerfectBlock')
			end)
		end
	end)

	task.delay(.25, function()
		if PC then
			PC:Disconnect()
			PC = nil
		end

		Perfect = false
	end)
end



--Combat System
CombatSetEvent:Connect(function(Player, Action, Params)
	if not Player:FindFirstChild("LoadedData") then return end

	local Character = Player.Character
	if not Character or not Character.Parent then return end
	local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	if not HumRP or not HumRP.Parent or not Humanoid or not Humanoid.Parent then return end
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then return end
	
	if Action == 'PunchStart' then
		if workspace.Configuration.NoAttack.Value == true or Player.Commands.NoAttack.Value == true then return end
		
		if Character:FindFirstChild("HasSnowball") and Character.HasSnowball:GetAttribute("Done") == true and Character:FindFirstChild("Snowball") then
			local Thrown = false
			local Ended = false

			local State = Character:FindFirstChild("HasSnowball")
			local Stun: ObjectValue = State:FindFirstChild("Stun")
			Stun.Parent = Character
			
			StunHandler:Unstun(Character, Stun.Value)
			Stun.Value = StunHandler:Stun(Character, nil, true, 0, 0, true)
			
			
			local Snowball: Model = Character.Snowball
			
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
			BodyVelocity.Name = "moveme"
			BodyVelocity:SetAttribute("Speed", 30)
			BodyVelocity:SetAttribute("Fallout", 0.98)
			BodyVelocity:SetAttribute("End", 2)
			BodyVelocity.Parent = HumRP
			
			
			local Animation = Animations.Other["Throw Snowball"]
			local AnimationTrack, AnimationEvents = AnimationService:getAnimationTrack(Character, Animation)

			table.insert(AnimationEvents, AnimationTrack:GetMarkerReachedSignal("throw"):Once(function()
				Thrown = true
				BodyVelocity:Destroy()

				ReplicateSet:FireAllClients("snowballfx", { Char = Character, Stage = "Throw" })

				local ThrowPos = HumRP.Position


				task.spawn(function()
					local EnemyCharacter: Model = Getter:InvokeClient(Player, { Func = "snowballthrow", Snowball = Snowball, Char = Character })
					if not EnemyCharacter or iFramesService:HasiFrame(EnemyCharacter, "M1") then return end

					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local GoalCF = CFrame.lookAt(EnemyHumRP.Position, ThrowPos)

					EnemyHumRP.CFrame = GoalCF
					DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.MoveDirection == Vector3.zero and 5 or 50, 1, Animations.Other["Victim Snowball"], true, false, false, false, true, nil, nil)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "VelocityTweenDown", MaxForce = Vector3.new(50000, 0, 50000), Velocity = -GoalCF.LookVector * 75, Time = 0.7 })

					ReplicateSet:FireAllClients("snowballfx", { Char = EnemyCharacter, Stage = "Hit" })
					SoundsModule:PlaySound(Sounds.Other["Snowball Hit Victim"], EnemyHumRP)
				end)


				Snowball.Parent = workspace.Thrown
				Snowball.Snowball:Destroy()


				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
				BodyVelocity.Velocity = HumRP.CFrame.LookVector * 175 + Vector3.new(0, 5, 0)
				BodyVelocity.Parent = Snowball
				Debris:AddItem(BodyVelocity, 0.1)
			end))

			table.insert(AnimationEvents, AnimationTrack:GetMarkerReachedSignal("end"):Once(function()
				Ended = true
				
				StunHandler:Unstun(Character, Stun.Value)
				Stun:Destroy()
			end))

			AnimationTrack.Stopped:Once(function()
				if not Thrown then
					Snowball:Destroy()
					BodyVelocity:Destroy()
				end
				
				if not Ended then
					StunHandler:Unstun(Character, Stun.Value)
					Stun:Destroy()
				end
			end)
			
			State:Destroy()
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, Animation)
			
			SoundsModule:PlaySound(Sounds.Other["Snowball Throw"], HumRP)
			
		else
			Character:SetAttribute("doPunch", true)
			
			M1(Player)
			
		end

	elseif Action == "PunchEnd" then
		Character:SetAttribute("doPunch", false)

	elseif Action == 'Block' then
		if Params.Stage == true then
			if workspace.Configuration.NoBlock.Value == true or Player.Commands.NoBlock.Value == true then return end

			Character:SetAttribute("doBlock", true)

			Block(Player)
		else
			Character:SetAttribute("doBlock", false)
		end
	end
end)