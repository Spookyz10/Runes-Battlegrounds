local Players = game:GetService("Players")

local RS = game:GetService("ReplicatedStorage")
local SvSt = game:GetService("ServerStorage")

local RNS = game:GetService("RunService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local Shared = RS.Shared.Modules
local SvModules = SvSt.Modules

local Trove = require(Shared.Trove)

local StunHandler = require(SvModules.StunHandler)
local MovesetHandlerModule = require(SvModules.MovesetHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local CollisionsModule = require(SvModules.CollisionsModule)
local DamageHandler = require(SvModules.DamageHandler)
local AnimationService = require(SvModules.AnimationService)
local Knockback = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)
local CombatUtils = require(SvModules.CombatUtils)
local ReplicatedHitboxes = require(SvModules.ReplicatedHitboxes)
local Data = require(RS.Shared.Data).server
local Assets = SvSt.Assets
local Animations = Assets.Animations

local Remotes = RS.Remotes
local ComunicatorComms = Remotes.Comunicator
local ComSet = ComunicatorComms.Set
local ComGet = ComunicatorComms.Get
local Replication = Remotes.Replicate
local ReplicateSet = Replication.Set
local ExtraCdsSet = Remotes.ExtraCds.Set

local AnimationsTable = {}

pcall(function()
	PhysicsService:RegisterCollisionGroup("NonPColDebri")
end)
pcall(function()
	PhysicsService:RegisterCollisionGroup("Players")
end)
PhysicsService:CollisionGroupSetCollidable("NonPColDebri", "Players", false)

for _, Animation in Assets.Animations:GetDescendants() do
	if Animation:IsA("Animation") then
		table.insert(AnimationsTable, Animation.AnimationId)
	end
end

shared.sfx = function(Parameters)
	local Sound = Instance.new("Sound")
	Sound.SoundGroup = game.SoundService.Sounds

	if Parameters.AddTo then
		table.insert(Parameters.AddTo, Sound)
		Parameters.AddTo = nil
	end

	local Attachment = nil
	local EndConnection = nil
	EndConnection = Sound.Ended:connect(function()
		if Sound then
			Sound:Destroy()
		end

		if Attachment then
			Attachment:Destroy()
		end

		return EndConnection:Disconnect()
	end)

	if not Parameters.RollOffMaxDistance then
		Parameters.RollOffMaxDistance = 300
	end

	if Parameters.CFrame then
		Attachment = Instance.new("Attachment")
		Attachment.Parent = workspace.Terrain
		Attachment.WorldCFrame = Parameters.CFrame
		Parameters.Parent = Attachment
	end

	Parameters.CFrame = nil

	for Index, Value in Parameters do
		Sound[Index] = Value
	end

	return Sound, Attachment
end

shared.safeDestroy = function(instance)
	if not instance or typeof(instance) ~= "Instance" then
		return
	end

	instance:Destroy()
	instance = nil
end

shared.cfolder = function(instanceData, lifeTime)
	local newInstance = Instance.new("Accessory")

	for i, v in instanceData do
		newInstance[i] = v
	end

	if lifeTime and typeof(lifeTime) == "number" then
		task.delay(lifeTime, function()
			shared.safeDestroy(newInstance)
		end)
	end

	return newInstance
end

shared.AddAppareance = function(Player, Character, HumanoidDescription)
	if not Player or not Character or not Character.Parent then
		return
	end

	local userId = Player.UserId
	local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 5)
	if not Humanoid then
		return
	end

	local PlayersModel = Players:GetCharacterAppearanceAsync(userId)
	HumanoidDescription = HumanoidDescription or Players:GetHumanoidDescriptionFromUserId(userId)

	if HumanoidDescription then
		Humanoid:ApplyDescription(HumanoidDescription)
	end

	if PlayersModel then
		local Face = PlayersModel:FindFirstChild("face")
		if Face then
			Character.Head.face.Texture = Face.Texture
		end

		PlayersModel:Destroy()
	end

	for _, Accessory in Character:GetChildren() do
		if Accessory:IsA("Accessory") then
			local Handle = Accessory:FindFirstChild("Handle")
			if Handle and Handle:FindFirstChildOfClass("Weld") then
				local AccessoryWeld = Handle:FindFirstChildOfClass("Weld")

				local Weld = Instance.new("Weld")
				Weld.Name = "WeldConstraint"
				Weld.Part1 = AccessoryWeld.Part1
				Weld.Part0 = Handle
				Weld.C0 = Handle.CFrame:ToObjectSpace(AccessoryWeld.Part1.CFrame)
				Weld.Parent = Accessory

				AccessoryWeld:Destroy()

				Handle.CanCollide = false
				Handle.CanQuery = false
				Handle.CanTouch = false
				Handle.Massless = true
				Handle.CollisionGroup = "Players"

				Accessory.Name = "#ACCESSORY_" .. Accessory.Name
				Accessory.Parent = Character.FakeHead
			end
		end
	end

	local NewOutfitApplied = Instance.new("Configuration")
	NewOutfitApplied.Name = "NewHumanoidDescriptionApplied"
	NewOutfitApplied.Parent = Character
	Debris:AddItem(NewOutfitApplied, 5)

	if RS.Clones:FindFirstChild(Character.Name) then
		RS.Clones[Character.Name]:Destroy()
	end

	Character.Archivable = true
	local CharacterClone = Character:Clone()
	Character.Archivable = false

	CharacterClone.Parent = RS.Clones
	for _, scriptInChar in CharacterClone:GetDescendants() do
		if scriptInChar:IsA("LocalScript") or scriptInChar:IsA("Script") then
			scriptInChar:Destroy()
		end
	end
