local ServerStorage = game:GetService('ServerStorage') 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StunHandler = require(ServerStorage.Modules.StunHandler)
local HitboxHandler = require(ServerStorage.Modules.HitboxHandler)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local RagdollHandler = require(ServerStorage.Modules.RagdollHandler)
local NewKnockback = require(ServerStorage.Modules.BodymoverService)
local AnimationService = require(ServerStorage.Modules.AnimationService)
local iFramesService = require(ServerStorage.Modules.iFramesService)
local WeaponsHandler = require(ServerStorage.Modules.WeaponsHandler)
local CollisionsModule = require(ServerStorage.Modules.CollisionsModule)
local SoundsModule = require(ServerStorage.Modules.SoundsModule)
local KnockbackModule = require(ServerStorage.Modules.KnockbackModule)
local ReplicatedHitboxes = require(ServerStorage.Modules.ReplicatedHitboxes)
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)

local Utility = require(ReplicatedStorage.Modules.Utility)
local WeldSystem = require(ReplicatedStorage.Modules.WeldSystem)


local Assets = ServerStorage.Assets

local Sounds = Assets.Sounds
local Animations = Assets.Animations
local Models = Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves


local ComSet = ReplicatedStorage.Remotes.Comunicator.Set
local ComGet = ReplicatedStorage.Remotes.Comunicator.Get


