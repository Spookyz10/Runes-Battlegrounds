local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local l_Players_0 = game:GetService("Players");
local l_RunService_0 = game:GetService("RunService");
local v4 = require(l_ReplicatedStorage_0.Modules.EffectUtility);
local v5 = require(l_ReplicatedStorage_0.Modules.AnimationRetriever);
local v6 = require(l_ReplicatedStorage_0.Modules.CameraShake);
local v7 = require(l_ReplicatedStorage_0.Modules.Vignette);
local v8 = require(l_ReplicatedStorage_0.Modules.Yuki_FOV);
local v9 = require(l_ReplicatedStorage_0.Modules.Utility);
local l_Railgun_0 = script.RailgunAnim;
local l_LocalPlayer_0 = l_Players_0.LocalPlayer;
local l_CurrentCamera_0 = workspace.CurrentCamera;
return {
    Start = function(v13, v14) --[[ Name: Start ]]
        -- upvalues: v5 (copy), l_Railgun_0 (copy), v4 (copy), l_Players_0 (copy), l_RunService_0 (copy), v7 (copy), v9 (copy), l_LocalPlayer_0 (copy), v8 (copy), v6 (copy), l_CurrentCamera_0 (copy), l_TweenService_0 (copy)
        local v15 = v5.new(v13, l_Railgun_0.User);
        if v15 == nil then
            return;
        else
            local l_Job_0 = v15.Job;
            local l_Animation_0 = v15.Animation;
            local l_RootPart_0 = v15.RootPart;
            local v19 = {};
            local v20 = l_Job_0:Task(script.RailGun:Clone());
            v20.Parent = v13;
            local l_Motor6D_0 = Instance.new("Motor6D");
            l_Motor6D_0.Name = "BodyHandle";
            l_Motor6D_0.C0 = CFrame.new(-1.125, 1.273, -0.69);
            l_Motor6D_0.C1 = CFrame.new(0.5, -1, -0.625);
            l_Motor6D_0.Part0 = l_RootPart_0;
            l_Motor6D_0.Part1 = v20.Body.BodyHandle;
            l_Motor6D_0.Parent = l_RootPart_0;
            local v22 = l_Job_0:Task(script.EffectPart:Clone());
            v22.Parent = workspace.Visuals;
            local l_Motor6D_1 = Instance.new("Motor6D");
            l_Motor6D_1.Name = "EffectPart";
            l_Motor6D_1.C0 = CFrame.new(-0.969, 1.361, -9.973);
            l_Motor6D_1.Part0 = l_RootPart_0;
            l_Motor6D_1.Part1 = v22;
            l_Motor6D_1.Parent = l_RootPart_0;
            local v24 = script.Friend:Clone();
            v4.Weld(v24, l_RootPart_0, CFrame.new(0, 0, 3.947));
            v24.Parent = workspace.Visuals;
            l_Job_0:Task(v24);
            task.spawn(function()
                -- upvalues: v14 (copy), v24 (copy), l_Players_0 (ref)
                if v14 then
                    local l_Humanoid_0 = v24:WaitForChild("Humanoid");
                    local l_l_Players_0_HumanoidDescriptionFromUserId_0 = l_Players_0:GetHumanoidDescriptionFromUserId((tonumber(v14.Id)));
                    if l_l_Players_0_HumanoidDescriptionFromUserId_0 then
                        l_Humanoid_0:ApplyDescription(l_l_Players_0_HumanoidDescriptionFromUserId_0);
                    end;
                end;
            end);
            local v27 = v24.Humanoid.Animator:LoadAnimation(l_Railgun_0.Friend);
            v19[v27] = true;
            l_Job_0:Task(l_RunService_0.PreAnimation:Connect(function()
                -- upvalues: v19 (copy), l_Animation_0 (copy)
                for v28 in v19 do
                    if v28.IsPlaying then
                        v28.TimePosition = l_Animation_0.TimePosition;
                    end;
                end;
            end));
            l_Job_0:Task(v27.Stopped:Once(function()
                -- upvalues: v24 (copy)
                v24:Destroy();
            end));
            v27:Play(0);
            local v29 = nil;
            local v30 = coroutine.create(function()
                -- upvalues: v7 (ref)
                while true do
                    v7(Color3.new(0.447059, 0.741176, 1), 0.3, 0.1);
                    task.wait(0.075);
                end;
            end);
            l_Job_0:Task(function()
                -- upvalues: v9 (ref), v30 (copy)
                v9.CloseThreadSafe(v30);
            end);
            l_Job_0:Task(l_Animation_0:GetMarkerReachedSignal("ChargeStart"):Connect(function()
                -- upvalues: v4 (ref), v20 (copy), l_Players_0 (ref), v13 (copy), l_LocalPlayer_0 (ref), v8 (ref)
                v4.Toggle(v20.Plate.ChargeUpFX, true);
                if l_Players_0:GetPlayerFromCharacter(v13) == l_LocalPlayer_0 then
                    v8.Tween(40, {
                        4
                    });
                end;
            end));
            l_Job_0:Task(l_Animation_0:GetMarkerReachedSignal("ChargeReady"):Connect(function()
                -- upvalues: v29 (ref), v6 (ref), v30 (copy), v4 (ref), v20 (copy)
                v29 = v6(1, 25, 0.1, 0);
                coroutine.resume(v30);
                v4.Toggle(v20.Plate.BarrelHandle.ChargeComplete, true);
                v4.Toggle(v20.Plate.BarrelHandle.FinishedCharge, true);
            end));
            l_Job_0:Task(l_Animation_0:GetMarkerReachedSignal("Shoot"):Connect(function()
                -- upvalues: v29 (ref), v9 (ref), v30 (copy), v20 (copy), v4 (ref), v22 (copy), l_Players_0 (ref), v13 (copy), l_LocalPlayer_0 (ref), l_Job_0 (copy), v24 (copy), l_RootPart_0 (copy), v6 (ref), v8 (ref), l_CurrentCamera_0 (ref)
                if v29 ~= nil then
                    v29:StartFadeOut(0.01);
                end;
                v9.CloseThreadSafe(v30);
                v20.Plate.ChargeUpFX:Destroy();
                v20.Plate.BarrelHandle.ChargeComplete:Destroy();
                v20.Plate.BarrelHandle.FinishedCharge:Destroy();
                v4.Toggle(v22.BeamFolder, true, true);
                v4.Emit(v22.ShotTaken);
                if l_Players_0:GetPlayerFromCharacter(v13) == l_LocalPlayer_0 then
                    local v31 = l_Job_0:Task(script.ImpactHighlight:Clone());
                    v31.Parent = v13;
                    local v32 = l_Job_0:Task(script.ImpactHighlight:Clone());
                    v32.Parent = v24;
                    local v33 = l_Job_0:Task(script.ColorCorrection:Clone());
                    v33.Parent = game.Lighting;
                    task.delay(0.075, function()
                        -- upvalues: v33 (copy), v31 (copy), v32 (copy)
                        v33.Brightness = -10;
                        v31.FillColor = Color3.fromRGB(255, 255, 255);
                        v32.FillColor = Color3.fromRGB(255, 255, 255);
                        task.delay(0.075, v31.Destroy, v31);
                        task.delay(0.075, v32.Destroy, v32);
                        task.delay(0.075, v33.Destroy, v33);
                    end);
                end;
                if l_LocalPlayer_0:DistanceFromCharacter(l_RootPart_0.Position) <= 250 then
                    v6(10, 125, 0.01, 1.5);
                    v8.Tween(l_CurrentCamera_0.FieldOfView + 70, {
                        0.25
                    });
                    task.delay(1.5, function()
                        -- upvalues: v8 (ref)
                        v8.Tween(70, {
                            2.5, 
                            Enum.EasingStyle.Quad, 
                            Enum.EasingDirection.In
                        });
                    end);
                end;
            end));
            l_Job_0:Task(l_Animation_0:GetMarkerReachedSignal("StartFade"):Connect(function()
                -- upvalues: v22 (copy), l_TweenService_0 (ref)
                for _, v35 in v22.BeamFolder:GetChildren() do
                    l_TweenService_0:Create(v35, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextureSpeed = 0, 
                        Brightness = 0
                    }):Play();
                end;
                task.delay(3, v22.Destroy, v22);
            end));
            return;
        end;
    end
};