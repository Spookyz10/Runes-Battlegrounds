local Debris            = game:GetService("Debris")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules    = ServerStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)

local services         = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims            = ServerStorage.Assets.Animations.Moves
local Models               = ServerStorage.Assets.Models
local ReplicateEffects_Set = RemotesContainer.Replicate.Set

return {
	Start = function(Player: Player, Tool: Tool)
		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Dio.Barrage.BarrageStart
		local StartTrack     = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents    = {}

		StartEvents["Spawn"] = StartTrack:GetMarkerReachedSignal("Spawn"):Once(function()

			-- Spawn The World stand in front of player
			local dummy = Models.Dio.TheWorld:Clone()
			dummy.Parent = workspace
			dummy:PivotTo(HumRP.CFrame * CFrame.new(0, 0, -5))

			-- Play barrage anim on stand
			local dummyHumanoid = dummy:FindFirstChildOfClass("Humanoid")
			local dummyAnimator = dummyHumanoid and dummyHumanoid:FindFirstChildOfClass("Animator")
			local BarrageAnim   = MoveAnims.Dio.Barrage.Barrage
			if dummyAnimator and BarrageAnim then
				local dummyTrack = dummyAnimator:LoadAnimation(BarrageAnim)
				dummyTrack:Play()
			end

			-- Keep stand in front of player
			local running = true
			local updateConn
			updateConn = RunService.Heartbeat:Connect(function()
				if not running then updateConn:Disconnect(); return end
				dummy:PivotTo(HumRP.CFrame * CFrame.new(0, 0, -5))
			end)

			-- Fire client to show spawn VFX + sounds
			ReplicateEffects_Set:FireAllClients("DioBarrage", {
				Stage = "spawn",
				char  = Character,
				hrpCF = HumRP.CFrame,
			})

			-- Repeated hitbox loop for 1.9s
			local totalTime = 1.9
			local interval  = 0.1
			local elapsed   = 0

			local standHRP = dummy:FindFirstChild("HumanoidRootPart")

			task.spawn(function()
				while elapsed < totalTime do
					if not dummy or not dummy.Parent then break end

					if standHRP then
						local Hitbox        = {}
						Hitbox.Size         = Vector3.new(6, 6, 8)
						Hitbox.CFrame       = standHRP.CFrame * CFrame.new(0, 0, -4)

						-- Manual overlap check since stand is an NPC not a player
						local params = OverlapParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = { Character, dummy }

						local parts = workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size, params)
						local hit = {}

						for _, part in ipairs(parts) do
							local enemy = part:FindFirstAncestorWhichIsA("Model")
							if enemy and not hit[enemy] and enemy:FindFirstChildOfClass("Humanoid") then
								hit[enemy] = true

								local EnemyHumanoid : Humanoid = enemy:FindFirstChildOfClass("Humanoid")
								local EnemyHumRP    : BasePart = enemy:FindFirstChild("HumanoidRootPart")
								if EnemyHumanoid.Health <= 0 then continue end
								if iFramesService:HasiFrame(enemy, Tool.Name) then continue end

								DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, false, true, false, nil, nil)

								ReplicateEffects_Set:FireAllClients("DioBarrage", {
									Stage   = "hit",
									char    = Character,
									enemy   = enemy,
									enemyCF = EnemyHumRP.CFrame,
								})
							end
						end
					end

					task.wait(interval)
					elapsed += interval
				end

				-- Done — fade out stand
				running = false

				ReplicateEffects_Set:FireAllClients("DioBarrage", {
					Stage = "end",
					char  = Character,
				})

				-- Fade out stand parts
				for _, obj in ipairs(dummy:GetDescendants()) do
					if obj:IsA("BasePart") then
						TweenService:Create(obj, TweenInfo.new(0.5), { Transparency = 1 }):Play()
					elseif obj:IsA("Decal") then
						TweenService:Create(obj, TweenInfo.new(0.5), { Transparency = 1 }):Play()
					end
				end

				Debris:AddItem(dummy, 0.6)
			end)
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}