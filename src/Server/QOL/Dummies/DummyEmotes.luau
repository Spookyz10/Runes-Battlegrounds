--Services
local RS = game:GetService('ReplicatedStorage')
local SvSt = game:GetService('ServerStorage')



--Server Modules
local SvModules = SvSt.Modules

local AnimationService = require(SvModules.AnimationService)
local SoundsModule = require(SvModules.SoundsModule)



--Remotes
local RemotesContainer = RS.Remotes


local ReplicateEffects_Set = RemotesContainer.Replicate.Set



--Variables
local Assets = SvSt.Assets


return {
	EmoteVariants = {
		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy["Power Up"]
			local Track, Events = AnimationService:getAnimationTrack(Dummy, Animation)
			
			
			local SpawnAssets = {}
			local Source = nil
			
			
			table.insert(Events, Track:GetMarkerReachedSignal("start"):Once(function()
				local auraAttachment = RS.Resources.Emotes.powerupaura.Attachment:Clone()
				table.insert(SpawnAssets, auraAttachment)

				Source = auraAttachment

				local randomAuraColor = ({
					BrickColor.new("Bright red").Color, 
					BrickColor.new("Bright yellow").Color, 
					BrickColor.new("Electric blue").Color, 
					BrickColor.new("White").Color
				})[math.random(1, 4)]

				for _, particle in pairs(auraAttachment:GetChildren()) do
					particle.Color = ColorSequence.new(randomAuraColor)
				end

				auraAttachment.Parent = Dummy.PrimaryPart
				auraAttachment.big:Emit(5)
				auraAttachment.ParticleEmitter.Enabled = true
			end))

			table.insert(Events, Track:GetMarkerReachedSignal("end"):Once(function()
				Source.ParticleEmitter.Enabled = false
			end))
			
			
			table.insert(SpawnAssets, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"]["Weakest Dummy"], HumRP))
			
			
			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)
			
			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local Animation = Assets.Animations["Spawn Animations"].Dummy["Locked In"]
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}

			task.spawn(function()
				local SFX = shared.sfx({
					SoundId = "rbxassetid://94677787747907", 
					Parent = Dummy.Torso, 
					Volume = 2, 
					RollOffMaxDistance = 85,
					Looped = true
				})
				SFX:Play()
				table.insert(SpawnAssets, SFX)
			end)

			local EmoteFolder = RS.Resources.Emotes.SumWater:Clone()
			table.insert(SpawnAssets, EmoteFolder)

			local sumWater = EmoteFolder.SumWater
			table.insert(SpawnAssets, sumWater)

			sumWater.Part0 = Dummy.Head
			sumWater.Part1 = EmoteFolder
			sumWater.Parent = Dummy.Head
			EmoteFolder.Parent = Dummy

			local AuraRen = RS.Resources.Emotes.AuraRen:Clone()
			table.insert(SpawnAssets, AuraRen)

			local Motor6D = AuraRen.Motor6D
			table.insert(SpawnAssets, Motor6D)

			Motor6D.Part0 = Dummy.PrimaryPart
			Motor6D.Part1 = AuraRen
			Motor6D.Parent = AuraRen
			AuraRen.Parent = Dummy

			local EmoteModel = RS.Resources.Emotes.tounge:Clone()
			table.insert(SpawnAssets, EmoteModel)

			local tounge = EmoteModel.tounge
			table.insert(SpawnAssets, tounge)

			tounge.Part0 = Dummy.Head
			tounge.Part1 = EmoteModel
			tounge.Parent = Dummy.Head

			EmoteModel.Parent = Dummy

			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy["Kitty Cat"]
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local Events = {}
			local SpawnAssets = {}

			local emoteModel = RS.Resources.Emotes.Maxwell:Clone()
			table.insert(SpawnAssets, emoteModel)

			local m6d = emoteModel.m6d
			table.insert(SpawnAssets, m6d)

			m6d.Part0 = Dummy["Left Arm"]
			m6d.Part1 = emoteModel.maxwell
			m6d.Name = "maxwell"
			m6d.Parent = Dummy["Left Arm"]

			emoteModel.Parent = Dummy


			Events['clap'] = Track:GetMarkerReachedSignal("clap"):Once(function()
				if math.random(1, 3) == 1 then
					local randomSound = {
						"rbxassetid://71306172013298", 
						"rbxassetid://98428650205813", 
						"rbxassetid://77052207188997"
					}
					local newSoundId = randomSound[math.random(1, #randomSound)]

					local SFX = shared.sfx({
						SoundId = newSoundId,
						RollOffMaxDistance = 90,
						RollOffMinDistance = 5,
						Volume = 0.5,
						Parent = HumRP
					})

					SFX:Play()

					table.insert(SpawnAssets, SFX)
				end
			end)


			Track.Stopped:Once(function()
				for _,v in Events do
					v:Disconnect()
				end
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local Animation = Assets.Animations["Spawn Animations"].Dummy["Dry Lips"]
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}

			local tangClone = RS.Resources.Emotes.tang:Clone()
			table.insert(SpawnAssets, tangClone)

			local weldConstraint = tangClone.Part
			table.insert(SpawnAssets, weldConstraint)

			tangClone.Name = "Part"
			weldConstraint.Part0 = Dummy.Head
			weldConstraint.Part1 = tangClone
			weldConstraint.Parent = Dummy.Head
			tangClone.Parent = Dummy

			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy["Silly Billy"]
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}

			SpawnAssets['Music'] = SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].Dummy.Silly, HumRP)

			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy.Bear
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}

			local bear = RS.Resources.Emotes.Bear:Clone()
			table.insert(SpawnAssets, bear)

			local body = bear.Body.Body
			body.Part0 = HumRP
			body.Part1 = bear.Body

			bear.Parent = Dummy

			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy.Griddy
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}

			table.insert(SpawnAssets, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].Dummy.Griddy, HumRP, 1, 1))

			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local Animation = Assets.Animations["Spawn Animations"].Dummy.Amplify
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local Events = {}
			local SpawnAssets = {}

			task.spawn(function()
				local SFX = shared.sfx({
					SoundId = "rbxassetid://92948087500146", 
					Parent = Dummy.Torso, 
					Volume = 2, 
					RollOffMaxDistance = 85,
				})
				SFX:Play()

				table.insert(SpawnAssets, SFX)
			end)


			Events['first'] = Track:GetMarkerReachedSignal("first"):Once(function()
				local AmplifyVfx = RS.Resources.Emotes.AmplifyVfx
				local v183 = {}
				local v184 = {}

				local function v191(v185, v186)
					local v187 = AmplifyVfx[v185]:Clone()
					v187.Parent = v186
					game.Debris:AddItem(v187, 5)
					v187:SetAttribute("EmoteProperty", true)

					table.insert(SpawnAssets, v187)

					local l_Motor6D_1 = v187:FindFirstChildOfClass("Motor6D")
					if l_Motor6D_1 then
						v187.CanCollide = false
						v187.Massless = true
						v187.Anchored = false
						l_Motor6D_1.Part0 = v186
						l_Motor6D_1.Part1 = v187
					else
						v187.CFrame = Dummy.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
					end

					for _, v190 in pairs(v187:GetDescendants()) do
						if v190:IsA("ParticleEmitter") then
							v190:Emit(v190:GetAttribute("EmitCount"))
							if l_Motor6D_1 then
								v190.Enabled = true
								table.insert(v184, v190)
							end

							if tostring(v185) == "head" then
								table.insert(v183, v190)
							end
						end
					end
				end

				v191("arm", Dummy["Right Arm"])
				v191("head", Dummy.Head)

				wait(1.1)

				for _, v193 in pairs(v183) do
					v193.Enabled = false
				end

				for _, v195 in pairs(v184) do
					v195.Enabled = false
					game.Debris:AddItem(v195, 1)
				end
			end)

			Events['sec'] = Track:GetMarkerReachedSignal("sec"):Once(function()
				local l_AmplifyVfx_1 = RS.Resources.Emotes.AmplifyVfx

				local function v208(v202, v203)
					local v204 = l_AmplifyVfx_1[v202]:Clone()
					v204.Parent = v203
					game.Debris:AddItem(v204, 5)
					v204:SetAttribute("EmoteProperty", true)

					table.insert(SpawnAssets, v204)

					local l_Motor6D_2 = v204:FindFirstChildOfClass("Motor6D");
					if l_Motor6D_2 then
						v204.CanCollide = false
						v204.Massless = true
						v204.Anchored = false
						l_Motor6D_2.Part0 = v203
						l_Motor6D_2.Part1 = v204
					else
						v204.CFrame = Dummy.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
					end

					for _, v207 in pairs(v204:GetDescendants()) do
						if v207:IsA("ParticleEmitter") then
							v207:Emit(v207:GetAttribute("EmitCount"))
							if l_Motor6D_2 then
								v207.Enabled = true
							end
						end
					end
				end

				v208("arm2", Dummy["Left Arm"])
				v208("auraoff", Dummy["Left Arm"])
			end)


			Track.Stopped:Once(function()
				for _,v in Events do
					v:Disconnect()
				end
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy.Wait
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}


			table.insert(SpawnAssets, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].Dummy.Wait, HumRP, 1, 1))


			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy.March
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}


			table.insert(SpawnAssets, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].Dummy.March, HumRP, 1, 1))


			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,

		function(Dummy: Model)
			local HumRP: BasePart = Dummy.HumanoidRootPart
			local Humanoid: Humanoid = Dummy.Humanoid
			
			local Animation = Assets.Animations["Spawn Animations"].Dummy.Owl
			local Track = AnimationService:getAnimationTrack(Dummy, Animation)

			local SpawnAssets = {}


			table.insert(SpawnAssets, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].Dummy.Owl, HumRP, 1, 1))


			Track.Stopped:Once(function()
				for _,v in SpawnAssets do
					if v and v.Parent then
						v:Destroy()
					end
				end
			end)

			AnimationService:playAnimation(Dummy, Animation)
		end,
	}
}