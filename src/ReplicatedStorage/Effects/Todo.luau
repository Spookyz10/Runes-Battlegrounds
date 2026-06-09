local ReplicatedStorage = game:GetService('ReplicatedStorage')
local module = {}
local Utility = require(ReplicatedStorage.Utility)
local Parent = require(script.Parent)
local PlayerGui = Utility.Idk.PlayerGui

function module.groundSlam(arg1)
	local clone_36 = ReplicatedStorage.Resources.Todo.GroundSlam:Clone()
	clone_36.Parent = workspace.Effects
	Parent.EmitOnly(clone_36)
	Utility.Services.Debris:AddItem(clone_36, 3)
	local any_Raycast_result1 = Utility.Modules.RayCast(arg1.Position, Vector3.yAxis * -5)
	if any_Raycast_result1 then
		clone_36:SetPrimaryPartCFrame(CFrame.new(any_Raycast_result1.Position))
	else
		clone_36:SetPrimaryPartCFrame(arg1.CFrame * CFrame.new(0, -3, 0))
	end
end
function module.jointStruggle(arg1, arg2)
	local RootPart_3_upvr = arg1:FindFirstChildOfClass("Humanoid").RootPart
	local any_new_result1 = Utility.Modules.Trove.new()
	local var21
	for _, v in ipairs(arg1:FindFirstChildOfClass("Humanoid").Animator:GetPlayingAnimationTracks()) do
		if v.Animation and v.Animation.AnimationId == ReplicatedStorage.Resources.Todo["Joint Struggle Hit"].AnimationId then
			var21 = v
		end
	end
	any_new_result1:Add(var21)
	local var22_upvw = arg1
	if Utility.Services.Players.LocalPlayer.Character == arg2 then
		var22_upvw = arg2
	end
	task.spawn(function() 
		Parent.Cutscene(ReplicatedStorage.Resources.Todo['Joint Struggle (Camera)'], ReplicatedStorage.Resources.CamRigWithLetterBox, RootPart_3_upvr, CFrame.new(0, -3, 0), ReplicatedStorage.Resources.Todo.jointStruggle.FOV, true)
		--Parent.Cutscene(ReplicatedStorage.Resources.Todo["Joint Struggle (Camera)"], ReplicatedStorage.Resources.CamRigWithLetterBox, RootPart_3_upvr, CFrame.new(0, -3, 0), ReplicatedStorage.Resources.Todo.jointStruggle.FOV, true)
	end)
	Utility.Modules.soundPlaying:play(ReplicatedStorage.Resources.Todo["Joint StruggleS"], Utility.Services.Sound)
	local ColorCorrectionEffect_upvr_2 = Instance.new("ColorCorrectionEffect")
	ColorCorrectionEffect_upvr_2.Parent = Utility.Services.Lighting
	ColorCorrectionEffect_upvr_2.Enabled = false
	local DepthOfFieldEffect_upvr = Instance.new("DepthOfFieldEffect")
	DepthOfFieldEffect_upvr.Parent = Utility.Services.Lighting
	local clone_5_upvr = ReplicatedStorage.Resources.Todo.BestFriend:Clone()
	clone_5_upvr.Parent = arg1
	Utility.Modules.animPlaying:loadAnimation(clone_5_upvr, ReplicatedStorage.Resources.Todo["Joint Struggle (Friend)"]):Play()
	local any_GetPlayerFromCharacter_result1_upvr_3 = Utility.Services.Players:GetPlayerFromCharacter(arg1)
	spawn(function()
		local tbl = {}
		local pcall_result1, pcall_result2 = pcall(function() 
			return Utility.Services.Players:GetFriendsAsync(any_GetPlayerFromCharacter_result1_upvr_3.UserId)
		end)
		if pcall_result1 then
			repeat
				for _, v_2 in pairs(pcall_result2:GetCurrentPage()) do
					table.insert(tbl, v_2)
				end
				if not pcall_result2.IsFinished then
					pcall_result2:AdvanceToNextPageAsync()
				end
			until pcall_result2.IsFinished
		end
		if next(tbl) ~= nil then
			clone_5_upvr:FindFirstChildOfClass("Humanoid"):ApplyDescription(Utility.Services.Players:GetHumanoidDescriptionFromUserId(tonumber(tbl[math.random(1, #tbl)].Id)))
		end
	end)
	local Weld_13 = Instance.new("Weld")
	Weld_13.Parent = clone_5_upvr.PrimaryPart
	Weld_13.Part0 = RootPart_3_upvr
	Weld_13.Part1 = clone_5_upvr.PrimaryPart
	local clone_37_upvr = ReplicatedStorage.Resources.Todo.StoneRig:Clone()
	clone_37_upvr.Parent = arg1
	Utility.Modules.animPlaying:loadAnimation(clone_37_upvr, ReplicatedStorage.Resources.Todo["Joint Struggle (Stone)"]):Play()
	local Weld_6 = Instance.new("Weld")
	Weld_6.Parent = clone_37_upvr.PrimaryPart
	Weld_6.Part0 = RootPart_3_upvr
	Weld_6.Part1 = clone_37_upvr.PrimaryPart
	Weld_6.C0 = CFrame.new(0, -3, 0)
	local clone_13_upvr = ReplicatedStorage.Resources.Todo.jointStruggle.White:Clone()
	clone_13_upvr.Parent = arg1
	clone_13_upvr:PivotTo(RootPart_3_upvr.CFrame * CFrame.new(0, -3, 0))
	Utility.Modules.animPlaying:loadAnimation(clone_13_upvr, ReplicatedStorage.Resources.Todo["Joint Struggle White"]):Play()
	local clone_4 = ReplicatedStorage.Resources.Todo.jointStruggle.enegyhand2:Clone()
	clone_4.Parent = clone_5_upvr
	local Weld_12 = Instance.new("Weld")
	Weld_12.Part0 = clone_5_upvr["Right Arm"]
	Weld_12.Part1 = clone_4
	Weld_12.C0 = CFrame.new(0, -1, 0)
	Weld_12.Parent = clone_4
	local clone_33_upvr = ReplicatedStorage.Resources.Todo.jointStruggle.Legimpact:Clone()
	clone_33_upvr.Parent = arg1
	clone_33_upvr.CFrame = arg1["Right Leg"].CFrame
	Utility.Services.Debris:AddItem(clone_33_upvr, 2)
	local Weld_3 = Instance.new("Weld")
	Weld_3.Part0 = arg1["Right Leg"]
	Weld_3.Part1 = clone_33_upvr
	Weld_3.Parent = clone_33_upvr
	local clone_18_upvr = ReplicatedStorage.Resources.Todo.jointStruggle.bkk:Clone()
	clone_18_upvr.Parent = arg2
	clone_18_upvr.CFrame = arg2.Torso.CFrame
	Utility.Services.Debris:AddItem(clone_18_upvr, 2)
	local clone_15 = ReplicatedStorage.Resources.Todo.jointStruggle.Fhit:Clone()
	clone_15.Parent = arg2
	clone_15.CFrame = arg2.Torso.CFrame
	for _, v_3 in pairs(clone_15:GetDescendants()) do
		if v_3:IsA("ParticleEmitter") then
			v_3:Emit(v_3:GetAttribute("EmitCount"))
		end
	end
	Utility.Services.Debris:AddItem(clone_15, 1)
	any_new_result1:Add(var21:GetMarkerReachedSignal("knockback"):Once(function() 
		for _, v_4 in pairs(clone_33_upvr:GetDescendants()) do
			if v_4:IsA("ParticleEmitter") then
				v_4.Enabled = false
			end
		end
		for _, v_5 in pairs(clone_18_upvr:GetDescendants()) do
			if v_5:IsA("ParticleEmitter") then
				v_5.Enabled = false
			end
		end
		local clone_34 = ReplicatedStorage.Resources.Todo.jointStruggle.hit:Clone()
		clone_34.Parent = workspace.Effects
		clone_34.CFrame = arg2.Torso.CFrame
		for _, v_6 in pairs(clone_34:GetDescendants()) do
			if v_6:IsA("ParticleEmitter") then
				v_6:Emit(v_6:GetAttribute("EmitCount"))
			end
		end
		Utility.Services.Debris:AddItem(clone_34, 1)
		local clone_20_upvr = ReplicatedStorage.Resources.Todo.jointStruggle.wi:Clone()
		clone_20_upvr.Parent = workspace.Effects
		local Weld_8 = Instance.new("Weld")
		Weld_8.Part0 = arg2.Torso
		Weld_8.Part1 = clone_20_upvr
		Weld_8.Parent = clone_20_upvr
		task.delay(0.5, function()
			for _, v_7 in pairs(clone_20_upvr:GetDescendants()) do
				if v_7:IsA("ParticleEmitter") then
					v_7.Enabled = false
				end
			end
			Utility.Services.Debris:AddItem(clone_20_upvr, 1)
		end)
		Parent.impactFrame(3)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("clap"):Once(function()
		Parent.Emit(RootPart_3_upvr, ReplicatedStorage.Resources.Todo.Slap)
		Parent.Emit(RootPart_3_upvr, ReplicatedStorage.Resources.Todo.jointStruggle.lightdada)
		local clone_11 = ReplicatedStorage.Resources.Todo.jointStruggle.mainLight:Clone()
		clone_11.Parent = workspace.Effects
		clone_11.CFrame = RootPart_3_upvr.CFrame
		Utility.Services.Debris:AddItem(clone_11, 2)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("blackflash"):Once(function() 
		local clone_38 = ReplicatedStorage.Resources.Todo.jointStruggle.KOKUZEN:Clone()
		clone_38.Parent = arg1
		local Weld_2 = Instance.new("Weld")
		Weld_2.Part0 = arg1["Right Leg"]
		Weld_2.Part1 = clone_38
		Weld_2.C0 = CFrame.new(0, -1, 0)
		Weld_2.Parent = clone_38
		for _, v_8 in pairs(clone_38:GetDescendants()) do
			if v_8:IsA("ParticleEmitter") then
				v_8:Emit(v_8:GetAttribute("EmitCount"))
			end
		end
		Utility.Services.Debris:AddItem(clone_38, 3)
		task.wait(0.5)
		ColorCorrectionEffect_upvr_2.Enabled = true
		ColorCorrectionEffect_upvr_2.Brightness = 0
		local any_Create_result1_8_upvr = Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(3), {
			Brightness = 1;
		})
		any_Create_result1_8_upvr:Play()
		any_Create_result1_8_upvr.Completed:Connect(function() 
			any_Create_result1_8_upvr:Destroy()
			task.wait(1)
			local any_Create_result1_5_upvr = Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(0.7), {
				Brightness = 0;
			})
			any_Create_result1_5_upvr:Play()
			any_Create_result1_5_upvr.Completed:Connect(function() 
				ColorCorrectionEffect_upvr_2.Enabled = false
				any_Create_result1_5_upvr:Destroy()
			end)
		end)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("blueLine"):Once(function() 
		local clone_21 = ReplicatedStorage.Resources.Todo.jointStruggle.blueLine:Clone()
		clone_21.Parent = arg1
		local Weld_14 = Instance.new("Weld")
		Weld_14.Part0 = arg1.Torso
		Weld_14.Part1 = clone_21
		Weld_14.Parent = clone_21
		Parent.Emit(clone_21)
		task.wait(3.5)
		clone_21:Destroy()
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("placeEffect"):Once(function() 
		local clone_2 = ReplicatedStorage.Resources.Todo.jointStruggle.placeEffect:Clone()
		clone_2.Parent = workspace.Effects
		local Weld_11 = Instance.new("Weld")
		Weld_11.Part0 = RootPart_3_upvr
		Weld_11.Part1 = clone_2
		Weld_11.Parent = clone_2
		task.wait(3.7)
		for _, v_9 in pairs(clone_2:GetDescendants()) do
			if v_9.Parent == clone_2.Attachment or v_9.Parent == clone_2.Blueatt then
				if v_9:IsA("ParticleEmitter") then
					v_9.Enabled = false
				end
			end
		end
		Utility.Services.Debris:AddItem(clone_2, 5)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("FFF"):Once(function()
		ColorCorrectionEffect_upvr_2.Enabled = true
		Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(1), {
			Brightness = 1;
		}):Play()
		local clone_8 = ReplicatedStorage.Resources.Todo.jointStruggle.FFF:Clone()
		clone_8.Parent = arg1
		Parent.Emit(clone_8)
		local Weld = Instance.new("Weld")
		Weld.Part0 = arg1.Torso
		Weld.Part1 = clone_8
		Weld.Parent = clone_8
		task.wait(1.653)
		clone_8:Destroy()
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("endFFF"):Once(function()
		local any_Create_result1_upvr = Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(1), {
			Brightness = 0;
		})
		any_Create_result1_upvr:Play()
		any_Create_result1_upvr.Completed:Once(function()
			ColorCorrectionEffect_upvr_2.Enabled = false
			any_Create_result1_upvr:Destroy()
		end)
		for _, v_10 in pairs(arg1:GetChildren()) do
			if v_10:IsA("BasePart") then
				for _, v_11 in pairs(ReplicatedStorage.Resources.Todo.jointStruggle.lineAura:GetChildren()) do
					if v_11:IsA("ParticleEmitter") then
						local clone_22 = v_11:Clone()
						clone_22.Parent = v_10
						Utility.Services.Debris:AddItem(clone_22, 5)
					end
				end
			end
		end
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("imageCharacter"):Once(function() 
		arg1.Archivable = true
		local Tick = tick()
		while tick() - Tick < 2.5 do
			local clone_3_upvr = arg1:Clone()
			clone_3_upvr.HumanoidRootPart:Destroy()
			clone_3_upvr.Head.face:Destroy()
			clone_3_upvr.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			for _, v_12 in clone_3_upvr:GetDescendants() do
				if v_12:IsA("BasePart") then
					v_12.Anchored = true
					v_12.CastShadow = false
				end
			end
			local clone_29_upvr = arg1:Clone()
			clone_29_upvr.HumanoidRootPart:Destroy()
			clone_29_upvr.Head.face:Destroy()
			clone_29_upvr.Humanoid:Destroy()
			for _, v_13 in clone_29_upvr:GetDescendants() do
				if v_13:IsA("Decal") then
					v_13:Destroy()
				elseif v_13:IsA("BasePart") then
					v_13.Anchored = true
					v_13.Transparency = 1
					v_13.Material = Enum.Material.Glass
				end
			end
			local Highlight_upvr = Instance.new("Highlight", clone_29_upvr)
			Highlight_upvr.DepthMode = Enum.HighlightDepthMode.Occluded
			Highlight_upvr.OutlineTransparency = 0.855
			Highlight_upvr.OutlineColor = Color3.fromRGB(255, 255, 255)
			coroutine.wrap(function() 
				while tick() - tick() < 0.1 do
					Highlight_upvr.FillTransparency = 0.1
					Highlight_upvr.FillColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					for _, v_14 in clone_3_upvr:GetDescendants() do
						if v_14:IsA("BasePart") then
							v_14.Transparency = 0
						end
					end
					Utility.Services.RunService.PreRender:Wait()
				end
				clone_3_upvr:Destroy()
				clone_29_upvr:Destroy()
			end)()
			local clone_39 = ReplicatedStorage.Resources.Todo.jointStruggle.trail:Clone()
			clone_39.Parent = workspace.Effects
			clone_3_upvr.Parent = clone_39
			clone_29_upvr.Parent = clone_39
			task.wait(0.025)
			Utility.Services.Debris:AddItem(clone_39, 1)
		end
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("eyeAura"):Once(function()
		local clone_25 = ReplicatedStorage.Resources.Todo.jointStruggle.eyeAura:Clone()
		clone_25.Parent = arg1
		local Weld_4 = Instance.new("Weld", clone_25)
		Weld_4.Part0 = arg1.Head
		Weld_4.Part1 = clone_25
		Utility.Services.Debris:AddItem(clone_25, 2)
		local clone_7 = ReplicatedStorage.Resources.Todo.jointStruggle.STARYELLOW:Clone()
		clone_7.Parent = workspace.Effects
		clone_7.CFrame = RootPart_3_upvr.CFrame * CFrame.new(0, -3, -1)
		Utility.Services.Debris:AddItem(clone_7, 1.2)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("hand"):Once(function()
		local clone = ReplicatedStorage.Resources.Todo.jointStruggle.yELLOW:Clone()
		clone.Parent = arg1
		local Weld_5 = Instance.new("Weld")
		Weld_5.Part0 = arg1["Right Arm"]
		Weld_5.Part1 = clone
		Weld_5.C0 = CFrame.new(0, -2.5, 0)
		Weld_5.Parent = clone
		Utility.Services.Debris:AddItem(clone, 1)
	end))
	any_new_result1:Add(var21:GetMarkerReachedSignal("charge"):Once(function() 
		Parent.Emit(RootPart_3_upvr, ReplicatedStorage.Resources.Todo.jointStruggle.lightingch, 2)
	end))
	task.spawn(function() 
		task.wait(3)
		local clone_26 = ReplicatedStorage.Resources.Todo.jointStruggle.line:Clone()
		clone_26.Parent = workspace.Effects
		clone_26.CFrame = RootPart_3_upvr.CFrame * CFrame.new(9.35, 1.924, -63.993) * CFrame.Angles((math.pi/2), -0.5792747787369179, 0)
		task.wait(0.05)
		clone_26:Destroy()
		Utility.Services.Lighting.ClockTime = 0
		Parent.impactFrame(3)
		local clone_41 = ReplicatedStorage.Resources.Todo.jointStruggle.redscreen:Clone()
		clone_41.Parent = workspace.Effects
		clone_41.CFrame = RootPart_3_upvr.CFrame * CFrame.Angles(0, 0.1322959573011702, 0) * CFrame.new(1.979, 2.426, 10.574)
		task.wait(1.545)
		clone_41:Destroy()
		Parent.impactFrame(3)
		local clone_23 = ReplicatedStorage.Resources.Todo.jointStruggle.blackgroundlom:Clone()
		clone_23.Parent = workspace.Effects
		local Weld_15 = Instance.new("Weld")
		Weld_15.Part0 = clone_37_upvr.Stone
		Weld_15.Part1 = clone_23
		Weld_15.C0 = CFrame.Angles(0, -0.2617993877991494, 0)
		Weld_15.Parent = clone_23
		task.wait(2.25)
		clone_23:Destroy()
		local clone_42 = ReplicatedStorage.Resources.Todo.jointStruggle.blackgroundbeam:Clone()
		clone_42.Parent = workspace.Effects
		clone_42.CFrame = RootPart_3_upvr.CFrame * CFrame.new(7.461, 1.562, -1.63)
		task.wait(3.45)
		local clone_10 = ReplicatedStorage.Resources.Todo.jointStruggle.Stone2fire:Clone()
		clone_10.Parent = arg1
		clone_10.CFrame = clone_37_upvr.Stone.CFrame
		Utility.Services.Tween:Create(clone_42.m['3'].lomairaa, TweenInfo.new(1), {
			Width0 = 20;
			Width1 = 20;
		}):Play()
		Utility.Services.Tween:Create(clone_42.m2.a2.lomairaa2, TweenInfo.new(1), {
			Width0 = 20;
			Width1 = 20;
		}):Play()
		Utility.Services.Tween:Create(clone_42.m3.s2.lomairaa3, TweenInfo.new(1), {
			Width0 = 1;
			Width1 = 1;
		}):Play()
		task.wait(3.2)
		ColorCorrectionEffect_upvr_2.Enabled = true
		ColorCorrectionEffect_upvr_2.Brightness = 1
		ColorCorrectionEffect_upvr_2.Contrast = 0
		ColorCorrectionEffect_upvr_2.Saturation = 0
		local any_Create_result1_7_upvr = Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(1), {
			Brightness = 0;
		})
		any_Create_result1_7_upvr:Play()
		any_Create_result1_7_upvr.Completed:Connect(function() 
			ColorCorrectionEffect_upvr_2.Enabled = false
			any_Create_result1_7_upvr:Destroy()
		end)
		clone_10:Destroy()
		clone_42:Destroy()
		DepthOfFieldEffect_upvr.Enabled = false
		local clone_35 = ReplicatedStorage.Resources.Todo.jointStruggle.Galaxy:Clone()
		clone_35.Parent = workspace.Effects
		clone_35.CFrame = RootPart_3_upvr.CFrame * CFrame.new(0, 0, -100)
		local clone_28 = ReplicatedStorage.Resources.Todo.jointStruggle.Baseplate:Clone()
		clone_28.Parent = workspace.Effects
		clone_28.CFrame = RootPart_3_upvr.CFrame * CFrame.new(0, -16 / RootPart_3_upvr.Size.Y * 2, 0)
		task.wait(4.5)
		DepthOfFieldEffect_upvr.Enabled = true
		clone_28:Destroy()
		clone_37_upvr:Destroy()
		clone_5_upvr:Destroy()
		task.wait(13.5)
		local clone_12 = ReplicatedStorage.Resources.Todo.jointStruggle.whitebackground:Clone()
		clone_12.Parent = workspace.Effects
		clone_12.CFrame = RootPart_3_upvr.CFrame * CFrame.new(0, 0, -8)
		Utility.Services.Tween:Create(clone_12, TweenInfo.new(1), {
			Size = Vector3.new(100, 100, 1);
		}):Play()
		Utility.Services.Debris:AddItem(clone_12, 3)
		task.wait(2)
		local redLine_upvr = PlayerGui.redLine
		redLine_upvr.B.Visible = true
		Utility.Services.Tween:Create(redLine_upvr.B, TweenInfo.new(0.5), {
			BackgroundTransparency = 0;
		}):Play()
		spawn(function() 
			for i_15 = 1, 86 do
				if redLine_upvr:FindFirstChild(i_15) then
					redLine_upvr:FindFirstChild(i_15).Visible = true
					task.wait(0.04)
					redLine_upvr:FindFirstChild(i_15).Visible = false
				end
			end
		end)
		task.wait(2)
		local clone_6 = ReplicatedStorage.Resources.Todo.jointStruggle.Blackhole:Clone()
		clone_6.Parent = workspace.Effects
		clone_6.CFrame = RootPart_3_upvr.CFrame * CFrame.new(-164.44, 1.374, -3.659)
		for _, v_15 in pairs(clone_35:GetDescendants()) do
			if v_15:IsA("ParticleEmitter") then
				v_15.Enabled = false
			end
		end
		task.wait(1)
		local any_Create_result1_2_upvr = Utility.Services.Tween:Create(redLine_upvr.B, TweenInfo.new(1), {
			BackgroundTransparency = 1;
		})
		any_Create_result1_2_upvr:Play()
		any_Create_result1_2_upvr.Completed:Connect(function() 
			redLine_upvr.B.Visible = false
			any_Create_result1_2_upvr:Destroy()
		end)
		DepthOfFieldEffect_upvr.Enabled = false
		task.wait(4)
		clone_6:Destroy()
		for _, v_16 in pairs(clone_35:GetDescendants()) do
			if v_16:IsA("ParticleEmitter") then
				v_16.Enabled = true
			end
		end
		local clone_14 = ReplicatedStorage.Resources.Todo.jointStruggle.LIGHT:Clone()
		clone_14.Parent = workspace.Effects
		clone_14.CFrame = RootPart_3_upvr.CFrame * CFrame.new(-14.347, -19.035, -53.869)
		Utility.Services.Debris:AddItem(clone_14, 3)
		task.wait(2.8)
		DepthOfFieldEffect_upvr.Enabled = true
		Utility.Services.Debris:AddItem(clone_13_upvr, 5)
		task.wait(4.75)
		local children = PlayerGui.wowsocute:GetChildren()
		local Huh = 0
		repeat
			local var183 = children[math.random(1, #children)]
			var183.Visible = true
			Utility.Modules.GuiShakerModule:ShakeOnce(var183, 4, 0.25, 0)
			task.wait(0.15)
			var183.Visible = false
			Huh += .2
		until Huh > 3.883
		task.wait(4)
		ColorCorrectionEffect_upvr_2.Enabled = true
		ColorCorrectionEffect_upvr_2.Brightness = 1
		local any_Create_result1_upvr_3 = Utility.Services.Tween:Create(ColorCorrectionEffect_upvr_2, TweenInfo.new(2), {
			Brightness = 0;
		})
		any_Create_result1_upvr_3:Play()
		any_Create_result1_upvr_3.Completed:Connect(function() 
			ColorCorrectionEffect_upvr_2:Destroy()
			any_Create_result1_upvr_3:Destroy()
		end)
		clone_35:Destroy()
		DepthOfFieldEffect_upvr:Destroy()
		Utility.Services.Lighting.ClockTime = 12
	end)
	task.wait(var21.Length)
	any_new_result1:Destroy()
end
return module
