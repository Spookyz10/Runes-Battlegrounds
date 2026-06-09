
local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local Utility_upvr = require(ReplicatedStorage_upvr.Utility)
local Parent_upvr = require(script.Parent)
function module_upvr.domainUI(arg1, arg2, arg3) 
    if Utility_upvr.Services.Players.LocalPlayer:DistanceFromCharacter(arg1.PrimaryPart.Position) <= 150 then
        Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.domainstarttt, Utility_upvr.Services.Sound)
        Utility_upvr.Modules.GuiShakerModule:ShakeOnce(Utility_upvr.Services.Players.LocalPlayer.PlayerGui.MainScreen.domainCanvas, 4, 0.35)
        local clone_9_upvr = ReplicatedStorage_upvr.Resources.UIs.dm:Clone()
        clone_9_upvr.Parent = Utility_upvr.Services.Players.LocalPlayer.PlayerGui.MainScreen.domainCanvas
        clone_9_upvr.LayoutOrder = #Utility_upvr.Services.Players.LocalPlayer.PlayerGui.MainScreen.domainCanvas:GetChildren()
        arg1.Archivable = true
        local clone_7 : Model = arg1:Clone()
        clone_7.Parent = clone_9_upvr.ViewportFrame.WorldModel
        clone_7:PivotTo(clone_9_upvr.ViewportFrame.WorldModel.Rig:FindFirstChild('HumanoidRootPart').CFrame)
		clone_7:FindFirstChild('HumanoidRootPart').Anchored = true
		
        Parent_upvr.Hand(ReplicatedStorage_upvr.Resources.Hand.LeftHand, clone_7["Left Arm"], nil, CFrame.new(0, -0.75, 0) * CFrame.Angles((math.pi/2), 0, (math.pi/2)))
        Parent_upvr.Hand(ReplicatedStorage_upvr.Resources.Hand.RightHand, clone_7["Right Arm"], nil, CFrame.new(0, -0.75, 0) * CFrame.Angles((math.pi/2), 0, (-math.pi/2)))
		
		task.wait()
		clone_9_upvr.ViewportFrame.WorldModel.Rig:Destroy()
        local any_loadAnimation_result1 = Utility_upvr.Modules.animPlaying:loadAnimation(clone_7, arg3)
		any_loadAnimation_result1:Play(0)
		local SizeSaved = clone_9_upvr.Size
        clone_9_upvr.Size = UDim2.new(0, 0, 1, 0)
        clone_9_upvr.GroupTransparency = 1
        Utility_upvr.Services.Tween:Create(clone_9_upvr, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            GroupTransparency = 0;
            Size = SizeSaved;
        }):Play()
        arg1.Archivable = false
        task.delay(any_loadAnimation_result1.Length - 0.3, function() -- Line 59
            --[[ Upvalues[2]:
                [1]: Utility_upvr (copied, readonly)
                [2]: clone_9_upvr (readonly)
            ]]
            Utility_upvr.Services.Tween:Create(clone_9_upvr, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                GroupTransparency = 1;
                Size = UDim2.new(0, 0, 1, 0);
            }):Play()
            Utility_upvr.Services.Debris:AddItem(clone_9_upvr, 0.3)
        end)
    end
end
function module_upvr.Shatter(arg1) -- Line 65
    --[[ Upvalues[2]:
        [1]: ReplicatedStorage_upvr (readonly)
        [2]: Utility_upvr (readonly)
    ]]
    local clone_6_upvr = ReplicatedStorage_upvr.Resources.Crack:Clone()
    clone_6_upvr.Parent = Utility_upvr.Services.Players.LocalPlayer.PlayerGui.MainScreen
    task.spawn(function() -- Line 69
        --[[ Upvalues[1]:
            [1]: clone_6_upvr (readonly)
        ]]
        for _ = 1, 2 do
            task.wait(0.01)
            clone_6_upvr.Impact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(0.01)
            clone_6_upvr.Impact.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            task.wait(0.01)
        end
        clone_6_upvr.Impact.Visible = false
    end)
    Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.glassCrack, Utility_upvr.Services.Sound)
    Utility_upvr.Modules.GuiShakerModule:ShakeOnce(clone_6_upvr.Crack, 12, 1.85, 0)
    task.wait(arg1 or 1)
    clone_6_upvr:Destroy()
