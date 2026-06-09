local Utility = require(game.ReplicatedStorage.Utility)
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CurrentCamera_upvr = workspace.CurrentCamera
local l_Trove_0 = Utility.Modules.Trove
local CameraShaker_upvr = Utility.Modules.CameraShaker
local module = {}
local LocalPlayer = nil
local PlayerGui = nil
local l_CurrentCamera_0 = workspace.CurrentCamera
local Brightness_2_upvr = Utility.Services.Lighting.Brightness
if Utility.Services.RunService:IsClient() then
	LocalPlayer = Utility.Services.Players.LocalPlayer
	PlayerGui = LocalPlayer.PlayerGui
end

function module.fieldOfView(arg1, arg2, arg3, arg4, arg5) 
	task.spawn(function()

		local var104 = arg4
		if not var104 then
			var104 = Enum.EasingStyle.Linear
		end
		arg4 = var104
		var104 = arg5
		local var105 = var104
		if not var105 then
			var105 = Enum.EasingDirection.InOut
		end
		arg5 = var105
		arg2 = arg2 or 100
		if arg1 then
			local tbl_2 = {}
			tbl_2.FieldOfView = arg2
			local any_Create_result1 =   Utility.Services.Tween:Create(CurrentCamera_upvr, TweenInfo.new(arg3 or 1, arg4, arg5), tbl_2)
			any_Create_result1:Play()
			any_Create_result1.Completed:Wait()
			any_Create_result1:Destroy()
		else
			CurrentCamera_upvr.FieldOfView = arg2
		end
	end)
end

function module.screenEffect(arg1, arg2) 
	warn('Screen')
	local clone_4_upvr = ReplicatedStorage.Resources.ScreenEffect:Clone()
	clone_4_upvr.Parent = PlayerGui
	if arg2 then
		clone_4_upvr.ImageLabel.ImageTransparency = 0
		Utility.Services.Lighting.Brightness = 0
	else
		Utility.Services.Tween:Create(clone_4_upvr.ImageLabel, TweenInfo.new(2.15, Enum.EasingStyle.Linear), {
			ImageTransparency = 0;
		}):Play()
		Utility.Services.Tween:Create(Utility.Services.Lighting, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0;
		}):Play()
	end
	task.delay(arg1, function() 
		if not clone_4_upvr:IsDescendantOf(game) then
		else
			Utility.Services.Tween:Create(Utility.Services.Lighting, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Brightness = Brightness_2_upvr;
			}):Play()
			Utility.Services.Tween:Create(clone_4_upvr.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				ImageTransparency = 1;
			}):Play()
			Utility.Services.Debris:AddItem(clone_4_upvr, 1)
		end
	end)
end

