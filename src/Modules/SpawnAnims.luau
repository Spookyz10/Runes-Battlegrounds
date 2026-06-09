--// Services \\--

local SvSt = game:GetService('ServerStorage')
local Debris = game:GetService('Debris')
local RNS = game:GetService('RunService')
local RS = game:GetService('ReplicatedStorage')

--// Remotes \\--

local Remotes = RS.Remotes

local ReplicateSet = Remotes.Replicate.Set

local ComunicatorFolder = Remotes.Comunicator

local PlrSet = ComunicatorFolder.Set


--// Assets \\--

local Assets = SvSt.Assets

local Models = Assets.Models
local Animations = Assets.Animations
local Sounds = Assets.Sounds


--// Replicated Modules \\--

local RpModules = RS.Modules

local AnimationEvents = require(RpModules.AnimationEvents)



--// Server Modules \\--

local SvModules = SvSt.Modules

local AnimationService = require(SvModules.AnimationService)
local SoundsModule = require(SvModules.SoundsModule)
local NewKnockback = require(SvModules.BodymoverService)
local StunHandler = require(SvModules.StunHandler)
local iFramesService = require(SvModules.iFramesService)



--// Raycast Things \\--

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Include
RayParams.FilterDescendantsInstances = { workspace.Map }
RayParams.IgnoreWater = true


local function raycast(origin, direction)
	return workspace:Raycast(origin, direction, RayParams)
end



