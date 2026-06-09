-- [[ Services ]]:

local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

-- [[ Modules ]]:

local ServerModules = serverStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local SoundsModule = require(ServerModules.SoundsModule)

local replication = replicatedStorage.Replicated

-- [[ Assets ]]:

local sukuna = replicatedStorage.Resources.Sukuna
local flameArrow = sukuna.FlameArrowFolder

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, 15, false, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		-- [[ Animation ]]:
		AnimationService:stopAll(Character)
		local MainTrack = AnimationService:playAnimation(Character, sukuna.flameArrow)

		-- [[ Sound ]]:
		SoundsModule:PlaySound(sukuna.fuga_start_shoot, HumRP)

		-- [[ Event folder for client VFX sync ]]:
		local EventFolder = Instance.new("Folder")
		EventFolder.Name = "FlameArrowEvents"
		EventFolder.Parent = Character

		local function AddEvent(name)
			local tag = Instance.new("Accessory")
			tag.Name = name
			tag.Parent = EventFolder
		end

		-- [[ Projectile hit hitbox ]]:
		local function ProjectileHit(pos: CFrame)
			if typeof(pos) ~= "CFrame" then return end

			local hitChars = {}
			local startTime = tick()

			repeat
				if not Character.Parent then break end

				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Offset = pos
				Hitbox.Size = Vector3.new(444.853, 175.515, 175.515)
				Hitbox.Ignore = { Character }

				Hitbox.onTouch = function(EnemyCharacter: Model)
					if hitChars[EnemyCharacter] then return end
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
					if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

					hitChars[EnemyCharacter] = true

					NewKnockback:Knockback(EnemyCharacter, {
						KnockbackType = "VelocityTweenDown",
						MaxForce = Vector3.new(50000, 50000, 50000),
						Velocity = EnemyHumRP.CFrame.UpVector * 40,
						Time = 0.1,
					})

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, true, true, false, nil, nil)

					if not EnemyCharacter:GetAttribute("Ragdolled") then
						RagdollHandler.ragdoll(EnemyHumanoid, 4)
					end
				end

				Hitbox:Once()
				Hitbox:Destroy()
				task.wait(0.1)
			until tick() - startTime > 3
		end

		-- [[ Create projectile & fire to clients ]]:
		local function CreateProjectile()
			local projValue = Instance.new("CFrameValue")
			projValue.Value = HumRP.CFrame * CFrame.new(0, 3, -3)
			projValue.Parent = Character

			-- Marker 3 fires the projectile
			MainTrack:GetMarkerReachedSignal("3"):Once(function()
				local Raycast = game:GetService("Workspace"):Raycast(
					projValue.Value.Position,
					projValue.Value.LookVector * 1000
				)

				local duration: number
				local targetCF: CFrame

				if Raycast then
					local distance = (projValue.Value.Position - Raycast.Position).Magnitude
					duration = math.max(distance / 300, 0.1)
					targetCF = CFrame.new(Raycast.Position)
				else
					duration = 5
					targetCF = CFrame.new(projValue.Value.LookVector * 1000)
				end

				local tween = game:GetService("TweenService"):Create(projValue, TweenInfo.new(duration), {
					Value = targetCF
				})
				tween:Play()

				-- Tell clients to render the projectile
				replication:FireAllClients({ "Require", "Projectile" }, projValue, flameArrow.projectileArrow)

				tween.Completed:Once(function()
					-- VFX explosion on all clients
					replication:FireAllClients({ "VFXS", "Sukuna", "flameArrow" }, nil, nil, projValue.Value.Position, true)

					task.wait(0.7)

					replication:FireAllClients({ "Require", "impactFrame" }, 15, { projValue.Value, 300 })
					replication:FireAllClients(
						{ "Require", "newCameraShake" },
						{ { 2, 25, 0, 5 }, Vector3.yAxis * 30 + Vector3.xAxis * 30 },
						{ projValue.Value, 1000 }
					)

					ProjectileHit(projValue.Value)
					projValue:Destroy()
				end)
			end)
		end

		-- [[ Marker events ]]:
		MainTrack:GetMarkerReachedSignal("1"):Once(function()
			replication:FireClient(Player, { "Require", "screenEffect" }, MainTrack.Length - 2)
			AddEvent("1")
		end)

		MainTrack:GetMarkerReachedSignal("2"):Once(function()
			replication:FireClient(Player, { "Require", "newCameraShake" }, { { 1, 5, 0, 3 }, Vector3.yAxis * 5 + Vector3.xAxis * 5 })
			CreateProjectile()
			AddEvent("2")
		end)

		MainTrack:GetMarkerReachedSignal("3"):Once(function()
			replication:FireClient(Player, { "Require", "fieldOfView" }, false, 200)
			replication:FireClient(Player, { "Require", "fieldOfView" }, true, 70, 1.5, Enum.EasingStyle.Linear)
			replication:FireAllClients({ "Require", "impactFrame" }, 2, { HumRP, 100 })
			AddEvent("3")
		end)

		-- [[ Trigger client VFX module ]]:
		replication:FireAllClients({ "VFXS", "Sukuna", "flameArrow" }, Character, EventFolder)

		-- [[ Cleanup ]]:
		MainTrack.Stopped:Once(function()
			EventFolder:Destroy()
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)
	end
}