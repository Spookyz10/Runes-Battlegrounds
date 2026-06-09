return {
	Start = function(Player: Player, Tool: Tool)
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")
		local RunService = game:GetService("RunService")
		local ServerStorage = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local PlayersService = game:GetService("Players")
		local Lighting = game:GetService("Lighting")

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
		local CollisionsModule = require(ServerModules.CollisionsModule)
		local WeldSystem = require(ReplicatedModules.WeldSystem)

		local MoveAnims = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Skill5Template = ReplicatedStorage.Resources.BakugoAssets.Effects.Explosion.Skill5

		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local Hit = false

		-- [[ Startup hitbox only — no animation ]]:
		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(6, 6, 6)
		Hitbox.Offset = CFrame.new(0, 0, -4)
		Hitbox.Ignore = { Character }
		Hitbox.onTouch = function(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if Hit or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
			Hit = true
			Hitbox:Destroy()

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			-- [[ Position setup ]]:
			local originalPlayerPos = HumRP.Position
			local direction = Vector3.new(
				EnemyHumRP.Position.X - HumRP.Position.X,
				0,
				EnemyHumRP.Position.Z - HumRP.Position.Z
			)
			if direction.Magnitude < 2 then direction = HumRP.CFrame.LookVector end
			local offset = direction.Unit * 4

			HumRP.Anchored = true
			EnemyHumRP.Anchored = true
			HumRP.CFrame = CFrame.new(originalPlayerPos)
			EnemyHumRP.CFrame = CFrame.new(originalPlayerPos + offset)
			task.wait(0.03)

			local Weld = WeldSystem.new(HumRP, EnemyHumRP,
				CFrame.new(-offset.X, -offset.Y, -offset.Z), -1)

			-- [[ Initial damage ]]:
			DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, nil)

			-- [[ Play animations ONLY on hit ]]:
			local PlayerAnimation = MoveAnims.Bakugo["Final Burst"].Player
			local PlayerTrack = AnimationService:getAnimationTrack(Character, PlayerAnimation)
			local VictimAnimation = MoveAnims.Bakugo["Final Burst"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

			-- [[ Skill5 VFX ]]:
			local cloneSkill5 = Skill5Template:Clone()
			cloneSkill5.Parent = workspace.Effects
			local hrpCF = HumRP.CFrame
			pcall(function()
				if cloneSkill5:FindFirstChild("Skill5Cut") and cloneSkill5.Skill5Cut.PrimaryPart then
					cloneSkill5.Skill5Cut:PivotTo(hrpCF)
				end
				if cloneSkill5:FindFirstChild("Model") and cloneSkill5.Model.PrimaryPart then
					cloneSkill5.Model:PivotTo(hrpCF)
				end
				if cloneSkill5:FindFirstChild("BlackGuy") and cloneSkill5.BlackGuy.PrimaryPart then
					cloneSkill5.BlackGuy:PivotTo(hrpCF)
				end
			end)
			for _, part in pairs(cloneSkill5:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.Anchored = true
				end
			end

			-- [[ Hide map ]]:
			ReplicateEffects_Set:FireAllClients("BakugoFinalBurst", {
				char = Character,
				enemy = EnemyCharacter,
				stage = "Start",
				id = PlayerAnimation.AnimationId,
			})

			local function setEnabled(root, enabled)
				if not root then return end
				for _, obj in pairs(root:GetDescendants()) do
					if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then obj.Enabled = enabled end
				end
			end

			local function emitGroup(root)
				if not root then return end
				for _, v in pairs(root:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						task.spawn(function()
							local d = v:GetAttribute("EmitDelay")
							if type(d) == "number" and d > 0 then task.wait(d) end
							local c = v:GetAttribute("EmitCount")
							if type(c) == "number" and c > 0 then v:Emit(c) end
						end)
					end
				end
			end

			local sc = cloneSkill5:FindFirstChild("Skill5Cut")

			task.spawn(function()
				if cloneSkill5:FindFirstChild("BlackGuy") then
					for _, v in pairs(cloneSkill5.BlackGuy:GetDescendants()) do
						if v:IsA("BasePart") then v.Transparency = 1 end
					end
				end
				if sc then
					setEnabled(sc:FindFirstChild("Atmosphere3"), true)
					setEnabled(sc:FindFirstChild("RainZoneVFX2"), true)
				end
			end)

			task.delay(0.683, function()
				if not sc then return end
				setEnabled(sc:FindFirstChild("Atmosphere3"), false)
				setEnabled(sc:FindFirstChild("RainZoneVFX2"), false)
				local bgWhite = sc:FindFirstChild("BGWhite")
				if bgWhite then bgWhite.Transparency = 0 end
				local function emitAndEnable(g)
					if not g then return end
					for _, v in pairs(g:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							local c = v:GetAttribute("EmitCount")
							if type(c) == "number" and c > 0 then v:Emit(c) end
							v.Enabled = true
						end
					end
				end
				emitAndEnable(sc:FindFirstChild("RainStop"))
				emitAndEnable(sc:FindFirstChild("RainAtmosphere"))
				local warp = sc:FindFirstChild("Warp")
				if warp then
					for _, v in pairs(warp:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							local c = v:GetAttribute("EmitCount")
							if type(c) == "number" and c > 0 then v:Emit(c) end
							v.TimeScale = 0.1
						end
					end
				end
			end)

			task.delay(0.85, function()
				if not sc then return end
				local rainAtmos = sc:FindFirstChild("RainAtmosphere")
				if rainAtmos then
					for _, v in pairs(rainAtmos:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 0 end
					end
				end
			end)

			task.delay(3.167, function()
				if not sc then return end
				local bgBlack = sc:FindFirstChild("BGBlack")
				if bgBlack then bgBlack.Transparency = 0 end
				local warp = sc:FindFirstChild("Warp")
				if warp then
					for _, v in pairs(warp:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 1 end
					end
				end
				local rainAtmos = sc:FindFirstChild("RainAtmosphere")
				if rainAtmos then
					for _, v in pairs(rainAtmos:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.Enabled = false; v.TimeScale = 1 end
					end
				end
			end)

			task.delay(3.383, function()
				if cloneSkill5:FindFirstChild("BlackGuy") then
					for _, v in pairs(cloneSkill5.BlackGuy:GetDescendants()) do
						if v:IsA("BasePart") then v.Transparency = 0 end
					end
				end
				for _, v in pairs(Character:GetDescendants()) do
					if v:IsA("BasePart") then v.Transparency = 1 end
					if v:IsA("Accessory") then
						local h = v:FindFirstChild("Handle")
						if h then h.Transparency = 1 end
					end
				end
				if sc then
					local bgBlack = sc:FindFirstChild("BGBlack")
					if bgBlack then
						for _, pe in pairs(bgBlack:GetDescendants()) do
							if pe:IsA("ParticleEmitter") then
								local c = pe:GetAttribute("EmitCount")
								if type(c) == "number" and c > 0 then pe:Emit(c) end
							end
						end
					end
				end
			end)

			task.delay(3.4, function()
				if sc then
					local bgWhite = sc:FindFirstChild("BGWhite")
					if bgWhite then
						TweenService:Create(bgWhite, TweenInfo.new(0.967, Enum.EasingStyle.Linear), {
							Color = Color3.fromRGB(0, 0, 0)
						}):Play()
					end
				end
			end)

			task.delay(3.767, function()
				if sc and sc:FindFirstChild("BGBlack") then sc.BGBlack.Transparency = 1 end
			end)

			task.delay(4.333, function()
				for _, v in pairs(Character:GetDescendants()) do
					if v:IsA("BasePart") then v.Transparency = 0 end
					if v:IsA("Accessory") then
						local h = v:FindFirstChild("Handle")
						if h then h.Transparency = 0 end
					end
				end
				if cloneSkill5:FindFirstChild("BlackGuy") then
					for _, v in pairs(cloneSkill5.BlackGuy:GetDescendants()) do
						if v:IsA("BasePart") then v.Transparency = 1 end
					end
				end
			end)

			task.delay(4.367, function()
				if not sc then return end
				local rainStop = sc:FindFirstChild("RainStop")
				if rainStop then
					for _, v in pairs(rainStop:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 0 end
					end
				end
				local bgWhite = sc:FindFirstChild("BGWhite")
				if bgWhite then bgWhite.Transparency = 1 end
			end)

			task.delay(4.817, function()
				if sc then emitGroup(sc:FindFirstChild("Soru")) end
			end)

			task.delay(6.283, function()
				if sc then
					emitGroup(sc:FindFirstChild("IMP1"))
					setEnabled(sc:FindFirstChild("AtmosphereSL0"), true)
				end
			end)

			task.delay(7.167, function()
				if sc and sc:FindFirstChild("PungExplosion") then
					emitGroup(sc.PungExplosion)
					task.wait(0.1)
					for _, v in pairs(sc.PungExplosion:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 0.1 end
					end
				end
			end)

			task.delay(8.6, function()
				if not sc then return end
				if sc:FindFirstChild("PungExplosion") then
					for _, v in pairs(sc.PungExplosion:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 1 end
					end
				end
				if sc:FindFirstChild("PungExplosion2") then
					emitGroup(sc.PungExplosion2)
					task.wait(0.1)
					for _, v in pairs(sc.PungExplosion2:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 0.05 end
					end
				end
			end)

			task.delay(9.167, function()
				if sc then setEnabled(sc:FindFirstChild("Laugh"), true) end
			end)

			task.delay(10.783, function()
				if sc then
					setEnabled(sc:FindFirstChild("Laugh"), false)
					setEnabled(sc:FindFirstChild("AtmosphereSL"), true)
				end
			end)

			task.delay(12.383, function()
				if not sc then return end
				if sc:FindFirstChild("PungExplosion2") then
					for _, v in pairs(sc.PungExplosion2:GetDescendants()) do
						if v:IsA("ParticleEmitter") then v.TimeScale = 1 end
					end
				end
				emitGroup(sc:FindFirstChild("PungExplosion3"))
			end)

			task.delay(13.533, function()
				if sc then
					emitGroup(sc:FindFirstChild("PungExplosion4"))
					setEnabled(sc:FindFirstChild("AtmosphereSL0"), false)
				end
			end)

			task.delay(15.35, function()
				if sc then
					setEnabled(sc:FindFirstChild("AtmosphereSL"), false)
					setEnabled(sc:FindFirstChild("AuraCore"), true)
					local ball = sc.AuraCore and sc.AuraCore:FindFirstChild("Ball")
					if ball then ball.Transparency = 0 end
				end
			end)

			task.delay(18.4, function()
				if sc then
					setEnabled(sc:FindFirstChild("AuraCore"), false)
					local ball = sc.AuraCore and sc.AuraCore:FindFirstChild("Ball")
					if ball then ball.Transparency = 1 end
				end
			end)

			task.delay(18.85, function()
				if sc then emitGroup(sc:FindFirstChild("LastShotMoment")) end
				local cc = Instance.new("ColorCorrectionEffect")
				cc.Saturation = -1
				cc.Contrast = -3
				cc.Parent = Lighting
				task.delay(0.2, function()
					cc.Saturation = -1
					cc.Contrast = 3
					task.wait(0.2)
					if cc and cc.Parent then cc:Destroy() end
				end)
			end)

			-- [[ Final damage + cleanup ]]:
			task.delay(21.783, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, false, false, true, true, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 3)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(1,1,1) * math.huge,
					Velocity = HumRP.CFrame.LookVector * 60 + Vector3.new(0, 20, 0)
				})

				pcall(function() Weld:Stop() end)
				HumRP.Anchored = false
				EnemyHumRP.Anchored = false

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

				cloneSkill5:Destroy()

				ReplicateEffects_Set:FireAllClients("BakugoFinalBurst", {
					char = Character,
					stage = "End",
				})
			end)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, PlayerAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
		end

		Hitbox:Start(0.25, true)

		-- [[ No anim plays on startup — only stun and hitbox ]]:
		task.delay(0.25, function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
	end
}