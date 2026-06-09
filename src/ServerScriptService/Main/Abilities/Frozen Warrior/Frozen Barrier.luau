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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local CounterConnection
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Frozen Barrier"].Main
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local Stopped = false
		local Triggered = false
		local Countering = false
		
		
		local IceShield = Models.Frozen.IceShield:Clone()
		Debris:AddItem(IceShield, 1.28)
		IceShield.Shield.Transparency = 1
		IceShield.Parent = Character
		IceShield:PivotTo(HumRP.CFrame * IceShield.Shield.Bone.C0)
		IceShield.Shield.Bone.Part0 = HumRP

		task.delay(0.2, function()
			if IceShield and not Stopped then
				for _, weld in IceShield.Shield:GetChildren() do
					if weld:IsA("Weld") and weld.Part1 then
						weld.C1 = CFrame.new(0, math.random(-6, 6), math.random(7, 18))
						weld.Part1.Transparency = 0
						
						TweenService:Create(weld, TweenInfo.new(math.random(3, 8) / 10), {
							["C1"] = CFrame.new(Vector3.new(0, 0, 0))
						}):Play()
					end
				end
			end
		end)
		
		task.delay(0.233, function()
			if IceShield and not Stopped then
				local Size = IceShield.Shield.Size
				IceShield.Shield.Size = Vector3.new(0, 0, 0)
				IceShield.Shield.Transparency = 0
				
				TweenService:Create(IceShield.Shield, TweenInfo.new(0.5), {
					["Size"] = Size
				}):Play()
			end
		end)
		
		
		local function Counter(child)
			if Countering then
				print("firedx2")
				
				local Cooked = false
				local function Boom(EnemyCharacter: Model)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					
					if not Cooked then
						Cooked = true
						local EnemyStun = StunHandler:Stun(EnemyCharacter, 0.1, true, 1, 0, true)
					end
					
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, true, nil, nil)
					local v39 = {
						["duration"] = 0.2,
						["force"] = 21,
						["direction"] = CFrame.new(HumRP.CFrame.Position * Vector3.new(1, 0, 1), EnemyCharacter.PrimaryPart.Position * Vector3.new(1, 0, 1)).LookVector + Vector3.new(0, 0.4, 0)
					}
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, v39)
					RagdollHandler.ragdoll(EnemyHumanoid, Triggered and 2 or 1)
				end
				if child then
					Boom(child.Value)
				end
				
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP.CFrame
				Hitbox.Size = Vector3.new(16, 8, 16)
				Hitbox.Offset = CFrame.new(0, 0, -2)
				Hitbox.Ignore = { Character }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					Boom(EnemyCharacter)
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
				
			end
		end
		
		
		IceShield.Destroying:Connect(function()
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Magnitude = 5, Roughness = 8, FadeInTime = 0, FadeOutTime = 0.4 })
			
			local GlassBreak = ReplicatedStorage.Resources["Frozen Warrior"].VFX.Base["Frozen Barrier"].GlassBreak:Clone()
			Debris:AddItem(GlassBreak, 4)
			GlassBreak.Parent = workspace.Thrown
			GlassBreak.CFrame = HumRP.CFrame * GlassBreak.Offset.C0

			task.delay(0.02, function()
				for _, v49 in GlassBreak:GetDescendants() do
					VfxUtility.emit_effect(v49)
				end
			end)

			SoundsModule:PlaySound(MoveSounds["Frozen Warrior"]["Frozen Barrier"].Burst, GlassBreak)

			local Cracked = Models.Frozen.IceShield.Cracked:Clone()
			Debris:AddItem(Cracked, 4)
			Cracked:PivotTo(HumRP.CFrame * CFrame.new(-0.021, 0.756, -1.5))
			Cracked.Parent = workspace.Thrown
			
			
			for _, part in Cracked:GetChildren() do
				if part:IsA("BasePart") then
					part.Transparency = 0
					local GoalCF = HumRP.CFrame
					local AnglesFunc = CFrame.Angles
					local Random20to50 = math.random(20, 50)
					local mathrad = math.rad(Random20to50)
					local ramdom30to30 = math.random(-30, 30)
					local mathrad30 = math.rad(ramdom30to30)
					local ramdom90to90 = math.random(-90, 90)
					
					part.AssemblyLinearVelocity = (GoalCF * AnglesFunc(mathrad, mathrad30, (math.rad(ramdom90to90)))).LookVector * math.random(10, 40)
				end
			end
			
			if not Triggered then
				Counter()
				
				print("fired")
			end
		end)
		
		
		task.delay(0.2, function()
			Countering = true
			Character:AddTag("Countering")
			
			CounterConnection = Character.ChildAdded:Connect(function(child: ObjectValue?)
				if child.Name == 'DamagedLog' and child:HasTag('Counterable') then
					Character:RemoveTag("Countering")
					CounterConnection:Disconnect()
					CounterConnection =  nil
					
					Triggered = true
					
					if IceShield then
						IceShield:Destroy()
						IceShield = nil
					end
					
					Counter(child)
				end
			end)
			
			task.delay(0.9, function()
				if CounterConnection then
					CounterConnection:Disconnect()
					CounterConnection = nil
				end
			end)
		end)
		
		
		StartTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)

			if CounterConnection then
				CounterConnection:Disconnect()
				CounterConnection = nil
			end

			Character:RemoveTag("Countering")

			Stopped = true
			if IceShield then
				IceShield:Destroy()
				IceShield = nil
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("FrozenBarrier", { Char = Character, Stage = "pa", model = IceShield })
	end
}