end

shared.fireAllExcept = function(RemoteEvent, Blacklist, Parameters)
	for _, Player in Players:GetPlayers() do
		if not table.find(Blacklist, Player) then
			RemoteEvent:FireClient(Player, table.unpack(Parameters))
		end
	end
end

shared.fireTo = function(RemoteEvent, Whitelist, Parameters)
	for _, Player in Whitelist do
		RemoteEvent:FireClient(Player, table.unpack(Parameters))
	end
end

local function HumanoidDied(Player)
	if not Player.Character then
		return
	end

	local Character = Player.Character
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character.Humanoid

	if not Character:HasTag("DontDoDieFunction") then
		if Humanoid.BreakJointsOnDeath then
			for _, v in Character:GetDescendants() do
				if v:IsA("Motor6D") or v:IsA("BallSocketConstraint") then
					v:Destroy()
				elseif v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") then
					v.AssemblyLinearVelocity =
						Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					v.AssemblyAngularVelocity =
						Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
				end
			end

			StunHandler:Stun(Character, 6)
		else
			Character:AddTag("CantRagdollCancel")
			RagdollHandler.ragdoll(Humanoid)
		end
	end

	local deathSoundId = Player:GetAttribute("deathSound")
	if deathSoundId ~= nil and HumRP then
		local deathSound = Instance.new("Sound")
		deathSound.RollOffMaxDistance = 250
		deathSound.RollOffMinDistance = 10
		deathSound.Volume = 1
		deathSound.SoundId = "rbxassetid://" .. tostring(deathSoundId)
		deathSound.SoundGroup = game.SoundService.Sounds
		deathSound.Parent = HumRP
		deathSound:Play()
		task.spawn(function()
			deathSound.Stopped:Wait()
			deathSound:Destroy()
		end)
	end

	iFramesService:RemoveAlliFrames(Character)

	local respawnConnection
	local respawnStartTime = os.clock()
	local respawnDelay = Player:WaitForChild("RespawnTime").Value

	respawnConnection = RNS.Heartbeat:Connect(function()
		if Player:WaitForChild("CanRespawn").Value == true then
			if (os.clock() - respawnStartTime) >= respawnDelay then
				Character:Destroy()

				if Player:IsDescendantOf(game) then
					Player:LoadCharacter()
				end

				respawnConnection:Disconnect()
				return
			end
		else
			respawnStartTime = os.clock()

			if respawnDelay ~= 2.5 then
				respawnDelay = 2.5
				return
			end
		end
	end)
end

