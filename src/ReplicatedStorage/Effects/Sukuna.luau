local ReplicatedStorage = game:GetService('ReplicatedStorage')


local module = {
	durationTime = {}
}
local Utility = require(ReplicatedStorage.Utility)
local Parent = require(script.Parent)

local module = {}
function module.domain(arg1, arg2) 
	local class_Humanoid_2_upvr = arg1:FindFirstChildOfClass("Humanoid")
	local RootPart_upvr_4 = class_Humanoid_2_upvr.RootPart
	local any_new_result1_upvr = Utility.Modules.Trove.new()
	local var61
	for _, v_4 in ipairs(class_Humanoid_2_upvr.Animator:GetPlayingAnimationTracks()) do
		if v_4.Animation and v_4.Animation.AnimationId == arg2 then
			var61 = v_4
		end
	end
	any_new_result1_upvr:Add(var61)
	task.spawn(function() 
		if Utility.Services.Players.LocalPlayer:DistanceFromCharacter(RootPart_upvr_4.Position) <= 500 then
			Parent.screenEffect(8)
		end
	end)
	task.spawn(function() 
		if Utility.Services.Players.LocalPlayer.Character == arg1 then
			--Parent.Cutscene(ReplicatedStorage.Resources.Sukuna.Domain.Cam, ReplicatedStorage.Resources.Camera, RootPart_upvr_4, nil, ReplicatedStorage.Resources.Sukuna.Domain.FOV, true)
			Parent.Cutscene(ReplicatedStorage.Resources.Sukuna.Domain.Cam, ReplicatedStorage.Resources.Camera, RootPart_upvr_4, nil, ReplicatedStorage.Resources.Sukuna.Domain.FOV, true)
		end
	end)
	local clone_upvr = ReplicatedStorage.Resources.Sukuna.Domain.domain_3_n:Clone()
	clone_upvr.Parent = workspace.Effects
	clone_upvr:PivotTo(RootPart_upvr_4.CFrame * CFrame.new(0, -3, 0))
	any_new_result1_upvr:Add(clone_upvr)
	local any_play_result1_upvr = Utility.Modules.soundPlaying:play(ReplicatedStorage.Resources.Sukuna["sukuna domain new"], Utility.Services.Sound)
	any_new_result1_upvr:Add(Utility.Services.RunService.PreRender:Connect(function() 
		if 600 < Utility.Services.Players.LocalPlayer:DistanceFromCharacter(clone_upvr.PrimaryPart.Position) then
			Utility.Services.Tween:Create(any_play_result1_upvr, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
		else
			Utility.Services.Tween:Create(any_play_result1_upvr, TweenInfo.new(1), {
				Volume = 1;
			}):Play()
		end
	end))
	local any_Add_result1_upvr = any_new_result1_upvr:Add(Utility.Modules.animPlaying:loadAnimation(clone_upvr, ReplicatedStorage.Resources.Sukuna.Domain.AnimS))
	any_Add_result1_upvr:Play(0)
	any_new_result1_upvr:Add(function() 
		clone_upvr:Destroy()
		if Utility.Services.Players.LocalPlayer:DistanceFromCharacter(RootPart_upvr_4.Position) <= 500 then
			Parent.Brightness(-1, 2, Color3.fromRGB(0, 0, 0))
		end
		if class_Humanoid_2_upvr.Health <= 0 or not arg1:IsDescendantOf(game) then
			any_play_result1_upvr:Destroy()
		end
	end)
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Black"):Once(function() 
		Parent.Emit(RootPart_upvr_4, ReplicatedStorage.Resources.Sukuna.Domain.watersplash, 2, CFrame.new(0, 0, -4))
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Void"):Once(function()
		local clone_17_upvr = ReplicatedStorage.Resources.Sukuna.Domain.Black:Clone()
		clone_17_upvr.Parent = workspace.Effects
		clone_17_upvr:PivotTo(RootPart_upvr_4.CFrame * CFrame.new(0, 0, 25))
		task.delay(5.55, function() 
			for _, v_5 in clone_17_upvr:GetDescendants() do
				if v_5:IsA("ParticleEmitter") then
					v_5.Enabled = false
				end
			end
			task.wait(1)
			Utility.Services.Debris:AddItem(clone_17_upvr, 1.65)
		end)
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Grab"):Once(function() 
		Parent.Emit(RootPart_upvr_4, ReplicatedStorage.Resources.Sukuna.Domain.watersplash, 2, CFrame.new(0, ReplicatedStorage.Resources.Sukuna.Domain.bigsplash.Size.Y / 2, -4))
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("UI"):Once(function() 
		if Utility.Services.Players.LocalPlayer:DistanceFromCharacter(RootPart_upvr_4.Position) <= 150 then
			local clone_2 = ReplicatedStorage.Resources.Sukuna.DE:Clone()
			clone_2.Parent = Utility.Services.Players.LocalPlayer.PlayerGui.MainScreen
			for _, v_6 in clone_2:GetChildren() do
				Utility.Modules.GuiShakerModule:ShakeOnce(v_6, 4, 1, 0)
			end
			task.wait(2)
			Utility.Services.Tween:Create(clone_2, TweenInfo.new(1), {
				GroupTransparency = 1;
			}):Play()
			Utility.Services.Debris:AddItem(clone_2, 1)
		end
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Out"):Once(function() 
		Parent.Emit(RootPart_upvr_4, ReplicatedStorage.Resources.Sukuna.Domain.bigsplash, 2, CFrame.new(0, ReplicatedStorage.Resources.Sukuna.Domain.bigsplash.Size.Y / 2, -4))
		local clone_13 = ReplicatedStorage.Resources.Sukuna.Domain.idleSplash:Clone()
		clone_13.Parent = clone_upvr
		clone_13.CFrame = clone_upvr.PrimaryPart.CFrame * CFrame.new(0, 0.15, 0)
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Freeze"):Once(function() 
		any_Add_result1_upvr:AdjustSpeed(0)
	end))
	any_new_result1_upvr:Add(var61:GetMarkerReachedSignal("Attack"):Once(function() 
		for _, v_7 in clone_upvr:GetDescendants() do
			if v_7:IsA("ParticleEmitter") then
				v_7.Enabled = true
			end
		end
		local clone_7 = ReplicatedStorage.Resources.Sukuna.Domain.cleave:Clone()
		clone_7:PivotTo(RootPart_upvr_4.CFrame * CFrame.new(0, -3, 0))
		clone_7.Parent = workspace.Effects
		local any_Raycast_result1_4 = Utility.Modules.RayCast(RootPart_upvr_4.Position, Vector3.yAxis * -1000)
		if any_Raycast_result1_4 then
			clone_7.thing.Position = any_Raycast_result1_4.Position
		end
		local clone_upvr_2 = ReplicatedStorage.Resources.Sukuna.Domain.ColorCorrection:Clone()
		clone_upvr_2.Parent = Utility.Services.Lighting
		clone_upvr_2.TintColor = Color3.fromRGB(255, 255, 255)
		Utility.Services.Tween:Create(clone_upvr_2, TweenInfo.new(1), {
			TintColor = Color3.fromRGB(255, 132, 70);
		}):Play()
		Parent.impactFrame(3, {RootPart_upvr_4, 500})
		any_new_result1_upvr:Add(Utility.Services.RunService.PreRender:Connect(function()
			Parent.newCameraShake({{1, 10, 0, 1}, Vector3.yAxis * 3 + Vector3.xAxis * 3}, {clone_upvr.PrimaryPart, 600})
		end))
		any_new_result1_upvr:Add(clone_7)
		any_new_result1_upvr:Add(function() 
			Utility.Services.Tween:Create(clone_upvr_2, TweenInfo.new(1), {
				TintColor = Color3.fromRGB(255, 255, 255);
			}):Play()
			Utility.Services.Debris:AddItem(clone_upvr_2, 1)
		end)
	end))
	any_new_result1_upvr:AttachToInstance(arg1)
	any_new_result1_upvr:Add(Utility.Services.Collection:GetInstanceRemovedSignal("Domain"):Connect(function(arg1_2) 
		if arg1_2 ~= arg1 then
		else
			any_new_result1_upvr:Destroy()
		end
	end))
	any_new_result1_upvr:Add(class_Humanoid_2_upvr.Died:Once(function()
		any_new_result1_upvr:Destroy()
	end))