function module.Cutscene(v91, v92, v93, v94, v95, v96) --[[ Line: 238 ]] --[[ Name: Cutscene ]]
	if l_CurrentCamera_0.CameraType == Enum.CameraType.Scriptable then
		return;
	else
		v92 = v92 or ReplicatedStorage.Resources.CameraRig;
		local v97 = l_Trove_0.new();
		local l_Character_0 = LocalPlayer.Character;
		local l_Humanoid_0 = l_Character_0:FindFirstChildOfClass("Humanoid");
		if not l_Humanoid_0.RootPart and not l_Character_0.PrimaryPart then
			local _ = l_Character_0.HumanoidRootPart;
		end;
		v97:AttachToInstance(l_Character_0);
		if not v94 then
			v94 = CFrame.new(Vector3.zero);
		end;
		local v101 = v92:Clone();
		v101.Parent = workspace.Effects;
		v101:PivotTo(v93.CFrame * v94);
		local v102 = Utility.Modules.animPlaying:loadAnimation(v101, v91);
		v102:Play();
		l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable;
		l_Humanoid_0.AutoRotate = false;
		if v95 then
			local v103 = 0;
			do
				local l_v103_0 = v103;
				v97:Add(Utility.Services.RunService.PreRender:Connect(function(v105) --[[ Line: 265 ]]
					local v106 = v105 * 60;
					l_v103_0 = l_v103_0 + v106;
					local l_v95_FirstChild_0 = v95:FindFirstChild((tonumber((math.ceil(l_v103_0)))));
					if l_v95_FirstChild_0 then
						l_CurrentCamera_0.FieldOfView = l_v95_FirstChild_0.Value;
					end;
				end));
			end;
		end;
		local v108 = v101:FindFirstChild("camera") or v101:FindFirstChild("CamPart") or v101:FindFirstChild('cam');
		local v109 = 0;
		v97:Add(Utility.Services.RunService.PreRender:Connect(function(v110) --[[ Line: 277 ]]
			v101:PivotTo(v93.CFrame * v94);
			if not v96 or v109 >= 20 then
				l_CurrentCamera_0.CFrame = v108.CFrame;
				return;
			else
				if v109 < 20 then
					v109 = v109 + 0.1;
				end;
				l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame:Lerp(v108.CFrame, v110 * v109);
				return;
			end;
		end));
		v97:Add(function() --[[ Line: 288 ]]
			l_Humanoid_0.AutoRotate = true;
			v101:Destroy();
			l_CurrentCamera_0.FieldOfView = 70;
			l_CurrentCamera_0.CameraType = Enum.CameraType.Custom;
		end);
		v97:Add(l_Humanoid_0.Died:Once(function() --[[ Line: 294 ]]
			v97:Destroy();
		end));
		v97:Add(v102.Stopped:Once(function() --[[ Line: 297 ]]
			v97:Destroy();
		end));
		return;
	end;
end;
function module.newCameraShake(arg1, arg2) 
	local function runCam()
		local any_new_result1_9 = CameraShaker_upvr.CameraShakeInstance.new(table.unpack(arg1[1]))
		any_new_result1_9.PositionInfluence = arg1[2]
		local any_new_result1_8 = CameraShaker_upvr.new(Enum.RenderPriority.Camera.Value, function(arg1_6) -- Line 1817
			workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * arg1_6
		end)
		any_new_result1_8:Start()
		any_new_result1_8:Shake(any_new_result1_9)
	end
	if not arg2 then
		runCam()
	else
		if arg2[2] < Utility.Services.Players.LocalPlayer:DistanceFromCharacter(arg2[1].Position) then return end
		runCam()
	end
end
function module.Emit(arg1, arg2, arg3, arg4, arg5)
	local var38
	if not arg1:IsDescendantOf(game) then
	else
		local var39 = arg3 or 1
		local var40 = arg4
		if not var40 then
			var40 = CFrame.new()
		end
		
		local Clone 
		if arg1 and not arg2 then
			Clone = arg1
		elseif arg1 and arg2 then
			Clone = arg2
		end
		local clone_14 : Model = Clone:Clone()
		var38 = workspace
		clone_14.Parent = var38.Effects

		if not arg1:IsA("CFrameValue") or not arg1.Value then
			if not arg1:IsA('Model') then
				var38 = arg1.CFrame
			end
			
		end
		if not clone_14:IsA('Model') then
			clone_14.CFrame = var38 * var40
			clone_14.Anchored = true
		end
		
		Utility.Services.Debris:AddItem(clone_14, var39)
		for _, v_48 in clone_14:GetDescendants() do
			if v_48:IsA("ParticleEmitter") then
				v_48.Enabled = false
				v_48:Emit(v_48:GetAttribute("EmitCount"))
			elseif v_48:IsA("PointLight") then
				Utility.Services.Tween:Create(v_48, TweenInfo.new(var39), {
					Brightness = 0;
				}):Play()
			end
		end
	end
end

function module.EmitOnly(arg1,arg2)
	local var39 = arg2 or 1
	for _, v_48 in arg1:GetDescendants() do
		if v_48:IsA("ParticleEmitter") then
			v_48.Enabled = false
			v_48:Emit(v_48:GetAttribute("EmitCount"))
		elseif v_48:IsA("PointLight") then
			Utility.Services.Tween:Create(v_48, TweenInfo.new(var39), {
				Brightness = 0;
			}):Play()
		end
	end