local ComunicatorFunctions = {
	MonsterPosConfrim = function(Player, Parameters)
		local Position = Parameters.Pos
		if typeof(Position) ~= "Vector3" then
			return
		end

		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart
		if not Character or not HumRP then
			return
		end

		local function clampDistance(origin, target, max)
			local dir = target - origin
			local mag = dir.Magnitude

			if mag <= max then
				return target
			end
			if mag == 0 then
				return origin
			end

			return origin + dir.Unit * max
		end

		Position = clampDistance(HumRP.Position, Position, 300)

		local RayOrigin = Position + Vector3.new(0, 5, 0)
		local RayDir = Vector3.new(0, -200, 0)
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		RayParams.FilterDescendantsInstances = { Character }

		local Hit = workspace:Raycast(RayOrigin, RayDir, RayParams)
		if Hit and Hit.Position then
			Position = Hit.Position
		end

		local Name = "MonsterPosConfrim"
		local HasAlready = Character:FindFirstChild(Name)

		if HasAlready and HasAlready:IsA("CFrameValue") then
			HasAlready.Value = CFrame.new(Position)
		else
			local CFrameValue = Instance.new("CFrameValue")
			CFrameValue.Name = Name
			CFrameValue.Value = CFrame.new(Position)
			CFrameValue.Parent = Character
		end
	end,

	Keypress = function(Player, Parameters)
		local Character = Player.Character
		if not Character then
			return
		end
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not Humanoid then
			return
		end
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local Keypressed = Parameters.Key

		if Keypressed == Enum.KeyCode.Q then
			local Direction = Parameters.Direction

			if Direction == "Front" or Direction == "Back" then
				if Direction == "Back" then
					if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
						if
							Character:HasTag("DashCD")
							or Character:HasTag("CantDash")
							or Character:HasTag("Stunned")
						then
							return
						end
					else
						if
							not Character:HasTag("CantRagdollCancel")
							and Character:GetAttribute("RagdollCancel") ~= false
						then
							task.spawn(function()
								RagdollHandler.cancelRagdoll(Humanoid, nil, false, nil, true, true)

								ReplicateSet:FireAllClients("Evasive", { Char = Character })
								ExtraCdsSet:FireClient(Player, "Evasive", 30)

								Character:SetAttribute("RagdollCancel", false)
								task.delay(30, function()
									Character:SetAttribute("RagdollCancel", true)
								end)
							end)
						else
							return
						end
					end

					local Jantior = Trove.new()

					Character:AddTag("DashCD")
					task.delay(5, function()
						Character:RemoveTag("DashCD")
					end)

					ExtraCdsSet:FireClient(Player, "BackDash", 5)

					AnimationService:stopAnimation(Character, Animations.Other.Knockback)

					StunHandler:Stun(Character, 1.017, true, 0, 0, true)

					StunHandler:Stun(Character, 1.017, true, 0, 0, true)

					ReplicateSet:FireAllClients("DashDebris", { func = "Start", char = Character })
					task.delay(1.017, function()
						ReplicateSet:FireAllClients("DashDebris", { func = "Stop", char = Character })
					end)

					task.delay(0.05, function()
						iFramesService:AddBaseiFrames(Character)
						task.delay(0.75, function()
							iFramesService:RemoveAlliFrames(Character)
						end)

						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.2))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character

						ReplicateSet:FireAllClients("smokeEffect", { time = 0.2, char = Character })
					end)

					task.delay(0.5, function()
						ReplicateSet:FireAllClients("smokeEffect", { time = 0.35, char = Character })

						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.4))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character
					end)

					task.delay(1.2, function()
						Jantior:Clean()
					end)

					local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
					for _, v in Character:GetChildren() do
						if v:IsA("BasePart") then
							if table.find(limbNames, v.Name) then
								ReplicateSet:FireAllClients(
									"armTrailEffect",
									{ char = Character, lifeTime = 0.65, limbName = v.Name }
								)
							end
						end
					end
				else
					if Character:HasTag("Stunned") then
						return
					end

					if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
						if
							Character:HasTag("DashCD")
							or Character:HasTag("CantDash")
							or Character:HasTag("Stunned")
						then
							return
						end
					end

					Character:AddTag("CantDash")
					Character:AddTag("DashCD")
					task.delay(5, function()
						Character:RemoveTag("CantDash")
						Character:RemoveTag("DashCD")
					end)

					ExtraCdsSet:FireClient(Player, "FrontDash", 5)

					for _, v in HumRP:GetChildren() do
						if v:IsA("LinearVelocity") or v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end

					local dashVelocity = Instance.new("BodyVelocity")
					dashVelocity.Name = "FrontDashVelocity"
					dashVelocity.MaxForce = Vector3.new(40000, 0, 40000)

					task.delay(0.1, function()
						ReplicateSet:FireAllClients("Ring", {
							FirstProps = {
								Size = Vector3.new(2.589, 0.896, 2.589),
								Transparency = 0.25,
							},

							CF = HumRP.CFrame * CFrame.Angles(1.5707963267948966, 0, 0),

							TN_Info = {
								Time = 0.3,
								Style = "Quad",
								Direction = "Out",
							},

							FinalProps = {
								Size = Vector3.new(9.874, 0.1, 9.874),
								Transparency = 1,
							},
						})
					end)

					local SmallDebris = shared.cfolder({ Name = "SmallDebris" }, 1)
					CollectionService:AddTag(SmallDebris, "SmallDebris")
					SmallDebris.Parent = Character

					local DashStart = RS.Resources.Animations.Dashes.DashFront
					local AnimTrack = AnimationService:getAnimationTrack(Character, DashStart)
					local HitEvents = {}

					local DetectedEnemy
					local Hit = false
					local Ended = false
					local Time = time()
					local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
					local NearEnemys = {}

					local Jantior = Trove.new()

					local dashingForward = Jantior:Add(shared.cfolder({ Name = "dashingForward" }))
					dashingForward.Parent = Character

					local function endDash()
						Ended = true

						Character:SetAttribute("Dashing", false)

						ReplicateSet:FireAllClients("DashDebris", { func = "Stop", char = Character })

						dashVelocity:Destroy()

						AnimTrack:AdjustSpeed(1)

						shared.safeDestroy(SmallDebris)

						if Jantior then
							Jantior:Destroy()
							Jantior = nil
						end
					end

					for _, CloseEnemy in workspace.Live:GetChildren() do
						if CloseEnemy == Character then
							continue
						end

						local CloseHumRP = CloseEnemy:FindFirstChild("HumanoidRootPart")
						if CloseHumRP then
							if (CloseHumRP.Position - HumRP.Position).Magnitude < 15 then
								table.insert(NearEnemys, CloseEnemy)
							end
						end
					end

					HitEvents["hit"] = AnimTrack:GetMarkerReachedSignal("hit"):Once(function()
						ReplicateSet:FireAllClients("destroyAmbient", {
							Velocity = HumRP.CFrame.LookVector,
							Multiplier = { 15, 50 },
							Size = Vector3.one * 8,
							CFrame = HumRP,
							Offset = CFrame.new(0, 1, -4),
							Voxels = true,
						})

						local Hitbox = ReplicatedHitboxes.new(Player)
						Hitbox.Size = Vector3.new(8, 8, 8)
						Hitbox.Offset = CFrame.new(0, 1, -4)
						Hitbox.Instance = HumRP
						Hitbox.Ignore = { Character }
						Hitbox.destroyAfterOnce = true
						Hitbox.onTouch = function(EnemyCharacter)
							local EnemyHumRP = EnemyCharacter.HumanoidRootPart
							local EnemyHumanoid = EnemyCharacter.Humanoid
							local Ragdolled = EnemyCharacter:HasTag("Ragdolled")
							local inAir = EnemyCharacter:FindFirstChild("inAir")
								or (
									EnemyCharacter:GetAttribute("TouchedGround")
									and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25
								)

							if EnemyCharacter ~= DetectedEnemy then
								if
									iFramesService:HasiFrame(EnemyCharacter, "M1")
									or EnemyHumanoid.Health <= 0
									or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
									or (Ragdolled and not inAir)
								then
									return
								end
							end

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								4,
								1,
								Assets.Animations.Combat.Hits[tostring(math.random(1, 3))],
								true,
								true,
								true
							)
							if HitInfo.Countered == true then
								return
							end

							if not Hit then
								Hit = true
								ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 2 })
							end

							ReplicateSet:FireAllClients("HitEffect", {
								EChar = EnemyCharacter,
								HitChar = Character,
							})

							if dashingForward then
								Debris:AddItem(dashingForward, 0.1)
							end

							if Ragdolled or table.find(NearEnemys, EnemyCharacter) then
								if Ragdolled then
									RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
								end

								EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

								local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
								local lookVector = Character.HumanoidRootPart.CFrame.LookVector
								local dotProduct = lookVector:Dot(selfToOtherChar)

								if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
									dotProduct = 1
								end

								local at = Character.HumanoidRootPart.Position
								local forward = Character.HumanoidRootPart.CFrame.LookVector
								local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

								require(SvModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
									LookVector = lookposition.LookVector,
									LookForce = 58.5,
									LookFinalForce = 55,
									LookAt = lookposition,
									DestroyRagdoll = true,
									GroundStunTime = 0.95,
									Escapable = false,
									FallingDetectDelay = 0.2,
									Dot = dotProduct,
									DotParams = { 0.4, 1 },
									canHitWall = true,
								}, Character)

								Knockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
							end
						end

						Hitbox:Once()

						if Hit then
							task.delay(0.05, function()
								StunHandler:Unstun(Character, Stun)
							end)
						end
					end)

					HitEvents["freeze"] = AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
						if Ended then
							AnimTrack:AdjustSpeed(1)
							return
						end

						AnimTrack:AdjustSpeed(0)
					end)

					HitEvents["jump"] = AnimTrack:GetMarkerReachedSignal("jump"):Once(function()
						dashVelocity.Parent = HumRP
						Debris:AddItem(dashVelocity, 0.85)

						local DetectHitbox = ReplicatedHitboxes.new(Player)
						DetectHitbox.Size = Vector3.new(8, 8, 8)
						DetectHitbox.Offset = CFrame.new(0, 1, -4)
						DetectHitbox.Instance = HumRP
						DetectHitbox.Ignore = { Character }
						DetectHitbox.onTouch = function(EnemyCharacter)
							local EnemyHumanoid = EnemyCharacter.Humanoid
							local Ragdolled = EnemyCharacter:HasTag("Ragdolled")
							local inAir = EnemyCharacter:FindFirstChild("inAir")
								or (
									EnemyCharacter:GetAttribute("TouchedGround")
									and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25
								)

							if
								iFramesService:HasiFrame(EnemyCharacter, "M1") == true
								or EnemyHumanoid.Health <= 0
								or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
								or (Ragdolled and not inAir)
							then
								return
							end

							if not Ended then
								if Character:GetAttribute("Combo") == 3 then
									shared.safeDestroy(dashVelocity)
									Character:SetAttribute("Combo", 0)
								end

								if time() - Time < 0.315 then
									return
								end

								if DetectHitbox ~= nil then
									DetectHitbox:Destroy()
									DetectHitbox = nil
								end

								DetectedEnemy = EnemyCharacter
								endDash()
							end
						end

						DetectHitbox:Start(0.7, true)
					end)

					AnimTrack.Stopped:Once(function()
						for _, v in HitEvents do
							v:Disconnect()
						end

						StunHandler:Unstun(Character, Stun)

						if not Hit then
							ReplicateSet:FireAllClients(
								"DashMiss",
								{ PrimaryPart = HumRP, YAngle = math.pi, Front = true }
							)
						end
					end)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, DashStart)

					Character:SetAttribute("Dashing", true)
					ReplicateSet:FireAllClients("DashDebris", { func = "Start", char = Character })

					ReplicateSet:FireAllClients("DashMiss", { PrimaryPart = HumRP })

					task.delay(0.55, function()
						Character:SetAttribute("Dashing", false)
					end)

					task.delay(0.7, function()
						HumRP.AssemblyLinearVelocity = Vector3.new()

						if not Ended then
							endDash()
						else
							AnimTrack:AdjustSpeed(1)
						end
					end)

					task.delay(1.25, function()
						if Stun and Stun.Parent == Character then
							AnimTrack:AdjustSpeed(1)
							StunHandler:Unstun(Character, Stun)
						end
					end)

					local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
					for _, v in Character:GetChildren() do
						if v:IsA("BasePart") then
							if table.find(limbNames, v.Name) then
								ReplicateSet:FireAllClients(
									"armTrailEffect",
									{ char = Character, lifeTime = 0.875, limbName = v.Name }
								)
							end
						end
					end
				end
			elseif Direction == "Right" or Direction == "Left" then
				if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
					if
						Character:HasTag("SideDashCD")
						or Character:HasTag("CantSideDash")
						or Character:HasTag("Stunned")
					then
						return
					end
				else
					if
						not Character:HasTag("CantRagdollCancel")
						and Character:GetAttribute("RagdollCancel") ~= false
					then
						task.spawn(function()
							RagdollHandler.cancelRagdoll(Humanoid, nil, false, nil, true, true)

							ReplicateSet:FireAllClients("Evasive", { Char = Character })

							Character:SetAttribute("RagdollCancel", false)
							task.delay(30, function()
								Character:SetAttribute("RagdollCancel", true)
							end)
						end)
					else
						return
					end
				end

				local Jantior = Trove.new()

				AnimationService:stopAnimation(Character, Animations.Other.Knockback)

				if Character:GetAttribute("TpDash") then
					Character:SetAttribute("Invisible", true)
					task.delay(0.45, function()
						Character:SetAttribute("Invisible", false)
					end)
				else
					task.spawn(function()
						local SmallDebris = Jantior:Add(shared.cfolder({ Name = "SmallDebris" }, 0.25))
						SmallDebris:AddTag("SmallDebris")
						SmallDebris.Parent = Character

						ReplicateSet:FireAllClients("smokeEffect", { time = 0.3, char = Character })
					end)

					task.delay(0.7, function()
						Jantior:Clean()
					end)
				end

				Character:AddTag("SideDashCD")
				task.delay(2, function()
					Character:RemoveTag("SideDashCD")
				end)

				ExtraCdsSet:FireClient(Player, Direction .. "Dash", 2)

				Character:AddTag("CantDash")
				task.delay(0.6, function()
					Character:RemoveTag("CantDash")
				end)
			end
		end
	end,

	DeleteBV = function(Player, Parameters)
		local BodyVelocity = Parameters.BV
		if BodyVelocity then
			BodyVelocity:Destroy()
		end
	end,

	ResetCharacter = function(Player)
		if not Player.Character or not Player.Character.Parent then
			return
		end

		local Character = Player.Character
		local Humanoid = Character.Humanoid

		local DamagedLog = Character:FindFirstChild("DamagedLog")
		local DamagerLog = Character:FindFirstChild("DamagerLog")

		if Character:HasTag("Stunned") then
			ComSet:FireClient(
				Player,
				"SendNotification",
				{ Title = "NOTIFICATION", Text = "YOU CAN'T RESET YOUR CHARACTER RIGHT NOW" }
			)
		elseif (DamagedLog and not DamagedLog:HasTag("Dummy")) or (DamagerLog and not DamagerLog:HasTag("Dummy")) then
			local TimeUntilReset = 0
			if DamagedLog then
				TimeUntilReset = DamagedLog.TimeRemaining.Value
			end

			if DamagerLog then
				if DamagerLog.TimeRemaining.Value > TimeUntilReset then
					TimeUntilReset = DamagerLog.TimeRemaining.Value
				end
			end

			ComSet:FireClient(Player, "SendNotification", {
				Title = "NOTIFICATION",
				Text = "WAIT " .. tostring(math.round(TimeUntilReset)) .. " SECONDS BEFORE RESETTING",
			})
		else
			Humanoid.Health = 0
		end
	end,

	GetCF = function(Player, Params)
		if Params.Obj then
			return Params.Obj.CFrame
		else
			return nil
		end
	end,

	SetMoveset = function(Player, MovesetName)
		if MovesetName == Player:GetAttribute("Moveset") then
			ComSet:FireClient(
				Player,
				"SendNotification",
				{ Title = "NOTIFICATION", Text = "YOU ARE ALREADY PLAYING THIS CHARACTER." }
			)
			return
		end

		local Character = Player.Character
		if not Character or Character:HasTag("Stunned") then
			ComSet:FireClient(
				Player,
				"SendNotification",
				{ Title = "NOTIFICATION", Text = "YOU CAN'T CHANGE MOVESETS RIGHT NOW." }
			)
			return
		end

		local DamagerLog = Player.Character:FindFirstChild("DamagerLog")
		local DamagedLog = Player.Character:FindFirstChild("DamagedLog")

		if
			(DamagerLog and not DamagerLog.Value:FindFirstChild("Dummy"))
			or (DamagedLog and not DamagedLog.Value:FindFirstChild("Dummy"))
		then
			local DamagerTime, DamagedTime = 0, 0

			if DamagerLog then
				DamagerTime = math.round(DamagerLog.TimeRemaining.Value)
			end

			if DamagedLog then
				DamagedTime = math.round(DamagedLog.TimeRemaining.Value)
			end

			local HighestTime = math.max(DamagerTime, DamagedTime)

			if HighestTime > 0 then
				ComSet:FireClient(Player, "SendNotification", {
					Title = "NOTIFICATION",
					Text = "CAN'T CHANGE MOVESETS RIGHT NOW, WAIT " .. HighestTime .. " SECONDS.",
				})
				return
			end
		end

		if Player:HasTag("MovesetCD") then
			ComSet:FireClient(
				Player,
				"SendNotification",
				{ Title = "NOTIFICATION", Text = "CAN'T EQUIP MOVESET, YOU ARE ON COOLDOWN." }
			)
			return
		end

		Player:AddTag("MovesetCD")
		task.delay(2, function()
			Player:RemoveTag("MovesetCD")
		end)

		Player.Configuration.Moveset.Value = MovesetName
		Player:SetAttribute("Moveset", MovesetName)

		Player:LoadCharacter()
	end,

	replicationLoaded = function(Player)
		Remotes.Replicate.Set:FireClient(Player, "preloadanims", AnimationsTable)
	end,

	destroyAmbient = function(_, Params)
		local Container = Params.Container
		local State = Params.State

		if not Container then
			return
		end

		if State == true then
			Container:AddTag("Destroyed")

			for _, Part in Container:GetDescendants() do
				if Part:IsA("Part") or Part:IsA("MeshPart") then
					Part.Transparency = 1
					Part.CanCollide = false
					Part.CanQuery = false
				end
			end
		else
			Container:RemoveTag("Destroyed")

			for _, Part in Container:GetDescendants() do
				if Part:IsA("Part") or Part:IsA("MeshPart") then
					Part.Transparency = 0
					Part.CanCollide = true
					Part.CanQuery = true
				end
			end
		end
	end,
}

