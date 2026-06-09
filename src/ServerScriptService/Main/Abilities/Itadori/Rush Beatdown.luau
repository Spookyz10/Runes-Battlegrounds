-- [[ Services ]]:

local serverStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- [[ Modules ]]:

local ServerModules = serverStorage.Modules
local ReplicatedModules = replicatedStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local SoundsModule = require(ServerModules.SoundsModule)

local replication = replicatedStorage.Replicated
local ReplicateEffects_Set = replicatedStorage.Remotes.Replicate.Set

-- [[ Assets ]]:

local sukuna = replicatedStorage.Resources.Sukuna

-- [[ Hitbox configs per marker ]]:
local hitboxes = {
	[1]  = { offset = CFrame.new(0,0,0),    size = Vector3.new(10,10,10)  },
	[2]  = { offset = CFrame.new(0,0,-3),   size = Vector3.new(10,10,10)  },
	[3]  = { offset = CFrame.new(0,0,-3),   size = Vector3.new(12,12,12)  },
	[4]  = { offset = CFrame.new(0,0,0),    size = Vector3.new(12,12,12)  },
	[5]  = { offset = CFrame.new(0,0,0),    size = Vector3.new(15,15,15)  },
	[6]  = { offset = CFrame.new(0,0,0),    size = Vector3.new(20,20,20)  },
	[7]  = { offset = CFrame.new(0,0,-1.5), size = Vector3.new(10,10,10)  },
	[8]  = { offset = CFrame.new(0,0,0),    size = Vector3.new(36.292, 7.667, 19.583) },
	[9]  = { offset = CFrame.new(0,0,-3),   size = Vector3.new(10,10,10)  },
	[10] = { offset = CFrame.new(0,0,0),    size = Vector3.new(36.292, 7.667, 19.583) },
}

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local MainEvents = {}

		-- [[ Helper: create hitbox for a given marker number ]]:
		local function createHitbox(MainTrack, markerNum)
			local config = hitboxes[markerNum]
			if not config then return end

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.Size = config.size
			Hitbox.Offset = config.offset

			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyPlayer = players:GetPlayerFromCharacter(EnemyCharacter)

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

				if EnemyCharacter:FindFirstChild("CounterObject") or EnemyCharacter:GetAttribute("DodgesEnabled") == true then
					local newValue = Instance.new("ObjectValue")
					newValue.Value = Character
					newValue.Name = "HitCounter"
					newValue.Parent = EnemyCharacter
					return
				end

				-- [[ Hits 1-5: light damage ]]:
				if markerNum < 5 then
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)

					-- [[ Hits 6-10: heavy damage + ragdoll + body position ]]:
				elseif markerNum >= 6 then
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 8, nil, nil, false, false, true, true, false, nil, nil)

					if not EnemyHumRP:FindFirstChildOfClass("BodyPosition") then
						RagdollHandler.ragdoll(EnemyHumanoid, 15)

						local bodyPosition = Instance.new("BodyPosition")
						bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bodyPosition.P = 300000
						bodyPosition.D = 10000
						bodyPosition.Parent = EnemyHumRP

						game:GetService("Debris"):AddItem(bodyPosition, 5)

						task.spawn(function()
							while task.wait() and Character.Parent and bodyPosition.Parent and MainTrack.IsPlaying do
								bodyPosition.Position = HumRP.Position
									+ HumRP.CFrame.LookVector * math.random(5, 10)
									+ HumRP.CFrame.UpVector * math.random(1, 10)
							end
						end)
					end

					-- [[ Final hit marker 10: big knockback ]]:
					MainEvents["10_final"] = MainTrack:GetMarkerReachedSignal("10"):Once(function()
						if EnemyHumRP and EnemyHumRP.Parent then
							local bp = EnemyHumRP:FindFirstChildOfClass("BodyPosition")
							if bp then bp:Destroy() end

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, nil)

							NewKnockback:Knockback(EnemyCharacter, {
								KnockbackType = "VelocityTweenDown",
								MaxForce = Vector3.new(math.huge, math.huge, math.huge),
								Velocity = HumRP.CFrame.LookVector * 100,
								Time = 0.1,
							})
						end
					end)
				end

				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", {
						Intensity = markerNum >= 6 and 2 or 1,
						Last = 0.15,
					})
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end

		-- [[ Play Anim ]]:
		AnimationService:stopAll(Character)
		local MainTrack = AnimationService:playAnimation(Character, sukuna.rushBeatdown)

		-- [[ Sound ]]:
		SoundsModule:PlaySound(sukuna.rushBeatdownSound, HumRP)

		-- [[ VFX ]]:
		replication:FireAllClients({ "VFXS", "Sukuna", "rushBeatdown" }, Character)

		-- [[ Wire up markers 1-10 ]]:
		for i = 1, 10 do
			local markerNum = i
			MainEvents[tostring(i)] = MainTrack:GetMarkerReachedSignal(tostring(i)):Connect(function()
				if markerNum >= 9 then
					replication:FireAllClients({ "Require", "impactFrame" }, 3 + markerNum - 5, { HumRP, 10 })
				end
				createHitbox(MainTrack, markerNum)
			end)
		end

		-- [[ Anim ended ]]:
		MainTrack.Stopped:Once(function()
			for _, v in MainEvents do
				v:Disconnect()
			end
			StunHandler:Unstun(Character, Stun)
		end)
	end
}