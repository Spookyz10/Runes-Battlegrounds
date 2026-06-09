local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")


local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes


local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local WeaponsHandler = require(ServerModules.WeaponsHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)



local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)
local Trove = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local VfxUtility = services:GetService("VFX_Utility")
local knockbackService = services:GetService("KnockbackService")


local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models


local Weapons = Models.Weapons

local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local CombatAnims = Animations.Combat
local CombatSounds = Sounds.Combat


local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get


local ReplicateEffects_Set = RemotesContainer.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena, 
	workspace.Map.Miscellaneous, 
	workspace.Map.Borders
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Attributes = ReplicatedStorage.Bindables.ATTRIBUTES
		local RandomGenerator = Random.new()
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		Character:AddTag('CantRotate')
		
		
		local UserAnimation = MoveAnims.Black["Rocket Launchers"].Main
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		
		
		local RocketLauncherModel = Models.Black.RocketLaunchers:Clone()
		Debris:AddItem(RocketLauncherModel, 3.3)
		RocketLauncherModel.Parent = Character
		
		
		for i = 1, 2 do
			local armSide = i == 1 and "Right" or "Left"
			local ArmLauncher = RocketLauncherModel:FindFirstChild("RL_" .. armSide)

			if ArmLauncher then
				local Arm = Character:FindFirstChild(armSide .. " Arm")
				
				if Arm then
					ArmLauncher:PivotTo(Arm.CFrame)
					ArmLauncher.PrimaryPart.MainWeld.Part0 = Arm

					local HighlightEffect = ReplicatedStorage.Resources.Black.Awakening["Rocket Launchers"].Highlight:Clone()
					Debris:AddItem(HighlightEffect, 3.3)
					HighlightEffect.Parent = Arm
					HighlightEffect.Adornee = Arm

					TweenService:Create(HighlightEffect, TweenInfo.new(0.3), {
						["FillTransparency"] = 0
					}):Play()

					coroutine.wrap(function()
						task.delay(2.633, function()
							TweenService:Create(HighlightEffect, TweenInfo.new(0.3), {
								["FillTransparency"] = 1
							}):Play()

							for scaleValue = 1, 0.1, -0.1 do
								ArmLauncher:ScaleTo(scaleValue)
								task.wait(0.02)
							end
						end)

						for scaleValue = 0.1, 1, 0.1 do
							ArmLauncher:ScaleTo(scaleValue)
							task.wait(0.02)
						end
					end)()

					ArmLauncher.AnimationController.Animator:LoadAnimation(MoveAnims.Black["Rocket Launchers"][armSide .. "RL"]):Play(0)

					task.delay(1.983, function()
						if ArmLauncher:FindFirstChild("Base") then
							for j = 1, 9 do
								ArmLauncher.Base:FindFirstChild("LP_" .. j)
							end
						end
					end)
				end
			end
		end
		
		
		local DamagedTargets = {}
		local function CreateExplosionAt(position)
			local explosionRadius = Attributes.EXPLOSION_RADIUS.Value
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = CFrame.new(position)
			Hitbox.Size = Vector3.new(1, 1, 1) * explosionRadius * 2
			Hitbox.Ignore = { Character }
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(1, 1, 1) * explosionRadius * 2 + Vector3.new(0, 25, 0) }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local damageAmount
				if DamagedTargets[EnemyCharacter] then
					damageAmount = math.random(2, 3)
				else
					damageAmount = math.random(22, 27)
				end
				DamagedTargets[EnemyCharacter] = true
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, damageAmount, 2, nil, false, false, true, true, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				local knockbackData = {
					["duration"] = 0.2,
					["force"] = 30,
					["direction"] = CFrame.new(position, EnemyCharacter.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
				}
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, knockbackData)
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
		end
		
		
		local function LaunchMissiles(targetPosition)
			if targetPosition then
				local hrpCFrame = HumRP.CFrame
				local startPosition = (hrpCFrame * CFrame.new(0, 25, 0)).Position
				local direction = CFrame.new(startPosition, targetPosition.Position).LookVector
				local clampedDirection = Vector3.new(direction.X, math.min(direction.Y, 0.05), direction.Z)
				local travelVector = clampedDirection * Attributes.MAX_RANGE.Value
				local rayResult = workspace:Raycast(startPosition, travelVector, MapRayParams)
				local endPosition = rayResult and rayResult.Position or startPosition + travelVector
				local maxOffset = Attributes.MAX_EXPLOSION_OFFSET.Value
				local totalTime = 0
				local projectileInfos = {}

				for i = 1, 18 do
					local offsetX = RandomGenerator:NextNumber(-maxOffset, maxOffset)
					local offsetY = RandomGenerator:NextNumber(-maxOffset / 3, maxOffset / 3)
					local offsetZ = RandomGenerator:NextNumber(-maxOffset, maxOffset)
					local explosionTarget = endPosition + Vector3.new(offsetX, offsetY, offsetZ)
					local groundRay = workspace:Raycast(explosionTarget, Vector3.new(0, -1, 0) * maxOffset, MapRayParams)
					local explosionPos = groundRay and groundRay.Position or explosionTarget
					local travelTime = (hrpCFrame.Position - explosionPos).Magnitude / Attributes.AVERAGE_PROJECTILE_SPEED.Value
					
					projectileInfos[i] = {
						["startPos"] = hrpCFrame.Position,
						["endPos"] = explosionPos,
						["timeToExplode"] = travelTime
					}

					totalTime += travelTime
					task.delay(travelTime, function()
						CreateExplosionAt(explosionPos)
					end)
				end

				task.delay(totalTime + 1, function()
					table.clear(DamagedTargets)
					DamagedTargets = nil
				end)
				
				ReplicateEffects_Set:FireAllClients("RocketLaunchers", { Char = Character, Stage = "missiles", pI = projectileInfos })

				table.clear(projectileInfos)
			end
		end
		
		
		task.delay(1.9, function()
			local RemoteConnection = nil

			RemoteConnection = RemotesContainer.RocketLaunchers.OnServerEvent:Connect(function(client, target)
				if client == Player then
					if RemoteConnection then
						RemoteConnection:Disconnect()
						RemoteConnection = nil
					end
					
					LaunchMissiles(target)
				else
					client:Kick("Unusual activites detected.")
				end
			end)

			task.delay(3.15, function()
				if RemoteConnection then
					RemoteConnection:Disconnect()
					RemoteConnection = nil
				end
			end)
		end)
		
		
		UserTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			Character:RemoveTag('CantRotate')
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)


		ReplicateEffects_Set:FireAllClients("RocketLaunchers", { Char = Character, Stage = "pa", Animation = UserAnimation.AnimationId })
	end
}