local function AddStarterPlayer(Player)
	if not Player then
		return
	end

	local PlayerData = Data.Service:waitForData(Player)
	local template = SvSt.StarterPlayer

	for _, obj in template:GetChildren() do
		local clone = obj:Clone()
		clone.Parent = Player
	end

	local Moveset = Player:FindFirstChild("Moveset")
	if not Moveset then
		Moveset = Instance.new("Folder")
		Moveset.Name = "Moveset"
		Moveset.Parent = Player
	end

	local AwakeningProgress = Player:FindFirstChild("AwakeningProgress")
	if not AwakeningProgress then
		AwakeningProgress = Instance.new("NumberValue")
		AwakeningProgress.Name = "AwakeningProgress"
		AwakeningProgress.Value = 0
		AwakeningProgress.Parent = Player
	end

	local CurrentMode = Player:FindFirstChild("CurrentMode")
	if not CurrentMode then
		CurrentMode = Instance.new("StringValue")
		CurrentMode.Name = "CurrentMode"
		CurrentMode.Value = "Default"
		CurrentMode.Parent = Player
	end

	local leaderstats = Player:FindFirstChild("leaderstats")
	if leaderstats then
		local Kills = leaderstats:FindFirstChild("Kills") or Instance.new("NumberValue", leaderstats)
		Kills.Name = "Kills"
		Kills.Value = Data[Player].Kills()
		Data[Player].Kills.Changed(function(kills, oldKills)
			Kills.Value = kills
		end)

		local TotalKills = leaderstats:FindFirstChild("Total Kills") or Instance.new("NumberValue", leaderstats)
		TotalKills.Name = "Total Kills"
		TotalKills.Value = Data[Player].TotalKills()
		Data[Player].TotalKills.Changed(function(kills, oldKills)
			Kills.Value = kills
		end)
	end

	local Moveset_attr = Player:GetAttribute("Moveset")
	if not Moveset_attr then
		Player:SetAttribute("Moveset", PlayerData.Moveset() or "Eclipse")
	else
		Player:SetAttribute("Moveset", Moveset_attr)
	end

	if Player:GetAttribute("Moveset") == "Eclipse" then
		Player:SetAttribute("MovesetMode_Eclipse", "Lunar")
	end

	CombatUtils.AddValue(Player, "NumberValue", 6, "RespawnTime")
	CombatUtils.AddValue(Player, "BoolValue", true, "CanRespawn")

	local loadedData = Instance.new("BoolValue")
	loadedData.Name = "LoadedData"
	loadedData.Value = true
	loadedData.Parent = Player

	CollectionService:AddTag(Player, "DataLoaded")
