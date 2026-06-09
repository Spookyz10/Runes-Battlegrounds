local ReplicatedStorage = game:GetService('ReplicatedStorage')


local module = {
	durationTime = {}
}
local Utility = require(ReplicatedStorage.Utility)
local Parent = require(script.Parent)

function module.dropkickwindup(character : Model,id)
	local RootPart_upvr_3 = character:FindFirstChildOfClass("Humanoid").RootPart
	local Ended 
	local Anim = nil
	local FlashConnec = nil
	for i,v : AnimationTrack in character:FindFirstChildOfClass('Humanoid'):FindFirstChildOfClass('Animator'):GetPlayingAnimationTracks() do
		if v.Animation.AnimationId == id then
			Anim = v
			break
		end
	end
	if Anim == nil then return end
	local l_LinearVelocity_4 = Instance.new("LinearVelocity");
	l_LinearVelocity_4.Attachment0 = RootPart_upvr_3.RootAttachment;
	l_LinearVelocity_4.ForceLimitMode = Enum.ForceLimitMode.PerAxis;
	l_LinearVelocity_4.MaxAxesForce = Vector3.new(1, 0, 1, 0) * 30000;
	l_LinearVelocity_4.RelativeTo = Enum.ActuatorRelativeTo.Attachment0;
	l_LinearVelocity_4.Parent = RootPart_upvr_3;
	
	Anim:GetMarkerReachedSignal('Start'):Once(function()
		task.spawn(function()
			Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.KJ.Jump, 4)
			local clone_2 = ReplicatedStorage.Resources.KJ.startRun:Clone()
			clone_2.Parent = character
			Utility.Services.Tween:Create(l_LinearVelocity_4, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				VectorVelocity = Vector3.zAxis * -250
			}):Play();
			repeat
				clone_2.CFrame = clone_2.CFrame:Lerp(RootPart_upvr_3.CFrame, 0.5)
				task.wait()
			until Ended or not character:IsDescendantOf(game) or not Anim.IsPlaying 
			FlashConnec:Disconnect()

			for _, v_7 in pairs(clone_2:GetDescendants()) do
				if v_7:IsA("Beam") then
					Utility.Services.Tween:Create(v_7, TweenInfo.new(0.25), {
						Width0 = 0;
						Width1 = 0;
					}):Play()
				elseif v_7:IsA("ParticleEmitter") then
					v_7.Enabled = false
				end
			end
			Utility.Services.Debris:AddItem(clone_2, 1)
		end)

	end)
	FlashConnec = Anim:GetMarkerReachedSignal('Flash'):Connect(function()
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.KJ.flash)
	end)
	Anim:GetMarkerReachedSignal('End'):Once(function()
		Ended = true
		FlashConnec:Disconnect()
		local Tween =Utility.Services.Tween:Create(l_LinearVelocity_4, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			VectorVelocity = Vector3.zero
		})
		Tween:Play()
		Tween.Completed:Once(function()
			l_LinearVelocity_4:Destroy()
		end)
	end)
	Anim.Stopped:Once(function()
		if not Ended then
		   Ended = true
		   l_LinearVelocity_4:Destroy()
		end
	end)
	--if Bind then
	--	Bind.Destroying:Once(function()
	--		Ended = true
	--		FlashConnec:Disconnect()
	--		l_LinearVelocity_4.VectorVelocity = Vector3.zero
	--		Utility.Services.Debris:AddItem(l_LinearVelocity_4,0.2)
	--	end)
	--end


end