end
function module.flameArrow(arg1, arg2, arg3, arg4) 
	if arg4 then
		local clone_15 = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.explosion:Clone()
		clone_15.Parent = workspace.Effects
		local any_Raycast_result1_2 = Utility.Modules.RayCast(arg3, Vector3.new(0, -50, 0))
		if any_Raycast_result1_2 then
			clone_15:SetPrimaryPartCFrame(CFrame.new(any_Raycast_result1_2.Position))
		else
			clone_15:SetPrimaryPartCFrame(CFrame.new(arg3))
		end
		Utility.Modules.soundPlaying:play(ReplicatedStorage.Resources.Sukuna.fuga_explode, clone_15.PrimaryPart)
		for _, v_8 in clone_15:GetDescendants() do
			if not v_8:FindFirstAncestor("ImpactFrame") then
				if v_8:IsA("ParticleEmitter") then
					v_8.Enabled = false
				elseif v_8:IsA("Beam") then
					v_8.Enabled = false
				elseif v_8:IsA("PointLight") then
					v_8.Enabled = false
				end
			end
		end
		for _, v_9 in clone_15.ImpactFrame.Charge:GetDescendants() do
			if v_9:IsA("ParticleEmitter") then
				v_9.Enabled = true
			end
		end
		for _, v_10 in clone_15.ImpactFrame.impactnuke:GetDescendants() do
			if v_10:IsA("Beam") then
				Utility.Services.Tween:Create(v_10, TweenInfo.new(1.2), {
					Width0 = 0;
					Width1 = 0;
				}):Play()
			end
		end
		task.wait(0.55)
		for _, v_11 in clone_15.ImpactFrame:GetDescendants() do
			if v_11:IsA("ParticleEmitter") then
				v_11.Enabled = false
			end
		end
		for _, v_12 in clone_15.ImpactFrame.impact:GetDescendants() do
			if v_12:IsA("ParticleEmitter") then
				v_12:Emit(v_12:GetAttribute("EmitCount"))
			end
		end
		task.wait(0.35)
		local clone_4 = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.Glass:Clone()
		clone_4.Parent = workspace.Effects
		clone_4.CFrame = clone_15.PrimaryPart.CFrame
		clone_4.Size = Vector3.new()
		Utility.Services.Tween:Create(clone_4, TweenInfo.new(0.35), {
			Transparency = 1;
			Size = Vector3.new(500, 500, 500);
		}):Play()
		Utility.Services.Debris:AddItem(clone_4, 0.35)
		for _, v_13 in clone_15:GetDescendants() do
			if not v_13:FindFirstAncestor("ImpactFrame") then
				if v_13:IsA("ParticleEmitter") then
					v_13.Enabled = true
				elseif v_13:IsA("Beam") then
					v_13.Enabled = true
				elseif v_13:IsA("PointLight") then
					v_13.Enabled = true
					v_13.Brightness = 0
					Utility.Services.Tween:Create(v_13, TweenInfo.new(1), {
						Brightness = v_13.Brightness;
					}):Play()
				end
			end
		end
		Parent.debrisZone(clone_15.PrimaryPart, 140, 7, 25, nil, nil, Vector3.new(0, -100, 0))
		task.wait(3)
		for _, v_14 in clone_15:GetDescendants() do
			if v_14:IsA("ParticleEmitter") then
				v_14.Enabled = false
			elseif v_14:IsA("Beam") then
				v_14.Enabled = false
			elseif v_14:IsA("PointLight") then
				Utility.Services.Tween:Create(v_14, TweenInfo.new(1), {
					Brightness = 0;
				}):Play()
			end
		end
		Utility.Services.Debris:AddItem(clone_15, 8)
	else
		local clone_12_upvr = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.Arm:Clone()
		clone_12_upvr.Parent = arg1
		local Weld_9 = Instance.new("Weld")
		Weld_9.Parent = clone_12_upvr
		Weld_9.Part0 = arg1["Left Arm"]
		Weld_9.Part1 = clone_12_upvr
		local clone_3_upvr = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.Arm:Clone()
		clone_3_upvr.Parent = arg1
		local Weld_2 = Instance.new("Weld")
		Weld_2.Parent = clone_3_upvr
		Weld_2.Part0 = arg1["Right Arm"]
		Weld_2.Part1 = clone_3_upvr
		for _, v_25 in clone_3_upvr:GetDescendants() do
			if v_25:IsA("Trail") or v_25:IsA("ParticleEmitter") then
				v_25.Enabled = false
			end
		end
		task.delay(1.6, function() -- Line 358
            --[[ Upvalues[1]:
                [1]: clone_3_upvr (readonly)
            ]]
			for _, v_26 in clone_3_upvr:GetDescendants() do
				if v_26:IsA("Trail") or v_26:IsA("ParticleEmitter") then
					v_26.Enabled = true
				end
			end
		end)
		local tbl_upvr = {}
		local RootPart_upvr = arg1:FindFirstChildOfClass("Humanoid").RootPart
		local function eventAdded_upvr() -- Line 367, Named "eventAdded"
            --[[ Upvalues[8]:
                [1]: clone_12_upvr (readonly)
                [2]: clone_3_upvr (readonly)
                [3]: Parent (copied, readonly)
                [4]: RootPart_upvr (readonly)
                [5]: ReplicatedStorage (copied, readonly)
                [6]: arg1 (readonly)
                [7]: tbl_upvr (readonly)
                [8]: Utility (copied, readonly)
            ]]
			return {
				['1'] = function() -- Line 369
                    --[[ Upvalues[7]:
                        [1]: clone_12_upvr (copied, readonly)
                        [2]: clone_3_upvr (copied, readonly)
                        [3]: Parent (copied, readonly)
                        [4]: RootPart_upvr (copied, readonly)
                        [5]: ReplicatedStorage (copied, readonly)
                        [6]: arg1 (copied, readonly)
                        [7]: tbl_upvr (copied, readonly)
                    ]]
					for _, v_27 in clone_12_upvr:GetDescendants() do
						if v_27:IsA("Trail") then
							v_27.Enabled = false
						end
					end
					for _, v_28 in clone_12_upvr.d1:GetChildren() do
						if v_28:IsA("Beam") then
							v_28.Attachment1 = clone_3_upvr.d1
						end
					end
					Parent.Emit(RootPart_upvr, ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.fireslap, 2, CFrame.new(0, 0, -2.5))
					local clone_6 = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.thingy2:Clone()
					clone_6.Parent = arg1
					table.insert(tbl_upvr, clone_6)
					local Weld = Instance.new("Weld")
					Weld.Parent = clone_6
					Weld.Part0 = RootPart_upvr
					Weld.Part1 = clone_6
					Weld.C0 = CFrame.new(0, -0.35, -2.5)
				end;
				['2'] = function()
					for _, v_29 in clone_12_upvr:GetDescendants() do
						if v_29:IsA("ParticleEmitter") or v_29:IsA("Trail") then
							v_29.Enabled = false
						elseif v_29:IsA("PointLight") then
							Utility.Services.Tween:Create(v_29, TweenInfo.new(1), {
								Brightness = 0;
							}):Play()
						end
					end
					Utility.Services.Debris:AddItem(clone_12_upvr, 1)
					for _, v_30 in clone_3_upvr:GetDescendants() do
						if v_30:IsA("ParticleEmitter") or v_30:IsA("Trail") then
							v_30.Enabled = false
						elseif v_30:IsA("PointLight") then
							Utility.Services.Tween:Create(v_30, TweenInfo.new(1), {
								Brightness = 0;
							}):Play()
						end
					end
					Utility.Services.Debris:AddItem(clone_3_upvr, 1)
					for _, v_31 in tbl_upvr do
						for _, v_32 in v_31:GetDescendants() do
							if v_32:IsA("ParticleEmitter") then
								v_32.Enabled = false
							elseif v_32:IsA("PointLight") then
								Utility.Services.Tween:Create(v_32, TweenInfo.new(1), {
									Brightness = 0;
								}):Play()
							end
						end
						Utility.Services.Debris:AddItem(v_31, 2)
					end
					local clone_10 = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.Arrow:Clone()
					clone_10.Parent = arg1
					table.insert(tbl_upvr, clone_10)
					local Weld_3 = Instance.new("Weld")
					Weld_3.Parent = clone_10
					Weld_3.Part0 = RootPart_upvr
					Weld_3.Part1 = clone_10
					Weld_3.C0 = CFrame.new(1, 0.8, -0.5) * CFrame.Angles(0, 0.2617993877991494, 0)
					for _, v_33 in clone_10:GetDescendants() do
						if v_33:IsA("Beam") then
							Utility.Services.Tween:Create(v_33, TweenInfo.new(1), {
								Width0 = v_33.Width0;
								Width1 = v_33.Width1;
							}):Play()
							v_33.Width0 = 0
							v_33.Width1 = 0
						end
					end
					for _, v_34 in clone_12_upvr.d1:GetChildren() do
						if v_34:IsA("Beam") then
							v_34.Attachment1 = nil
						end
					end
					local clone = ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.firefit:Clone()
					clone.Parent = arg1
					table.insert(tbl_upvr, clone)
					for _, v_35 in clone:GetDescendants() do
						if v_35:IsA("PointLight") then
							v_35.Brightness = 0
							Utility.Services.Tween:Create(v_35, TweenInfo.new(1), {
								Brightness = v_35.Brightness;
							}):Play()
						end
					end
					local Weld_7 = Instance.new("Weld")
					Weld_7.Parent = clone
					Weld_7.Part0 = RootPart_upvr
					Weld_7.Part1 = clone
					Weld_7.C0 = CFrame.new(0, -3, 0)
				end;
				['3'] = function() 
					clone_12_upvr:Destroy()
					clone_3_upvr:Destroy()
					for _, v_36 in tbl_upvr do
						for _, v_37 in v_36:GetDescendants() do
							if v_37:IsA("ParticleEmitter") or v_37:IsA("Beam") then
								v_37.Enabled = false
							elseif v_37:IsA("PointLight") then
								Utility.Services.Tween:Create(v_37, TweenInfo.new(1), {
									Brightness = 0;
								}):Play()
							end
						end
						Utility.Services.Debris:AddItem(v_36, 2)
					end
					Parent.Emit(RootPart_upvr, ReplicatedStorage.Resources.Sukuna.FlameArrowFolder.shot, 3)
				end;
			}
		end
		
		arg2.ChildAdded:Connect(function(arg1_3)
			if eventAdded_upvr()[arg1_3.Name] then
				eventAdded_upvr()[arg1_3.Name]()
			end
		end)
		repeat
			Utility.Services.RunService.Stepped:Wait()
		until not arg2:IsDescendantOf(game) and not arg1:IsDescendantOf(game)
		for _, v_38 in tbl_upvr do
			for _, v_39 in v_38:GetDescendants() do
				if v_39:IsA("ParticleEmitter") or v_39:IsA("Beam") then
					v_39.Enabled = false
				elseif v_39:IsA("PointLight") then
					Utility.Services.Tween:Create(v_39, TweenInfo.new(1), {
						Brightness = 0;
					}):Play()
				end
			end
			Utility.Services.Debris:AddItem(v_38, 2)
		end
		
	end