end

function module.impactFrame(arg1, arg2) 
	local function imp() 
		if Utility.Services.Lighting:FindFirstChild("DefaultColorCorrection") then
			Utility.Services.Lighting.DefaultColorCorrection.Enabled = false
		end
		local ColorCorrectionEffect_2 = Instance.new("ColorCorrectionEffect", game.Lighting)
		ColorCorrectionEffect_2.Brightness = -0.1
		ColorCorrectionEffect_2.Contrast = 0.2
		ColorCorrectionEffect_2.Saturation = 0.1
		if arg1 then
			for _ = 1, arg1 do
				ColorCorrectionEffect_2.Brightness = -25
				ColorCorrectionEffect_2.Contrast = -100
				ColorCorrectionEffect_2.Saturation = -1
				task.wait(0.01)
				ColorCorrectionEffect_2.Brightness = -200
				ColorCorrectionEffect_2.Contrast = 50000
				ColorCorrectionEffect_2.Saturation = -1
				task.wait(0.02)
				
			end
		else
			ColorCorrectionEffect_2.Brightness = -25
			ColorCorrectionEffect_2.Contrast = -100
			ColorCorrectionEffect_2.Saturation = -1
			task.wait(0.01)
			ColorCorrectionEffect_2.Brightness = -200
			ColorCorrectionEffect_2.Contrast = 50000
			ColorCorrectionEffect_2.Saturation = -1
			task.wait(0.02)
		end
		ColorCorrectionEffect_2:Destroy()
		if Utility.Services.Lighting:FindFirstChild("DefaultColorCorrection") then
			Utility.Services.Lighting.DefaultColorCorrection.Enabled = true
		end
	end
	if not arg2 then
		task.spawn(imp)
	elseif Utility.Services.Players.LocalPlayer:DistanceFromCharacter(arg2[1].Position) <= arg2[2] then
		task.spawn(imp)
	end
end

function module.CameraShake(v32, v33, v34, v35)
	local function v39() 
		local v36 = CameraShaker_upvr.CameraShakeInstance.new(5, v32, 0, v33);
		v36.PositionInfluence = Vector3.new(1, 1, 0, 0) * v34;
		local v38 = CameraShaker_upvr.new(Enum.RenderPriority.Camera.Value, function(v37)
			workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * v37;
		end);
		v38:Start();
		v38:Shake(v36);
	end;
	if not v35 then
		v39();
		return;
	elseif LocalPlayer:DistanceFromCharacter(v35[1].Position) > v35[2] then
		return;
	else
		v39();
		return;
	end;
end;
function module.Brightness(arg1, arg2, arg3, arg4)
	return false
end
function module.Hand(arg1,arg2,arg3,arg4)
	local clone_9 = arg1:Clone()
	clone_9.Parent = arg2
	for i_19, v_15 in clone_9:GetDescendants() do
		if v_15:IsA("BasePart") then
			v_15.Color = arg2.Color
		end
	end
	local Motor6D = Instance.new("Motor6D", clone_9.PrimaryPart)
	Motor6D.Part0 = arg2
	Motor6D.Part1 = clone_9.PrimaryPart
	if arg4 then
		Motor6D.C0 = arg4
	else
		Motor6D.C0 = CFrame.new(0,-0.75,0) * CFrame.Angles(math.pi/2, 0, (-math.pi/2))
	end
	if arg3 then
		Utility.Services.Debris:AddItem(clone_9, arg3)
	end
