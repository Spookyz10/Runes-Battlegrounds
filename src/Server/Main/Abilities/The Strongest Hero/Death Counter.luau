local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)

local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local StatesHandler = require(ServerModules.StatesHandler)

local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local Trove = require(ReplicatedModules.Trove)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		Player.AwakeningProgress.Value = 0

		Character:AddTag("Countering")
		Character:AddTag("DEATH")

		local Hit = false
		local CounterConnection: RBXScriptConnection
		local MenacingFolder

		local function stopCounter()
			if CounterConnection then
				CounterConnection:Disconnect()
			end
			Character:RemoveTag("Countering")
			Character:RemoveTag("DEATH")
		end

		MenacingFolder = Instance.new("Folder", Character)
		ReplicateEffects_Set:FireClient(Player, "Menacing", { Char = Character, Time = 10, Folder = MenacingFolder })
		ReplicateEffects_Set:FireClient(Player, "SetAwkbar", { State = true })

		local function handleHit(child)
			if child.Name == "DamagedLog" and child:HasTag("Counterable") then
				CounterConnection:Disconnect()

				local EnemyCharacter: Model = child.Value
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				Hit = true

				local playerClass = shared.playerClasses[Player.UserId]
				if playerClass then
					playerClass.TitlesProgress.Counters += 1
					Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.Counters)
				end

				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = false } })
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "deathPunchMusic", { Stage = "Start" } })

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				if MenacingFolder and MenacingFolder.Parent then
					MenacingFolder:Destroy()
				end

				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")

				local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

				local UserAnimation = MoveAnims.BaldHero["Death Counter"].User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)

				HumRP.Anchored = true
				EnemyHumRP.Anchored = true

				ReplicateEffects_Set:FireAllClients("deathPunchFace", { Char = Character })
				shared.fireTo(
					ReplicateEffects_Set,
					{ Player, EnemyPlayer },
					{ "deathPunch", { Caller = EnemyCharacter, Root = HumRP, Char = Character, Head = Character.Head } }
				)

				local VictimAnimation = MoveAnims.BaldHero["Death Counter"].Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

				task.delay(0.1, function()
					VictimTrack:AdjustSpeed(0.008)
					UserTrack:AdjustSpeed(0.008)

					shared.fireTo(
						ReplicateEffects_Set,
						{ Player, EnemyPlayer },
						{ "deathScreenCamera", { Char = Character } }
					)

					task.delay(3, function()
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "deathScreen", { User = Character, Root = HumRP } }
						)

						task.delay(0.5, function()
							shared.fireTo(
								ReplicateEffects_Set,
								{ Player, EnemyPlayer },
								{ "deathScreenSound", { Stage = "Start" } }
							)
						end)
					end)

					task.delay(5.37, function()
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "deathScreen2", { User = Character } }
						)
					end)

					Character.Archivable = true

					local Clone = Character:Clone()
					Clone.Parent = workspace.Thrown

					game.TweenService
						:Create(HumRP, TweenInfo.new(0.1), {
							["CFrame"] = EnemyHumRP.CFrame * CFrame.new(0, 0, 3.5),
						})
						:Play()

					for i, v in pairs(Clone:GetDescendants()) do
						if v:IsA("BasePart") or v:IsA("Part") or v.Name == "Handle" then
							game.TweenService
								:Create(v, TweenInfo.new(1), {
									Transparency = 1,
								})
								:Play()
						end
					end

					task.delay(1, function()
						Clone:Destroy()
					end)

					task.delay(0.5, function()
						HumRP.Anchored = false
						EnemyHumRP.Anchored = false
					end)
				end)

				task.delay(1, function()
					VictimTrack:AdjustSpeed(0.001)
					UserTrack:AdjustSpeed(0.001)
				end)

				task.delay(5.35, function()
					VictimTrack:AdjustSpeed(0.009)
					UserTrack:AdjustSpeed(0.009)
				end)

				task.delay(8, function()
					VictimTrack:AdjustSpeed(0.9)
					UserTrack:AdjustSpeed(0.9)

					task.delay(3, function()
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true } })
					end)

					task.delay(0.439, function()
						local Weld = WeldSystem.new(
							HumRP,
							EnemyHumRP,
							CFrame.new(0, 0, -2.5) * CFrame.Angles(0, rad(-180), 0),
							6
						)
						Weld:Start()

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
					end)

					task.delay(0.45, function()
						task.delay(0.5, function()
							ReplicateEffects_Set:FireAllClients(
								"fistSmoke",
								{ Dur = 5, Heat = true, Char = Character, Part = Character }
							)
						end)

						ReplicateEffects_Set:FireAllClients(
							"debrisLines",
							{ Part = HumRP, Char = Character, Serious = true }
						)

						local humrpCF2 = HumRP.CFrame * CFrame.Angles(math.rad(90), 0, 0)

						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(20, 0, 20), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(30, 0, 30), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(40, 0, 40), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(50, 0, 50), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(70, 0, 70), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(100, 0, 100), Transparency = 1 },
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ring",
							{
								FirstProps = { Size = Vector3.new(0, 3, 0), Transparency = 0 },
								CF = humrpCF2,
								TN_Info = { Time = 1, Style = "Quad", Direction = "Out" },
								FinalProps = { Size = Vector3.new(130, 0, 130), Transparency = 1 },
							}
						)

						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							100,
							nil,
							nil,
							false,
							false,
							nil,
							false,
							true
						)
						RagdollHandler.ragdoll(EnemyHumanoid, 4.5, false, Character)
						NewKnockback:Knockback(
							EnemyCharacter,
							{
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(1, 1, 1) * math.huge,
								Velocity = Vector3.new(
									HumRP.CFrame.LookVector.X * 215,
									85,
									HumRP.CFrame.LookVector.Z * 215
								),
							}
						)
					end)
				end)

				UserTrack.Stopped:Once(function()
					Character:RemoveTag("CantRotate")
					Character:RemoveTag("DEATH")
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
				end)

				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, UserAnimation)
			end
		end

		CounterConnection = Character.ChildAdded:Connect(handleHit)

		task.delay(10, function()
			stopCounter()
		end)

		StatesHandler.SkillText(Player, "DEATH COUNTER [USED]")
	end,
}
