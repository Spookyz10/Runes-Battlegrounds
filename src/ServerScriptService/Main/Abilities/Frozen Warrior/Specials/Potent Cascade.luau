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
local Clock = services:GetService("Clock")


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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 6, 0, true)
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Potent Cascade"].Use1
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local OldAxe = Models.Frozen.OldAxe:Clone()
		Debris:AddItem(OldAxe, 1.68)
		OldAxe:PivotTo(HumRP.CFrame)
		OldAxe.rootPart.Bone.Part0 = Character["Right Arm"]
		OldAxe.Parent = Character

		coroutine.wrap(function()
			pcall(function()
				OldAxe:ScaleTo(0.01)
				
				for v33 = 1, 10 do
					OldAxe:ScaleTo(v33 / 10)
					task.wait(0.01)
				end
			end)
		end)()

		
		local function Trigger(Numb)
			if StartTrack.IsPlaying == false then return end
			
			local PlayedSound = false
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(17, 7, 17)
			Hitbox.Offset = CFrame.new(0, 0, -5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Countered then return end
				
				if EnemyCharacter:FindFirstChild("Ragdolled") then
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = 0.15,
						["force"] = 30,
						["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.35, 0)
					})
					RagdollHandler.ragdoll(EnemyHumanoid, 1)
				else
					local Count = Numb % 4
					local calc = math.max(Count, 1)
					
					local EnemyStun = StunHandler:Stun(EnemyCharacter, 1, true, 0, 0, true)
					AnimationService:playAnimation(EnemyCharacter, CombatAnims.Hits[calc], 0.7)
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = 0.15,
						["force"] = 45,
						["direction"] = HumRP.CFrame.LookVector
					})
				end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, true, nil, nil)
				
				if not PlayedSound then
					SoundsModule:PlaySound(MoveSounds["Frozen Warrior"]["Potent Cascade"]["Hit" .. Numb], EnemyCharacter.PrimaryPart)
					PlayedSound = true
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end
		
		
		task.delay(0.41, Trigger, 1)
		task.delay(0.85, Trigger, 2)
		task.delay(1.22, Trigger, 3)
		task.delay(1.68, function()
			if StartTrack.IsPlaying == false then return end
			
			local ServerTime = workspace:GetServerTimeNow()
			local GoalCF = HumRP.CFrame * CFrame.new(2, 0, -7)
			local FoundCF = CFrame.new(GoalCF.Position, GoalCF.Position + GoalCF.LookVector * Vector3.new(1, 0, 1))
			
			
			local CFContainer = {
				[1] = FoundCF.Position,
				[2] = (FoundCF * CFrame.new(0, 8, -75)).Position,
				[3] = (FoundCF * CFrame.new(-12.5, 15, -150)).Position,
				[5] = (FoundCF * CFrame.new(-25, 10, -100)).Position,
				[6] = (FoundCF * CFrame.new(-25, 5, -75)).Position,
				[7] = (FoundCF * CFrame.new(-25, 0, 5)).Position,
				[8] = (FoundCF * CFrame.new(-25, 0, 10)).Position
			}
			
			
			for i, CF in CFContainer do
				local RayParams = workspace:Raycast(FoundCF.Position, (CF - FoundCF.Position).Unit * (FoundCF.Position - CF).Magnitude, MapRayParams)
				
				if RayParams then
					CFContainer[i] = RayParams.Position
				end
			end
			
			
			local Bezier = require(ReplicatedModules.Bezier).new(unpack(CFContainer))
			local Projectile = ReplicatedStorage.Resources["Frozen Warrior"].VFX.Base["Potent Cascade"].Projectile:Clone()
			Debris:AddItem(Projectile, 2.5)
			Projectile.Parent = workspace.Thrown
			Projectile.CFrame = FoundCF
			
			
			task.delay(1.5, function()
				for _, obj in Projectile:GetDescendants() do
					if obj:IsA("MeshPart") then
						obj.Transparency = 1
						
					elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
						obj.Enabled = false
						
					end
				end
			end)
			
			
			SoundsModule:PlaySound(MoveSounds["Frozen Warrior"]["Potent Cascade"].AxeSpin, Projectile)
			
			
			coroutine.wrap(function()
				pcall(function()
					for i = 10, 14 do
						Projectile.Axe:ScaleTo(i / 10)
						
						task.wait(0.05)
					end
				end)
			end)()
			
			task.delay(1.2, function()
				pcall(function()
					for i = 14, 1, -1 do
						Projectile.Axe:ScaleTo(i / 10)
						
						task.wait(0.02142857142857143)
					end
				end)
			end)
			
			
			coroutine.wrap(function()
				for i = 1, 20 do
					local Mathed = (i - 1) / 19
					local PosAt = Bezier:CalculatePositionAt(Mathed)
					local DerivativeAt = Bezier:CalculateDerivativeAt(Mathed)
					
					local TweenInf = {
						["CFrame"] = CFrame.new(PosAt, PosAt + DerivativeAt)
					}
					
					TweenService:Create(Projectile, TweenInfo.new(0.15), TweenInf):Play()
					task.wait(0.075)
				end
			end)()
			
			
			local Enemies = {}
			
			
			coroutine.wrap(function()
				repeat
					TweenService:Create(Projectile.Axe.rootPart.Bone, TweenInfo.new(0.15), {
						["C0"] = Projectile.Axe.rootPart.Bone.C0 * CFrame.Angles(0, 3.12413936106985, 0)
					}):Play()
					
					task.wait(0.15)
					
				until not (Projectile and Projectile:IsDescendantOf(workspace))
			end)()
			
			
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = Projectile
			Hitbox.Size = Vector3.new(10, 7.5, 10)
			Hitbox.Offset = CFrame.new(0, 0, 0)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				
				if Enemies then
					if not Enemies[EnemyCharacter] then
						Enemies[EnemyCharacter] = {}
						
						for _, Vel in EnemyCharacter.PrimaryPart:GetDescendants() do
							if Vel:IsA("LinearVelocity") then
								Vel:Destroy()
							end
						end
						
						
						local TimeBetween = 1.4 - (workspace:GetServerTimeNow() - ServerTime)
						local TimerValue = math.max(TimeBetween, 0)
						
						
						SoundsModule:PlaySound(MoveSounds["Frozen Warrior"]["Potent Cascade"]["Hit" .. 4], EnemyCharacter.PrimaryPart)
						local HitBarrage = SoundsModule:PlaySound(MoveSounds["Frozen Warrior"]["Potent Cascade"].HitBarrage, EnemyCharacter.PrimaryPart)
						HitBarrage.TimePosition = workspace:GetServerTimeNow() - ServerTime
						
						
						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
						
						
						local Weld = Instance.new("Weld")
						Debris:AddItem(Weld, TimerValue)
						Weld.Part0 = Projectile.Axe.rootPart
						Weld.Part1 = EnemyCharacter.PrimaryPart
						Weld.Name = "_destroyableOnEvasiveWeld"
						Weld.Parent = EnemyCharacter.PrimaryPart
						
						
						local RanomValue = math.random(-180, 180)
						local RadValue = math.rad(RanomValue)
						
						
						TweenService:Create(Weld, TweenInfo.new(TimerValue * 0.8), {
							["C0"] = CFrame.new(0, 0, -6) * CFrame.Angles(0, RadValue, 0)
						}):Play()
						
						task.delay(TimerValue * 0.8, function()
							TweenService:Create(Weld, TweenInfo.new(TimerValue * 0.2), {
								["C0"] = CFrame.new(0, 0, 0) * CFrame.Angles(0, RadValue, 0)
							}):Play()
						end)
						
						
						Enemies[EnemyCharacter].Weld = Weld
						Enemies[EnemyCharacter].Stun = EnemyStun
						
						AnimationService:stopAll(EnemyCharacter)
					end
				end
			end

			Hitbox:Start(1.4, true)
			
			task.delay(1.41, function()
				for EnemyCharacter: Model, v in Enemies do
					if EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter:GetAttribute("Stunned") == true) then
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
						local PrimaryPart = EnemyCharacter.PrimaryPart
						
						if v.Weld then
							v.Weld:Destroy()
							v.Weld = nil
						end
						
						if v.Stun then
							StunHandler:Unstun(EnemyCharacter, v.Stun)
							v.Stun = nil
						end
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, true, nil, nil)
						PrimaryPart.CFrame = PrimaryPart.CFrame * CFrame.new(-1.5707963267948966, 0, 0)
						knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
							["duration"] = 0.15,
							["force"] = 35,
							["direction"] = Projectile.CFrame.LookVector
						})
						RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
					end
				end
				
				table.clear(Enemies)
				Enemies = nil
			end)
		end)
		
		
		StartTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("PotentCascade", { Char = Character, Stage = "pa", Axe = OldAxe })
	end
}