end
function module.debrisZone(v255, v256, v257, v258, v259) 
	v258 = v258 / 2;
	local l_AssemblyLinearVelocity_1 = v255.AssemblyLinearVelocity;
	local v261 = math.log(3 + l_AssemblyLinearVelocity_1.Magnitude * 20);
	local v262 = Utility.Modules.RayCast(v255.Position, v259 or l_AssemblyLinearVelocity_1.Unit * v261);
	if v262 then
		local v263 = CFrame.new(v262.Position, v262.Position + v262.Normal) * CFrame.Angles(-1.5707963267948966, 0, 0);
		--l_Sound_0:play(l_ReplicatedStorage_0.Resources[("slammed %*"):format((Random.new():NextInteger(1, 5)))], v255);
		module.CameraShake(5, v258 / 2, v258 * 2, {
			v255, 
			v256 * 2
		});
		for v273 = 0, 360, 360 / v257 do
			local function v287(v274, v275) --[[ Line: 1144 ]] --[[ Name: spawnRock ]]
				local v276 = 360 / v257;
				local v277 = Random.new():NextNumber(0.3, 1.15) * v275;
				local v278 = v263 * CFrame.Angles(0, math.rad(v273), 0) * CFrame.new(0, 0, v277);
				local _ = v263 * CFrame.Angles(0, math.rad(v273 + v276), 0) * CFrame.new(0, 0, v277);
				local _ = Random.new():NextNumber(0.7, 1.1);
				local v281 = Random.new():NextNumber(-30, -15);
				local v282 = v278 * CFrame.Angles(math.rad(v281), math.rad((Random.new():NextNumber(-v274 / 2, v274 / 2))), (math.rad((Random.new():NextNumber(-v274 / 2, v274 / 2)))));
				local v283 = v278 * CFrame.new(0, -5, 0);
				local v284 = Utility.Modules.RayCast(v278.Position + v262.Normal * 5, -v262.Normal * 10);
				if v284 then
					local _ = Random.new():NextNumber(0.3, v274 / 2);
					local v286 = Instance.new("Part", workspace.Effects);
					v286.Size = Vector3.new(Random.new():NextNumber(1, 5) * v274, v274, Random.new():NextNumber(2, 3) * v274);
					v286.CFrame = v282;
					v286.Anchored = true;
					v286.CanCollide = false;
					--v286.Material = v284.Instance.Material;
					v286.Color = v284.Instance.Color;
					v286.MaterialVariant = v284.Instance.MaterialVariant;
					task.delay(2.85, function() --[[ Line: 1188 ]]
						Utility.Services.Tween:Create(v286, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							CFrame = v283, 
							Size = Vector3.new(0, 0, 0, 0)
						}):Play();
						Utility.Services.Debris:AddItem(v286, 2);
					end);
				end;
			end;
			task.spawn(v287, table.unpack({
				v258 / 2, 
				v256 / 2
			}));
			task.spawn(v287, table.unpack({
				v258, 
				v256
			}));
		end;
		return v262;
	else
		return;
	end;
end;



function module.MapTransparency(Bind : Humanoid,Duration)
	

	if Duration <= 0 then Duration = 5 end
	local Transparency = {}
	local New = Utility.Modules.Trove.new()
	local Canceled = false
	
	local function GetBackMrPresiden()
		for i_6, v_6 in Transparency do
			i_6.Transparency = v_6
		end
		table.clear(Transparency)
	end
	
	
	for _, v_5 in workspace.Map:GetDescendants() do
		if v_5:IsA("BasePart") or v_5:IsA("Texture") or v_5:IsA("Decal") then
			if 1 > v_5.Transparency  then
				Transparency[v_5] = v_5.Transparency
				v_5.Transparency = 1
			end
		end
	end
	
	if Bind:IsA('Humanoid') then
		New:Add(Bind.Died:Once(function()
			 GetBackMrPresiden()
			 Canceled = true
			 New:Destroy()
		end))
		New:Add(Bind.Parent:GetPropertyChangedSignal('Parent'):Once(function()
			 if Bind.Parent.Parent == nil then
				 Canceled = true
				 GetBackMrPresiden()
				 New:Destroy()
			 end
		end))
	end
	
	
	
	
	
	task.wait(Duration)
	if Canceled then return end
	New:Destroy()
	GetBackMrPresiden()
end