end

local function PlayerAdded(Player)
	if Player:GetAttribute("Added") == true then
		return
	end
	Player:SetAttribute("Added", true)

	local ok, err = pcall(AddStarterPlayer, Player)
	if not ok then
		Player:Kick("Erro ao inicializar personagem.")
		if RNS:IsStudio() then
			warn(err)
		end
		return
	end

	Player:SetAttribute("Loaded", true)

	local Character = Player.Character
	if Character then
		CharacterAdded(Character)
	end
	Player.CharacterAdded:Connect(CharacterAdded)
end

function CharacterAdded(Character)
	if not Character:IsDescendantOf(game) then
		repeat
			task.wait()
		until Character:IsDescendantOf(game)
	end

	Character:SetAttribute("JustSpawned", true)
	Character.Parent = workspace.Live

	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		if Character then
			Character:Destroy()
		end
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
	local HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

	local Died = false

	if Player:GetAttribute("Awakened") then
		Player.AwakeningProgress.Value = 0
	end
	Player:SetAttribute("Awakened", false)

	iFramesService:AddAlliFrames(Character)
	AnimationService:loadAnimations(Character)

	task.delay(4, function()
		Character:SetAttribute("JustSpawned", nil)
		iFramesService:RemoveAlliFrames(Character)
	end)

	if Humanoid.MoveDirection.Magnitude == 0 then
		Humanoid:GetPropertyChangedSignal("MoveDirection"):Once(function()
			if Humanoid.MoveDirection.Magnitude ~= 0 then
				AnimationService:stopAll(Character)
			end
		end)
	end

	task.spawn(function()
		shared.AddAppareance(Player, Character)
	end)

	Humanoid.Died:Once(function()
		if Died == false then
			Died = true
			HumanoidDied(Player)
		end
	end)

	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			if Died == false then
				Died = true
				HumanoidDied(Player)
			end
		end
	end)

	HumRP:GetPropertyChangedSignal("Parent"):Connect(function()
		if Died == false and HumRP.Position.Y <= workspace.FallenPartsDestroyHeight then
			Died = true
			HumanoidDied(Player)
		end
	end)

	Humanoid.DisplayName = Player.DisplayName

	MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))

	AnimationService:loadAnimations(Character)

	CollisionsModule:SetCollisionGroup(Character, "Players")

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	Character:SetAttribute("Moveset", Player:GetAttribute("Moveset"))
end