end
function module_upvr.domainClashIdle(arg1)
    local var33 = Vector3.new(0,0,0)
    for _, v in pairs(arg1) do
        local PrimaryPart = v.PrimaryPart
        if not PrimaryPart then
            PrimaryPart = v.HumanoidRootPart
        end
        var33 += PrimaryPart.Position
    end
    local clone_5 = ReplicatedStorage_upvr.Resources.domainClashIdle:Clone()
    clone_5.Position = var33 / (0 + 1)
    clone_5.Parent = workspace.Effects
    Parent_upvr.impactFrame(3, {clone_5, 150})
    Parent_upvr.newCameraShake({{5, 10, 0, 3}, Vector3.one * 7}, {clone_5, 150})
    if Utility_upvr.Services.Players.LocalPlayer:DistanceFromCharacter(clone_5.Position) <= 150 then
        Parent_upvr.Brightness(0.3, 2, Color3.fromRGB(255, 255, 255))
        Parent_upvr.fieldOfView(false, 120)
        Parent_upvr.fieldOfView(true, 70, 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        Parent_upvr.screenEffect(9)
    end
    Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.dclashs, clone_5)
    repeat
        Parent_upvr.newCameraShake({{5, 10, 0, 0.5}, Vector3.one * 1}, {clone_5, 150})
        task.wait(0.05)
    until workspace:GetServerTimeNow() + 9 <= tick()
    Parent_upvr.newCameraShake({{5, 10, 0, 3}, Vector3.one * 7}, {clone_5, 150})
    Parent_upvr.impactFrame(2, {clone_5, 150})
    if Utility_upvr.Services.Players.LocalPlayer:DistanceFromCharacter(clone_5.Position) <= 150 then
        Parent_upvr.Brightness(0.3, 2, Color3.fromRGB(255, 255, 255))
        Parent_upvr.fieldOfView(false, 120)
        Parent_upvr.fieldOfView(true, 70, 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end
    Parent_upvr.Emit(clone_5, ReplicatedStorage_upvr.Resources.domainClashEnd, 3)
    for _, v_2 in clone_5:GetDescendants() do
        if v_2:IsA("ParticleEmitter") then
            v_2.Enabled = false
        elseif v_2:IsA("PointLight") then
            Utility_upvr.Services.Tween:Create(v_2, TweenInfo.new(0.5), {
                Brightness = 0;
            }):Play()
        end
    end
    Utility_upvr.Services.Debris:AddItem(clone_5, 2)
end
function module_upvr.domainDestroy(arg1, arg2, arg3, arg4) -- Line 142
    --[[ Upvalues[3]:
        [1]: ReplicatedStorage_upvr (readonly)
        [2]: Utility_upvr (readonly)
        [3]: Parent_upvr (readonly)
    ]]
    -- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
    local clone_2 = ReplicatedStorage_upvr.Resources.domainDestroy:Clone()
    clone_2.Parent = workspace.Effects
    clone_2:PivotTo(arg1.CFrame)
    clone_2.Size = Vector3.one * arg2
    Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.domainBreak, clone_2)
    for _, v_3 in pairs(clone_2:GetDescendants()) do
        if v_3:IsA("ParticleEmitter") then
            local tbl_6 = {}
            local var72 = math.clamp(arg2 * 2, 0, math.huge) * 0.0025
            for i_5, v_4 in ipairs(v_3.Size.Keypoints) do
                tbl_6[i_5] = NumberSequenceKeypoint.new(v_4.Time, v_4.Value * var72, v_4.Envelope * var72)
                local _
            end
            v_3.Size = NumberSequence.new(tbl_6)
            v_3.Color = ColorSequence.new(arg1.Color)
        end
    end
    Utility_upvr.Emit(clone_2)
    Utility_upvr.Services.Debris:AddItem(clone_2, 3)
    if Utility_upvr.Services.Players.LocalPlayer.Character == arg3 or arg4[Utility_upvr.Services.Players.LocalPlayer.Character] then
        Parent_upvr.newCameraShake({{5, 10, 0, 3}, Vector3.one * 3})
        Parent_upvr.impactFrame(3)
        Parent_upvr.Brightness(1, 2.5)
    elseif Utility_upvr.Services.Players.LocalPlayer:DistanceFromCharacter(arg1.Position) <= arg2 then
        Parent_upvr.newCameraShake({{5, 10, 0, 3}, Vector3.one * 3})
        Parent_upvr.impactFrame(3)
        Parent_upvr.Brightness(1, 2.5)
    end