local ReplicateEffects_Set = ReplicatedStorage.Remotes.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = ServerStorage.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		if Player:GetAttribute("DamageNeed") and Player:GetAttribute("DamageNeed") >= 1 then
			Player.AwakeningProgress.Value = 0
			Player:SetAttribute("DamageNeed", 0)
			
			local SideEnemyPlayer = nil
			local EnemyCharacters = {}
			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			local MainCF = Character:GetPivot()
			Character:AddTag("CantRotate")
			HumRP.Anchored = true
			Character.Archivable = true
			iFramesService:AddAlliFrames(Character)
			CollisionsModule:SetCollisionGroup(Character, "NoCol")
			
			local Animation = ReplicatedStorage.Resources.KJ.UFW.User
			local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
			local AnimationEvents = {}
			
			local Whitelist = {
				Character,
			}
			
			local GotClone
			local CloneGot
			
			local DomainSphere = ReplicatedStorage.Resources.KJ.UFW.DomainSphere:Clone()
			DomainSphere.Parent = workspace.Thrown
			DomainSphere.CFrame = MainCF
			
			local usingufw = Instance.new("Accessory")
			usingufw.Name = "usingufw"
			usingufw.Parent = Character
			
			Debris:AddItem(usingufw,29.46)
			Debris:AddItem(DomainSphere,31)
			
			spawn(function()
				wait(3)
				
				DomainSphere.Position = MainCF.Position
				DomainSphere.Transparency = 0
				
				delay(21,function()
					TweenService:Create(DomainSphere,TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.In),{
						Color = Color3.new(255,255,255)
					}):Play()
					DomainSphere.Material = Enum.Material.Neon
				end)
				
				delay(22,function()
					TweenService:Create(DomainSphere,TweenInfo.new(0.45,Enum.EasingStyle.Cubic,Enum.EasingDirection.In),{
						Transparency = 1
					}):Play()
					wait(0.45)
					
					if DomainSphere then
						DomainSphere:Destroy()
						DomainSphere = nil
					end
				end)
			end)
			
			delay(8.3,function()
				local Description = game.Players:GetHumanoidDescriptionFromUserId(Player.UserId)
				GotClone = ReplicatedStorage.Resources.KJ.UFW.Rig:Clone()
				GotClone:PivotTo(MainCF + MainCF.LookVector * 2)
				GotClone.Root.Anchored = true
				GotClone.Parent = workspace.Thrown
				delay(2,function()
					for _, GotHumanoid:Humanoid in pairs(GotClone:GetDescendants()) do
						if GotHumanoid:IsA("Humanoid") then
							GotHumanoid:ApplyDescription(Description)
						end
					end
				end)

				Debris:AddItem(GotClone,16)

				CloneGot = Instance.new("ObjectValue")
				CloneGot.Name = "CloneGot"
				CloneGot.Value = GotClone
				CloneGot.Parent = Character

				Debris:AddItem(CloneGot,15)
			end)
			
			AnimationEvents["Hit"] = AnimationTrack:GetMarkerReachedSignal("Hit"):Once(function()
				if DomainSphere then
					DomainSphere:Destroy()
					DomainSphere = nil
				end
				if CloneGot then
					CloneGot:Destroy()
					CloneGot = nil
				end
				if GotClone then
					GotClone:Destroy()
					GotClone = nil
				end
				
				local function Damage(EnemyCharacter, Value)
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					DamageHandler:TakeDamage(Character, EnemyHumanoid, Value, nil, nil, false, false, true, false, true, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = HumRP.CFrame.LookVector * Vector3.new(500, 0, 500) + Vector3.new(0, 250, 0) })
				end

				for _, Info: { Char: Model, Stun: BoolValue } in EnemyCharacters do
					local EnemyCharacter = Info.Char
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					
					StunHandler:Unstun(Character, Info.Stun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag("CantRotate")
					CollisionsModule:SetCollisionGroup(Character, "Players")
					EnemyHumRP.Anchored = false
					
					Damage(EnemyCharacter, 100)
				end
				
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(100, 100, 1000)
				Hitbox.Offset = CFrame.new(0, 47, -500)
				Hitbox.Ignore = { Character, table.unpack(EnemyCharacters) }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(100, 100, 1000) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end


					Damage(EnemyCharacter, math.random(60, 70))
				end

				Hitbox:Once()
				Hitbox:Destroy()
				
				ReplicateEffects_Set:FireAllClients("finalPunch", { Already = Whitelist, Char = Character })
				
				SoundsModule:PlaySound(MoveSounds.KJ.UFW.Final, HumRP.CFrame)
				Player.AwakeningProgress.Value = 0
				
				local ignoreContainer = {}
				local humanoidContainer = {}
				local partContainer = {}

				for _, part in pairs(workspace:GetPartBoundsInRadius(Character.PrimaryPart.Position, 350)) do
					if (part:GetAttribute("IsTree") or part.Name == "TreeRoot") and not table.find(ignoreContainer, part.Parent) then
						ReplicateEffects_Set:FireAllClients("shakeTree", { Tree = part.Parent, Intensity = Random.new():NextNumber(5, 10), From = Character.PrimaryPart.Position })
					end

					local targetHumanoid = part.Parent:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Name ~= "FakeHumanoid" and not table.find(humanoidContainer, targetHumanoid) and targetHumanoid ~= Humanoid then
						table.insert(partContainer, part.Parent)
					end
				end
			end)
			
			ReplicateEffects_Set:FireClient(Player, "flexWorks", { char = Character, Position = MainCF.Position })
			ReplicateEffects_Set:FireAllClients("domainSphere", { Char = Character, Blacklist = Whitelist, Position = MainCF.Position, Radius = 40.25, TotalParts = 150 })
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(85, 85, 85)
			Hitbox.Offset = CFrame.new(0, 0, 0)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				
				SideEnemyPlayer = EnemyPlayer
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				EnemyCharacters[#EnemyCharacters + 1] = { Char = EnemyCharacter, Stun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true) }
				table.insert(Whitelist, EnemyCharacter)
				
				iFramesService:AddAlliFrames(EnemyCharacter)
				EnemyCharacter:AddTag("CantRotate")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				EnemyHumRP.Anchored = true
				
				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "flexWorks", { char = Character, Position = MainCF.Position })
				end
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			AnimationTrack.Stopped:Once(function()
				for _,v in AnimationEvents do
					v:Disconnect()
				end
				
				if DomainSphere then DomainSphere:Destroy()	DomainSphere = nil end
				if CloneGot then CloneGot:Destroy() CloneGot = nil end
				if GotClone then GotClone:Destroy() GotClone = nil end
				
				Character:PivotTo(MainCF)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				iFramesService:RemoveAlliFrames(Character)
				HumRP.Anchored = false
				Character:RemoveTag("CantRotate")
				StunHandler:Unstun(Character, Stun)
				
				shared.fireTo(ReplicateEffects_Set, { Player, SideEnemyPlayer }, { 'cameraType' })
				
				SideEnemyPlayer = nil
			end)
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, Animation)
			
			task.delay(3, function()
				AnimationTrack.TimePosition = 3
			end)
			
			StatesHandler.SkillText(Player, "UNLIMITED FLEX WORKS [USED]")
		end
	end
}