for _, v in Players:GetPlayers() do
	if not v:GetAttribute("Added") then
		task.spawn(function()
			PlayerAdded(v)
		end)
	end
end

Players.PlayerAdded:Connect(PlayerAdded)

CollectionService:GetInstanceAddedSignal("CantRotate"):Connect(function(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.AutoRotate = false
	end
end)

CollectionService:GetInstanceRemovedSignal("CantRotate"):Connect(function(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		if Character:HasTag("Ragdolled") then
			Character:AddTag("CantRotate")
		else
			Humanoid.AutoRotate = true
		end
	end
end)

ComGet.OnServerInvoke = function(Player, Function, Params)
	print("Invoked: " .. Function)
	if not ComunicatorFunctions[Function] then
		return nil
	end
	return ComunicatorFunctions[Function](Player, Params)
end

ComSet.OnServerEvent:Connect(function(Player, _Function, Params)
	if _Function == "InputDetected" then
		for _, AnimationTrack in AnimationService:getLoadedAnimations(Player.Character) do
			if
				AnimationTrack.IsPlaying == true
				and AnimationTrack.Animation.Parent == Animations["Spawn Animations"]
			then
				AnimationService:stopAnimation(Player.Character, AnimationTrack.Animation)
			end
		end

		Player:SetAttribute("DoSpawnAnim", false)
	else
		ComunicatorFunctions[_Function](Player, Params)
	end
end)