end
function module.rushBeatdown(arg1, arg2) -- Line 512
    --[[ Upvalues[3]:
        [1]: Utility (readonly)
        [2]: ReplicatedStorage (readonly)
        [3]: Parent (readonly)
    ]]
	local any_GetPlayerFromCharacter_result1_upvr = Utility.Services.Players:GetPlayerFromCharacter(arg1)
	local class_Humanoid_3 = arg1:FindFirstChildOfClass("Humanoid")
	local RootPart_upvr_3 = class_Humanoid_3.RootPart
	local var255_upvw = false
	local var259
	for _, v_15 in ipairs(class_Humanoid_3.Animator:GetPlayingAnimationTracks()) do
		if v_15.Animation and v_15.Animation.AnimationId == ReplicatedStorage.Resources.Sukuna.rushBeatdown.AnimationId then
			var259 = v_15
		end
	end
	local tbl_upvr_2 = {}
	local function endFunction() -- Line 530
        --[[ Upvalues[2]:
            [1]: tbl_upvr_2 (readonly)
            [2]: var255_upvw (read and write)
        ]]
		for _, v_16 in tbl_upvr_2 do
			v_16:Disconnect()
		end
		var255_upvw = true
	end
	if any_GetPlayerFromCharacter_result1_upvr == Utility.Services.Players.LocalPlayer then
		Parent.newlinearVelocity(RootPart_upvr_3, Vector3.zAxis * -140, Vector3.new(1, 0, 1) * 80000, {{0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
			VectorVelocity = Vector3.zero;
		}}, 0.5)
		Parent.fieldOfView(true, 50, 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
	Parent.newCameraShake({{1, 5, 0, 3}, Vector3.yAxis * 5 + Vector3.xAxis * 5}, {RootPart_upvr_3, 35})
	local clone_11 = ReplicatedStorage.Resources.Sukuna.rushBeatdownF.Start:Clone()
	clone_11.Parent = arg1
	local Weld_6 = Instance.new("Weld")
	Weld_6.Part0 = RootPart_upvr_3
	Weld_6.Part1 = clone_11
	Weld_6.Parent = arg1
	Parent.EmitOnly(clone_11)
	Utility.Services.Debris:AddItem(clone_11, 1)
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('1'):Once(function() -- Line 553
        --[[ Upvalues[5]:
            [1]: any_GetPlayerFromCharacter_result1_upvr (readonly)
            [2]: Utility (copied, readonly)
            [3]: Parent (copied, readonly)
            [4]: RootPart_upvr_3 (readonly)
            [5]: ReplicatedStorage (copied, readonly)
        ]]
		if any_GetPlayerFromCharacter_result1_upvr == Utility.Services.Players.LocalPlayer then
			Parent.fieldOfView(false, 70)
		end
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 15 + Vector3.xAxis * 15}, {RootPart_upvr_3, 35})
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.Sukuna.rushBeatdownF.Cleave, 2)
		Parent.impactFrame(2, {RootPart_upvr_3, 35})
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('2'):Once(function() -- Line 561
        --[[ Upvalues[3]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: ReplicatedStorage (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 4 + Vector3.xAxis * 4}, {RootPart_upvr_3, 35})
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.Sukuna.rushBeatdownF.Cleave2, 2)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('3'):Once(function() -- Line 568
        --[[ Upvalues[3]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: ReplicatedStorage (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 4 + Vector3.xAxis * 4}, {RootPart_upvr_3, 35})
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.Sukuna.rushBeatdownF.Cleave3, 2)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('4'):Once(function() -- Line 575
        --[[ Upvalues[3]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: ReplicatedStorage (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 4 + Vector3.xAxis * 4}, {RootPart_upvr_3, 35})
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.Sukuna.rushBeatdownF.dismantleHit1, 2)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('6'):Once(function() -- Line 582
        --[[ Upvalues[4]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: any_GetPlayerFromCharacter_result1_upvr (readonly)
            [4]: Utility (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 15 + Vector3.xAxis * 15}, {RootPart_upvr_3, 35})
		if any_GetPlayerFromCharacter_result1_upvr == Utility.Services.Players.LocalPlayer then
			Parent.newlinearVelocity(RootPart_upvr_3, Vector3.zAxis * -300, Vector3.new(1, 0, 1) * 80000, {{1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
				VectorVelocity = Vector3.zero;
			}}, 1.5)
		end
		--Parent.rockFlakes(RootPart_upvr_3, 0.5, 0.6)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('7'):Once(function() -- Line 589
        --[[ Upvalues[3]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: ReplicatedStorage (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 15 + Vector3.xAxis * 15}, {RootPart_upvr_3, 35})
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.Sukuna.rushBeatdownF.Cleave2, 2)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal('8'):Once(function() -- Line 593
        --[[ Upvalues[7]:
            [1]: any_GetPlayerFromCharacter_result1_upvr (readonly)
            [2]: Utility (copied, readonly)
            [3]: Parent (copied, readonly)
            [4]: RootPart_upvr_3 (readonly)
            [5]: ReplicatedStorage (copied, readonly)
            [6]: var255_upvw (read and write)
            [7]: arg1 (readonly)
        ]]
		if any_GetPlayerFromCharacter_result1_upvr == Utility.Services.Players.LocalPlayer then
			Parent.newlinearVelocity(RootPart_upvr_3, Vector3.zAxis * -100, Vector3.new(1, 0, 1) * 80000, {{1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
				VectorVelocity = Vector3.zAxis * -150;
			}}, 3)
		end
		local clone_5 = ReplicatedStorage.Resources.Sukuna.rushBeatdownF.dismantleHit2:Clone()
		clone_5.Parent = workspace.Effects
		local Weld_8 = Instance.new("Weld")
		Weld_8.Parent = clone_5
		Weld_8.Part0 = RootPart_upvr_3
		Weld_8.Part1 = clone_5
		repeat
			Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 1 + Vector3.xAxis * 1}, {RootPart_upvr_3, 35})
			local any_Raycast_result1_3 = Utility.Modules.RayCast(RootPart_upvr_3.Position, Vector3.new(0, -5, 0))
			if any_Raycast_result1_3 then
				for _, v_17 in next, clone_5:GetDescendants() do
					if v_17:IsA("ParticleEmitter") and v_17.Parent.Name == "Smoke" then
						v_17.Color = ColorSequence.new(any_Raycast_result1_3.Instance.Color)
					end
				end
			end
			task.wait()
		until var255_upvw or not arg1:IsDescendantOf(game)
		clone_5.Anchored = true
		Weld_8:Destroy()
		for _, v_18 in clone_5:GetDescendants() do
			if v_18:IsA("ParticleEmitter") then
				v_18.Enabled = false
			end
		end
		Utility.Services.Debris:AddItem(clone_5, 2)
	end))
	table.insert(tbl_upvr_2, var259:GetMarkerReachedSignal("10"):Once(function() -- Line 628
        --[[ Upvalues[6]:
            [1]: Parent (copied, readonly)
            [2]: RootPart_upvr_3 (readonly)
            [3]: any_GetPlayerFromCharacter_result1_upvr (readonly)
            [4]: Utility (copied, readonly)
            [5]: var255_upvw (read and write)
            [6]: ReplicatedStorage (copied, readonly)
        ]]
		Parent.newCameraShake({{1, 5, 0, 2}, Vector3.yAxis * 35 + Vector3.xAxis * 35}, {RootPart_upvr_3, 35})
		if any_GetPlayerFromCharacter_result1_upvr == Utility.Services.Players.LocalPlayer then
			Parent.newlinearVelocity(RootPart_upvr_3, Vector3.zAxis * -350, Vector3.new(1, 0, 1) * 80000, {{1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
				VectorVelocity = Vector3.zero;
			}}, 1)
		end
		var255_upvw = true
		local clone_16 = ReplicatedStorage.Resources.Sukuna.rushBeatdownF.im1:Clone()
		clone_16.Parent = workspace.Effects
		clone_16.CFrame = RootPart_upvr_3.CFrame
		local Weld_5 = Instance.new("Weld")
		Weld_5.Parent = clone_16
		Weld_5.Part0 = RootPart_upvr_3
		Weld_5.Part1 = clone_16
		task.wait(0.35)
		for _, v_19 in clone_16:GetDescendants() do
			if v_19:IsA("ParticleEmitter") then
				v_19.Enabled = false
			end
		end
		Utility.Services.Debris:AddItem(clone_16, 1)
	end))
	table.insert(tbl_upvr_2, class_Humanoid_3.Died:Once(endFunction))
	table.insert(tbl_upvr_2, arg1.AncestryChanged:Once(endFunction))
	task.wait(var259.Length)
	for _, v_20 in tbl_upvr_2 do
		v_20:Disconnect()
	end
	var255_upvw = true
end
return module