function InvisibleChar(char,Duration,Bollean)
	if Duration <= 0 then Duration = 5 end
	local Transparency = {}
	local New = Utility.Modules.Trove.new()
	local Canceled = false

	local function GetBackMrPresiden()
		for i_6, v_6 in Transparency do
			i_6.Transparency = v_6
		end
		table.clear(Transparency)
	end
   
   
   if Bollean then
		if Bollean == true then
			for _, v_5 in workspace.Map:GetDescendants() do
				if v_5:IsA("BasePart") or v_5:IsA("Texture") or v_5:IsA("Decal") then
					if 1 > v_5.Transparency  then
						Transparency[v_5] = v_5.Transparency
						v_5.Transparency = 1
					end
				end
			end
		else
			for _, v_5 in workspace.Map:GetDescendants() do
				if v_5:IsA("BasePart") or v_5:IsA("Texture") or v_5:IsA("Decal") then
					if 1 > v_5.Transparency  then
						Transparency[v_5] = v_5.Transparency
						v_5.Transparency = 0
					end
				end
			end
		end
   else
		for _, v_5 in workspace.Map:GetDescendants() do
			if v_5:IsA("BasePart") or v_5:IsA("Texture") or v_5:IsA("Decal") then
				if 1 > v_5.Transparency  then
					Transparency[v_5] = v_5.Transparency
					v_5.Transparency = 1
				end
			end
		end
   end
	

	




    if Bollean then return end

	task.wait(Duration)
	if Canceled then return end
	New:Destroy()
	GetBackMrPresiden()
end

function module.Projectile(arg1, arg2) 
	local clone_3 = arg2:Clone()
	clone_3.Parent = workspace.Effects
	clone_3.CFrame = arg1.Value
	repeat
		clone_3.CFrame = clone_3.CFrame:Lerp(arg1.Value, 0.5)
		task.wait()
	until not arg1:IsDescendantOf(game)
	clone_3:Destroy()
end
function module.newlinearVelocity(arg1, arg2, arg3, arg4, arg5) -- Line 244
    --[[ Upvalues[1]:
        [1]: Utility_upvr (readonly)
    ]]
	local var69 = arg2
	if not var69 then
		var69 = Vector3.zAxis * -80
	end
	local LinearVelocity_upvr = Instance.new("LinearVelocity")
	LinearVelocity_upvr.Attachment0 = arg1.RootAttachment
	LinearVelocity_upvr.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	local var71 = arg3
	if not var71 then
		var71 = Vector3.new(1, 0, 1) * 30000
	end
	LinearVelocity_upvr.MaxAxesForce = var71
	LinearVelocity_upvr.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	LinearVelocity_upvr.VectorVelocity = var69
	local var73_upvw
	var73_upvw = arg1:GetPropertyChangedSignal("Velocity"):Connect(function() -- Line 261
        --[[ Upvalues[2]:
            [1]: var73_upvw (read and write)
            [2]: LinearVelocity_upvr (readonly)
        ]]
		var73_upvw:Disconnect()
		LinearVelocity_upvr:Destroy()
	end)
	if arg5 then
		Utility.Services.Debris:AddItem(LinearVelocity_upvr, arg5)
		task.delay(arg5, function() -- Line 267
            --[[ Upvalues[1]:
                [1]: var73_upvw (read and write)
            ]]
			var73_upvw:Disconnect()
		end)
	end
	if arg4 then
		Utility.Services.Tween:Create(LinearVelocity_upvr, TweenInfo.new(arg4[1][1], arg4[1][2], arg4[1][3]), arg4[2]):Play()
	end
	LinearVelocity_upvr.Parent = arg1
	return LinearVelocity_upvr
end
function module.Frames(Table,Parents)
	local FPS = Table.FPS
	local Frame = Table.Frames
	
	local function Create(id)
		local Images = Instance.new('ImageLabel')
		Images.Size = UDim2.new(1, 0,1, 0)
		Images.BackgroundTransparency = 1
		Images.Image = 'rbxassetid://'..id
		Images.Visible = true
		Images.Parent = Parents
		task.wait(FPS)
		Images.Visible = false
	end
	
	for i,v in Frame do
		Create(i)
	end

	
	
	
	
end

return module
