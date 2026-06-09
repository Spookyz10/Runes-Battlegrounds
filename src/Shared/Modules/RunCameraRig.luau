local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local l_RunService_0 = game:GetService("RunService");
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer;
local l_CurrentCamera_0 = workspace.CurrentCamera;
local v6 = require(l_ReplicatedStorage_0.Modules.Job);
local v7 = nil;
return function(v8, v9, v10, v11, v12) --[[ Line: 20 ]]
    -- upvalues: v7 (ref), l_CurrentCamera_0 (copy), v6 (copy), l_LocalPlayer_0 (copy), l_TweenService_0 (copy), l_RunService_0 (copy)
    if v7 then
        v7();
        v7 = nil;
    end;
    v11 = v11 or {};
    v10 = v10 or CFrame.identity;
    local v13 = true;
    local l_CFrame_0 = l_CurrentCamera_0.CFrame;
    local v15 = nil;
    local l_AttachTo_0 = v9:FindFirstChild("AttachTo");
    local v17 = l_AttachTo_0 and l_AttachTo_0.Value or v9:FindFirstChild("camera");
    local v18 = v6.new();
    if not v11.DontDeleteRigOnClean then
        v18:Task(v9);
    end;
    if v11.AttachToListen and l_AttachTo_0 then
        v18:Task(l_AttachTo_0:GetPropertyChangedSignal("Value"):Connect(function() --[[ Line: 45 ]]
            -- upvalues: v17 (ref), l_AttachTo_0 (copy)
            v17 = l_AttachTo_0.Value;
        end));
    end;
    local l_NumberValue_0 = Instance.new("NumberValue");
    v18:Task(l_NumberValue_0);
    local function _() --[[ Line: 53 ]] --[[ Name: DisconnectRunner ]]
        -- upvalues: v15 (ref), v7 (ref)
        if v15 and v15.Connected then
            v15:Disconnect();
        end;
        v7 = nil;
    end;
    local v21 = false;
    local function v23() --[[ Line: 64 ]] --[[ Name: Clean ]]
        -- upvalues: v21 (ref), v15 (ref), v7 (ref), v18 (copy), v11 (ref), v13 (ref), l_CurrentCamera_0 (ref), l_CFrame_0 (ref), l_LocalPlayer_0 (ref)
        if v21 then
            return;
        else
            v21 = true;
            if v15 and v15.Connected then
                v15:Disconnect();
            end;
            v7 = nil;
            v18:Destroy();
            if not v11.DontSaveCameraPosition and v13 then
                l_CurrentCamera_0.CFrame = l_CFrame_0;
            end;
            if l_LocalPlayer_0.Character then
                local l_Humanoid_0 = l_LocalPlayer_0.Character:FindFirstChild("Humanoid");
                if l_Humanoid_0 then
                    l_CurrentCamera_0.CameraSubject = l_Humanoid_0;
                end;
            end;
            l_LocalPlayer_0.CameraMinZoomDistance = 0.5;
            l_CurrentCamera_0.CameraType = Enum.CameraType.Custom;
            l_LocalPlayer_0:SetAttribute("InCameraAnimation", nil);
            return;
        end;
    end;
	local function OnDisabledSetting() --[[ Line: 89 ]] --[[ Name: OnDisabledSetting ]]
        -- upvalues: v15 (ref), v7 (ref), v11 (ref), l_CurrentCamera_0 (ref), l_CFrame_0 (ref), l_LocalPlayer_0 (ref)
        if v15 and v15.Connected then
            v15:Disconnect();
        end;
        v7 = nil;
        if not v11.DontSaveCameraPosition then
            l_CurrentCamera_0.CFrame = l_CFrame_0;
        end;
        l_LocalPlayer_0.CameraMinZoomDistance = 0.5;
        l_CurrentCamera_0.CameraType = Enum.CameraType.Custom;
    end;
    local function v27() --[[ Line: 100 ]] --[[ Name: OnEnabledSetting ]]
        -- upvalues: l_LocalPlayer_0 (ref), l_CFrame_0 (ref), l_CurrentCamera_0 (ref), v11 (ref), l_NumberValue_0 (copy), l_TweenService_0 (ref), v15 (ref), l_RunService_0 (ref), v9 (copy), v23 (copy), v17 (ref), v8 (copy), v10 (ref)
        l_LocalPlayer_0.CameraMinZoomDistance = 2;
        if l_LocalPlayer_0.Character then
            for _, v26 in l_LocalPlayer_0.Character:GetDescendants() do
                if v26:IsA("BasePart") then
                    v26.LocalTransparencyModifier = 0;
                end;
            end;
        end;
        l_CFrame_0 = l_CurrentCamera_0.CFrame;
        l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable;
        if not v11.DontDoTransition then
            l_NumberValue_0.Value = 0;
            l_TweenService_0:Create(l_NumberValue_0, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Value = 1
            }):Play();
        end;
        l_LocalPlayer_0:SetAttribute("InCameraAnimation", true);
        v15 = l_RunService_0.PreRender:Connect(function() --[[ Line: 125 ]]
            -- upvalues: l_LocalPlayer_0 (ref), v9 (ref), v23 (ref), v17 (ref), v8 (ref), v10 (ref), v11 (ref), l_CurrentCamera_0 (ref), l_CFrame_0 (ref), l_NumberValue_0 (ref)
            if l_LocalPlayer_0.Character == nil or v9.Parent == nil then
                return v23();
            else
                if v17 == nil then
                    warn("BOI THERES NO ATTACH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                end;
                if v8 then
                    v9:PivotTo(v8.CFrame * v10);
                end;
                if not v11.DontDoTransition then
                    l_CurrentCamera_0.CFrame = l_CFrame_0:Lerp(v17.CFrame, l_NumberValue_0.Value);
                    return;
                else
                    l_CurrentCamera_0.CFrame = v17.CFrame;
                    return;
                end;
            end;
        end);
    end;
    local v28 = {};
    for _, v30 in ipairs(v9:GetDescendants()) do
        if v30:IsA("BasePart") then
            v28[v30] = v30.Transparency;
        end;
    end;
    local function v33() --[[ Line: 154 ]] --[[ Name: Update ]]
        -- upvalues: v21 (ref), v13 (ref), l_LocalPlayer_0 (ref), v27 (copy), v15 (ref), v7 (ref), v11 (ref), l_CurrentCamera_0 (ref), l_CFrame_0 (ref), v12 (copy), v28 (copy)
        if v21 then
            return;
        else
            v13 = l_LocalPlayer_0:GetAttribute("Cutscenes") and not l_LocalPlayer_0:GetAttribute("InFreecam");
            if v13 then
                v27();
            else
                if v15 and v15.Connected then
                    v15:Disconnect();
                end;
                v7 = nil;
                if not v11.DontSaveCameraPosition then
                    l_CurrentCamera_0.CFrame = l_CFrame_0;
                end;
                l_LocalPlayer_0.CameraMinZoomDistance = 0.5;
                l_CurrentCamera_0.CameraType = Enum.CameraType.Custom;
            end;
            if v12 then
                task.spawn(v12, v13);
            end;
            for v31, v32 in v28 do
                if v32 == 0 then
                    v31.Transparency = v13 and 0 or 1;
                end;
            end;
            return;
        end;
    end;
    if not v11.DontSupportCutsceneSetting then
        v18:Task(l_LocalPlayer_0:GetAttributeChangedSignal("Cutscenes"):Connect(v33));
        v33();
    else
        v27();
    end;
    v7 = v23;
    return v23;
end;