return {
	['KJ'] = function(Player: Player)
		if not Player then return end


		local Character = Player.Character

		if not Character then return end


		local HumRP: BasePart = Character.HumanoidRootPart
		local Torso: BasePart = Character.Torso
		
		local AnimObjects = {}
		local animTrack, AnimEvents = AnimationService:getAnimationTrack(Character, Animations["Spawn Animations"].KJ)

		local phone = Models.KJ["Spawn Animation"].phone:Clone()
		phone.Parent = Character
		phone.Handle.Handle.Part0 = Character['Right Arm']
		SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].KJ.Phone, phone.Handle, 1, 1)
		table.insert(AnimObjects, phone)
		Debris:AddItem(phone, animTrack.Length)

		AnimEvents["throw"] = animTrack:GetMarkerReachedSignal("throw"):Once(function()
			if not phone or not phone.Parent then return end

			phone.Handle.Handle:Destroy()

			local mainVel = Instance.new('BodyVelocity')
			mainVel.MaxForce = Vector3.new(1,1,1) * math.huge
			mainVel.Velocity = HumRP.CFrame.LookVector * 15
			mainVel.Parent = phone.Handle
			Debris:AddItem(mainVel, .1)

			task.wait(.4)

			phone.Handle:Destroy()

			local topVel = Instance.new('BodyVelocity')
			topVel.MaxForce = Vector3.new(1,1,1) * math.huge
			topVel.Velocity = HumRP.CFrame.LookVector * math.random(1.5, 2)
			topVel.Parent = phone.Top.Main
			SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].KJ["Phone Break"], phone.Top.Main, 1, 1)
			Debris:AddItem(topVel, .1)

			local bottomVel = Instance.new('BodyVelocity')
			bottomVel.MaxForce = Vector3.new(1,1,1) * math.huge
			bottomVel.Velocity = HumRP.CFrame.LookVector * math.random(.5, 1)
			bottomVel.Parent = phone.Bottom.Main
			SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].KJ["Phone Break"], phone.Bottom.Main, 1, 1)
			Debris:AddItem(bottomVel, .1)
		end)

		animTrack.Stopped:Once(function()
			for _, Object in AnimObjects do
				Object:Destroy()
			end
		end)

		animTrack.Ended:Once(function()
			ReplicateSet:FireClient(Player, 'fixspeedbug')
			PlrSet:FireClient(Player, 'SpawnAnimsFixSpeed')
		end)


		AnimationService:playAnimation(Character, Animations["Spawn Animations"].KJ)
		table.insert(AnimObjects, SoundsModule:PlaySound(Assets.Sounds["Spawn Animations"].KJ.Walk, Character.Torso, 1, 1))
	end,
	
	["The Strongest Hero"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end


		local Animation = Animations["Spawn Animations"]["The Strongest Hero"]
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)


		AnimationTrack.Stopped:Once(function()

		end)

		AnimationService:playAnimation(Character, Animation)
	end,
	
	["Martial Artist"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end

		local Assets = {}
		local Animation = Animations["Spawn Animations"].Suiryu
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)

		AnimationTrack.Stopped:Once(function()
			
			for _,v in Assets do
				v:Destroy()
			end
		end)

		AnimationService:playAnimation(Character, Animation)

		table.insert(Assets, SoundsModule:PlaySound(Sounds["Spawn Animations"].Suiryu, HumRP))
	end,
	
	["Turbo Kun"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end

		local Animation = Animations["Spawn Animations"].Okarun
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		AnimationTrack.Stopped:Once(function()
			
		end)
		
		AnimationService:playAnimation(Character, Animation)
		
		SoundsModule:PlaySound(Sounds["Spawn Animations"].Okarun.SFX, HumRP)
		SoundsModule:PlaySound(Sounds["Spawn Animations"].Okarun.Voice, HumRP)
	end,
	
	["Finger Eater"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end

		
		local Animation = Animations["Spawn Animations"].Dawi
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		AnimationTrack.Stopped:Once(function()
			
		end)
		
		AnimationService:playAnimation(Character, Animation)
	end,
	
	["The Frozen Soul"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end

		local Animation = Animations["Spawn Animations"]["The Frozen Soul"]
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		local Attachments = {}
		
		local function ApplyAuraEffects(AuraTemplate, Char)
			local AuraTargetFolder = Char[tostring(AuraTemplate)]

			if not AuraTargetFolder then
				return
			else
				for _, AuraPart in pairs(AuraTemplate:GetChildren()) do
					local ClonedPart = AuraPart:Clone()
					ClonedPart.Parent = AuraTargetFolder 

					for _, Descendant in pairs(ClonedPart:GetDescendants()) do
						if (Descendant:IsA("Trail") or Descendant:IsA("Beam")) and Descendant.Attachment0 and Descendant.Attachment1 then
							Attachments[Descendant] = {
								Attachment0 = Descendant.Attachment0.CFrame, 
								Attachment1 = Descendant.Attachment1.CFrame
							}
						end
					end
				end

				if next(Attachments) then
					for TrailOrBeam, AttachmentData in pairs(Attachments) do
						local OrigCFrame0 = AttachmentData.Attachment0
						local OrigCFrame1 = AttachmentData.Attachment1
						local TargetPart = TrailOrBeam.Parent.Parent

						for _, CharacterAttachment in pairs(Character:GetDescendants()) do
							if CharacterAttachment:IsA("Attachment") then
								local AttachmentParent = CharacterAttachment.Parent

								if AttachmentParent and AttachmentParent:IsA("BasePart") and AttachmentParent == TargetPart then
									local l_CFrame_2 = CharacterAttachment.CFrame

									if l_CFrame_2 == OrigCFrame0 then
										TrailOrBeam.Attachment0 = CharacterAttachment

									elseif l_CFrame_2 == OrigCFrame1 then
										TrailOrBeam.Attachment1 = CharacterAttachment
									end
								end
							end
						end
					end
				end
			end
		end
		
		
		for _, Aura in pairs(Models["Frozen Aura"]:GetChildren()) do
			local MatchingTemplate = Models["Frozen Aura"]:FindFirstChild((tostring(Aura)))

			if MatchingTemplate then
				ApplyAuraEffects(MatchingTemplate, Character)
			end
		end
		
		
		AnimationTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)

		AnimationService:playAnimation(Character, Animation)
	end,
	
	["Cursed Child"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end


		local Animation = Animations["Spawn Animations"]["Cursed Child"]
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		AnimationTrack.Stopped:Once(function()

		end)
		
		AnimationService:playAnimation(Character, Animation)
		
		ReplicateSet:FireAllClients("CharaSpawn", { Char = Character, Anim = Animation.AnimationId })
	end,
	
	["Volt Viper"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end
		
		
		local Assets = {}
		
		local Animation = Animations["Spawn Animations"]["Volt Viper"]
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		
		AnimationTrack.Stopped:Once(function()
			for _,v in Assets do
				v:Destroy()
			end
		end)
		

		AnimationService:playAnimation(Character, Animation)
		
		ReplicateSet:FireAllClients("VoltViperSpawn", { Char = Character, Animation = Animation.AnimationId })
		table.insert(Assets, SoundsModule:PlaySound(Sounds["Spawn Animations"]["Volt Viper"], HumRP))
	end,
	
	["Hero Hunter"] = function(Player: Player)
		if not Player then return end

		local Character = Player.Character
		if not Character then return end

		local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then return end



		local Animation = Animations["Spawn Animations"]["Hero Hunter"]
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		
		
		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.25, Limb = "Right Arm" })
		ReplicateSet:FireAllClients("waterpalm", { Char = Character, Time = 1.25, Limb = "Left Arm" })
		
		
		AnimationTrack.Stopped:Once(function()

		end)
		
		
		AnimationService:playAnimation(Character, Animation)
	end,
}