end
function module_upvr.domainStart(arg1, arg2, arg3, arg4) -- Line 178
    --[[ Upvalues[4]:
        [1]: Utility_upvr (readonly)
        [2]: ReplicatedStorage_upvr (readonly)
        [3]: Parent_upvr (readonly)
        [4]: module_upvr (readonly)
    ]]
    local var100
    if not var100 then
        var100 = arg1.PrimaryPart
    end
    Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.domainAppear, arg2)
    local clone_10 = ReplicatedStorage_upvr.Resources.Release:Clone()
    local any_Raycast_result1_2 = Utility_upvr.Modules.RayCast(arg2.Position, Vector3.yAxis * 15)
    if any_Raycast_result1_2 then
        clone_10.CFrame = CFrame.new(any_Raycast_result1_2.Position)
    else
        clone_10.CFrame = var100.CFrame * CFrame.new(0, -3, 0)
    end
    for _, v_5 in pairs(clone_10:GetDescendants()) do
        if v_5:IsA("ParticleEmitter") then
            v_5:Emit(v_5:GetAttribute("EmitCount"))
            if any_Raycast_result1_2 then
                v_5.Color = ColorSequence.new(any_Raycast_result1_2.Instance.Color)
            end
        end
    end
    Utility_upvr.Services.Debris:AddItem(clone_10, 2)
    clone_10.Parent = workspace.Effects
    local Part_2 = Instance.new("Part")
    Part_2.Shape = Enum.PartType.Ball
    Part_2.Parent = workspace.Effects
    Part_2.Anchored = true
    Part_2.CanCollide = false
    Part_2.CFrame = clone_10.CFrame
    Part_2.Size = Vector3.new(0, 0, 0)
    Part_2.Transparency = 0
    Part_2.Material = Enum.Material.ForceField
    Part_2.Color = Color3.fromRGB(255, 255, 255)
    Part_2.CastShadow = false
    Utility_upvr.Services.Tween:Create(Part_2, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = Vector3.one * arg3;
        Transparency = 1;
    }):Play()
    Utility_upvr.Services.Debris:AddItem(Part_2, 2)
    local tbl_5 = {}
    tbl_5[1] = arg2
    tbl_5[2] = arg3
    Parent_upvr.newCameraShake({{5, 10, 0, 2}, Vector3.one * 1}, tbl_5)
    module_upvr.domainUI(arg1, arg3, arg4)