function module.dropkick(character,victim,id)
	local RootPart_upvr_3 = character:FindFirstChildOfClass("Humanoid").RootPart
	local Torso_upvr_2 = character:FindFirstChild('Torso')
	local Anim = nil
	for i,v : AnimationTrack in character:FindFirstChildOfClass('Humanoid'):FindFirstChildOfClass('Animator'):GetPlayingAnimationTracks() do
		if v.Animation.AnimationId == id then
			Anim = v
			break
		end
	end
	if Anim == nil then return end
	local Transparency = {}
	local Frame
	local Beam
	local function shake_upvr(arg1_2, arg3_2) 
		arg1_2.Visible = true
		arg1_2.Size = arg3_2
		local any_Create_result1 = Utility.Services.Tween:Create(arg1_2, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = arg1_2.Size;
		})
		any_Create_result1:Play()
		any_Create_result1.Completed:Wait()
	end

	if Utility.Services.Players.LocalPlayer.Character == character or Utility.Services.Players.LocalPlayer.Character == victim then
		Parent.Cutscene(ReplicatedStorage.Resources.KJ.dropKickCam, ReplicatedStorage.Resources['CamLetterBox'], RootPart_upvr_3, CFrame.new(0,0,2) *CFrame.Angles(0, 0, 0), ReplicatedStorage.Resources.KJ.dropKickFOV)
		Frame = ReplicatedStorage.Resources.KJ["20-20-20DropKick"]:Clone()
		Frame.Parent = Utility.Idk.PlayerGui.PlaceHolder
		Frame.Visible = false
		Anim:GetMarkerReachedSignal('1'):Once(function()
			if Frame then
				Frame.Visible = true
				shake_upvr(Frame['1'],UDim2.new(0.35, 0, 0.5, 0))
			end
		end)
		Anim:GetMarkerReachedSignal('2'):Once(function()
			if Frame then
				shake_upvr(Frame['2'],UDim2.new(0.35, 0, 0.5, 0))
			end
		end)
		Anim:GetMarkerReachedSignal('3'):Once(function()
			if Frame then
				shake_upvr(Frame['3'],UDim2.new(0.35, 0, 0.5, 0))
			end
		end)
		Anim:GetMarkerReachedSignal('4'):Once(function()
			if Frame then
				shake_upvr(Frame['4'],UDim2.new(0.95, 0, 0.59, 0))
			end
		end)
		Utility.Modules.soundPlaying:play(ReplicatedStorage.Resources.KJ.dropkickWind, Utility.Services.Sound);
	else
		Utility.Modules.soundPlaying:play(ReplicatedStorage.Resources.KJ.dropkickWind, RootPart_upvr_3);
	end
	Anim:GetMarkerReachedSignal('startDropKick'):Once(function()
		local clone_9 = ReplicatedStorage.Resources.KJ.Kickline:Clone()
		clone_9.Parent = workspace.Effects
		clone_9.CFrame = CFrame.new(victim.Torso.Position, victim.Torso.Position + RootPart_upvr_3.CFrame.LookVector) * CFrame.Angles(0, (-math.pi/2), 0) * CFrame.new(0, -character:GetExtentsSize().Y / 2, 0)
		for _, v_3 in clone_9:GetDescendants() do
			if v_3:IsA("Beam") then
				Utility.Services.Tween	:Create(v_3, TweenInfo.new(2), {
					TextureSpeed = 0.015;
				}):Play()
				Utility.Services.Tween	:Create(v_3, TweenInfo.new(6.85), {
					Width0 = 0;
					Width1 = 0;
				}):Play()
			end
		end
		Utility.Services.Debris:AddItem(clone_9, 6.85)
		local clone_3 = ReplicatedStorage.Resources.KJ.air:Clone()
		clone_3.Parent = workspace.Effects
		local Weld = Instance.new("Weld")
		Weld.Part0 = Torso_upvr_2
		Weld.Part1 = clone_3
		Weld.Parent = clone_3
		Weld.C0 = CFrame.new(0, -4, 0)
		for _, v_4 in clone_3:GetDescendants() do
			if v_4:IsA("ParticleEmitter") then
				Utility.Services.Tween	:Create(v_4, TweenInfo.new(3), {
					TimeScale = 0.05;
				}):Play()
			end
		end
		Utility.Services.Debris:AddItem(clone_3, 5)
		local clone = ReplicatedStorage.Resources.KJ.Shockwave:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = CFrame.new(character.Torso.Position, character.Torso.Position + RootPart_upvr_3.CFrame.LookVector)
		clone.Transparency = 0.85
		local Weld_8 = Instance.new("Weld")
		Weld_8.Part0 = Torso_upvr_2
		Weld_8.Part1 = clone
		Weld_8.Parent = clone
		Utility.Services.Tween	:Create(Weld_8, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			C0 = CFrame.Angles(0, 2.0943951023931953, 0) * CFrame.new(0, 2, 0);
		}):Play()
		Utility.Services.Tween	:Create(clone, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = Vector3.new(5, 10, 5);
			Transparency = 1;
		}):Play()
		Utility.Services.Debris:AddItem(clone, 5)
		local clone_8 = ReplicatedStorage.Resources.KJ.BROPUTITURSELFT:Clone()
		clone_8.Parent = workspace.Effects
		clone_8.CFrame = CFrame.new(character.Torso.Position, character.Torso.Position + RootPart_upvr_3.CFrame.LookVector)
		local Weld_5 = Instance.new("Weld")
		Weld_5.Part0 = Torso_upvr_2
		Weld_5.Part1 = clone_8
		Weld_5.Parent = clone_8
		Weld_5.C0 = CFrame.new(0, 15, 0) * CFrame.Angles(0, 0, (math.pi/2))
		Utility.Services.Tween:Create(Weld_5, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			C0 = CFrame.Angles(0, 2.0943951023931953, (math.pi/2));
		}):Play()
		Utility.Services.Tween	:Create(clone_8.Decal, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 1;
		}):Play()
		Utility.Services.Debris:AddItem(clone_8, 5)
	end)

	Anim:GetMarkerReachedSignal('Kick'):Once(function()
		if Utility.Services.Players.LocalPlayer.Character == character or Utility.Services.Players.LocalPlayer.Character == victim then
			Beam =ReplicatedStorage.Resources.KJ.blackgroundbeam:Clone()
			Beam.Parent = workspace.Effects
			Beam.CFrame = CFrame.new(character.Torso.Position, character.Torso.Position + RootPart_upvr_3.CFrame.LookVector) * CFrame.new(-13, 12, -12) * CFrame.Angles(0, (-math.pi/2), 0)
			for _, v_5 in workspace.Map:GetDescendants() do
				if v_5:IsA("BasePart") or v_5:IsA("Texture") or v_5:IsA("Decal") then
					if 1 > v_5.Transparency then
						Transparency[v_5] = v_5.Transparency
						v_5.Transparency = 1
						task.delay(7,function()
							if Transparency[v_5] ~= nil then
								v_5.Transparency = Transparency[v_5]
								Transparency[v_5] = nil
								if Beam.Parent then
									Beam:Destroy()
								end
							end
						end)
					end
				end
			end
		end
	end)
	Anim:GetMarkerReachedSignal('End'):Once(function()
		Parent.Emit(RootPart_upvr_3, ReplicatedStorage.Resources.KJ.Jump, 4)
		if Beam then
			Beam:Destroy()
		end
		for i_6, v_6 in Transparency do
			i_6.Transparency = v_6
		end
		table.clear(Transparency)
		if Frame then
			Frame:Destroy()
		end
	end)




end

return module