end
function module_upvr.domainGenerate(arg1, arg2, arg3, arg4, arg5) -- Line 284
    --[[ Upvalues[2]:
        [1]: ReplicatedStorage_upvr (readonly)
        [2]: Utility_upvr (readonly)
    ]]
    -- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
    if not arg1:FindFirstChildOfClass("Humanoid").RootPart then
    end
    local clone = ReplicatedStorage_upvr.Resources.domainGenerate:Clone()
    clone.Parent = workspace.Effects
    clone:PivotTo(arg2.CFrame)
    local Floor = clone.Floor
    Floor.CFrame *= CFrame.new(0, -arg1:GetExtentsSize().Y / 2 + 1, 0)
    clone.domainGenerate.Size = Vector3.one * arg3
    clone.Floor.Size = Vector3.xAxis * arg3 + Vector3.zAxis * arg3
    for _, v_6 in clone:GetDescendants() do
        if v_6:IsA("ParticleEmitter") then
            local tbl_4 = {}
            local var133 = math.clamp(arg3 * 2, 0, math.huge) * 0.0025
            for i_8, v_7 in ipairs(v_6.Size.Keypoints) do
                tbl_4[i_8] = NumberSequenceKeypoint.new(v_7.Time, v_7.Value * var133, v_7.Envelope * var133)
                local _
            end
            v_6.Size = NumberSequence.new(tbl_4)
            v_6.Color = ColorSequence.new(arg2.Color)
            Utility_upvr.Services.Tween:Create(v_6, TweenInfo.new(arg4 / 2), {
                ShapePartial = 1;
            }):Play()
        end
    end
    clone.domainGenerate.Transparency = 1
    local any_Create_result1 = Utility_upvr.Services.Tween:Create(clone.domainGenerate, TweenInfo.new(arg4), {
        Transparency = 0;
    })
    any_Create_result1:Play()
    clone.domainGenerate.Color = arg2.Color
    any_Create_result1.Completed:Wait()
    repeat
        task.wait()
    until not arg2:IsDescendantOf(game) and not arg1:IsDescendantOf(game)
    clone:Destroy()
end
function module_upvr.infinityVoid(arg1, arg2, arg3, arg4) -- Line 339
    --[[ Upvalues[3]:
        [1]: Parent_upvr (readonly)
        [2]: Utility_upvr (readonly)
        [3]: ReplicatedStorage_upvr (readonly)
    ]]
    Parent_upvr.Brightness(1, 3)
    Parent_upvr.cameraShake("explosionPosition4")
    Utility_upvr.Services.Sound.AmbientReverb = "Cave"
    local clone_3 = ReplicatedStorage_upvr.Resources.Gojo.Domain.DomainSky:Clone()
    clone_3.Parent = workspace.Effects
    clone_3:PivotTo(CFrame.new(arg2.Position))
    Utility_upvr.Emit(clone_3)
    local clone_8_upvr = ReplicatedStorage_upvr.Resources.Gojo.Domain.Line:Clone()
    clone_8_upvr.Parent = workspace.Effects
    clone_8_upvr.CFrame = arg1.PrimaryPart.CFrame * CFrame.new(0, 0, 120)
    Parent_upvr.fieldOfView(true, 120, 2.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    spawn(function() -- Line 360
        --[[ Upvalues[3]:
            [1]: Utility_upvr (copied, readonly)
            [2]: Parent_upvr (copied, readonly)
            [3]: clone_8_upvr (readonly)
        ]]
        local BloomEffect = Instance.new("BloomEffect", game.Lighting)
        BloomEffect.Intensity = 0
        BloomEffect.Size = 0
        Utility_upvr.Services.Tween:Create(BloomEffect, TweenInfo.new(7), {
            Intensity = 10;
            Size = 56;
            Threshold = 0;
        }):Play()
        repeat
            Parent_upvr.cameraShake("explosionPosition")
            task.wait(0.1)
        until workspace:GetServerTimeNow() + 3 <= Utility_upvr.tick()
        BloomEffect:Destroy()
        Parent_upvr.Brightness(1, 1.5)
        Parent_upvr.cameraShake("explosionPosition4")
        Parent_upvr.fieldOfView(false, 70)
        clone_8_upvr:Destroy()
    end)
    repeat
        task.wait()
    until workspace:GetServerTimeNow() + arg3.Duration <= Utility_upvr.tick() and not arg1:IsDescendantOf(game) and (not arg4 or not arg4:IsDescendantOf(game)) and arg1:FindFirstChildOfClass("Humanoid").Health <= 0
    clone_3:Destroy()
    Utility_upvr.Services.Sound.AmbientReverb = "NoReverb"
    Utility_upvr.Services.Tween:Create(Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.Gojo.Domain.domainS, Utility_upvr.Services.Sound), TweenInfo.new(1), {
        Volume = 0;
    }):Play()
end
return module_upvr