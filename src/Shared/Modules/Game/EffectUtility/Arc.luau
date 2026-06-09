-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Arc, time of decompilation: Tue Aug  5 05:07:06 2025 ]]
local v0 = {};
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
v0.ToggleAttachment = function(v4, v5, v6) --[[ Line: 8 ]] --[[ Name: ToggleAttachment ]]
    -- upvalues: v0 (copy)
    for _, v8 in ipairs(v4:GetDescendants()) do
        if v8:IsA("ParticleEmitter") or v8:IsA("Trail") or v8:IsA("Beam") then
            v8.Enabled = v5;
        end;
    end;
    if v6 ~= nil and v6 > 0 then
        task.delay(v6, v0.ToggleAttachment, v4, false);
    end;
end;
v0.CloneAndEmit = function(v9, v10) --[[ Line: 20 ]] --[[ Name: CloneAndEmit ]]
    -- upvalues: v0 (copy)
    local v11 = v9:Clone();
    v11.Parent = v10;
    v0.EmitAttachment(v11);
    return v11;
end;
v0.EmitAttachment = function(v12) --[[ Line: 28 ]] --[[ Name: EmitAttachment ]]
    -- upvalues: v3 (copy), l_TweenService_0 (copy)
    local v13 = 0;
    for _, v15 in ipairs(v12:GetDescendants()) do
        if v15:IsA("ParticleEmitter") then
            local l_v15_Attributes_0 = v15:GetAttributes();
            local v17 = l_v15_Attributes_0.EnableDuration or 0;
            local v18 = l_v15_Attributes_0.EmitCount or 1;
            local v19 = l_v15_Attributes_0.EmitDelay or 0;
            if v19 > 0 then
                task.delay(v19, v15.Emit, v15, v18);
            else
                v15:Emit(v18);
            end;
            if v17 > 0 then
                v15.Enabled = true;
                task.delay(v17, function() --[[ Line: 48 ]]
                    -- upvalues: v15 (copy)
                    v15.Enabled = false;
                end);
            end;
            v13 = math.max(v13, v15.Lifetime.Min + v15.Lifetime.Max + (v19 + v17) / v15.TimeScale);
        elseif v15:IsA("Trail") then
            local v20 = v15:GetAttribute("EnableDuration") or 0;
            if v20 > 0 then
                v15.Enabled = true;
                task.delay(v20, function() --[[ Line: 61 ]]
                    -- upvalues: v15 (copy)
                    v15.Enabled = false;
                end);
            end;
            v13 = math.max(v13, v20);
        elseif v15:IsA("Light") then
            local l_v15_Attributes_1 = v15:GetAttributes();
            local v22 = l_v15_Attributes_1.EnableDuration or 0;
            if v22 > 0 then
                local v23 = l_v15_Attributes_1.StartFade or 0;
                local v24 = l_v15_Attributes_1.EndFade or 0;
                local v25 = l_v15_Attributes_1.StartFadeStyle or "Cubic";
                local v26 = l_v15_Attributes_1.EndFadeStyle or "Cubic";
                local v27 = l_v15_Attributes_1.Brightness or v15.Brightness;
                if v23 > 0 then
                    v15.Brightness = 0;
                    l_TweenService_0:Create(v15, TweenInfo.new(v23, Enum.EasingStyle[v25], Enum.EasingDirection.Out), {
                        Brightness = v27
                    }):Play();
                else
                    v15.Brightness = v27;
                end;
                v15.Enabled = true;
                task.delay(v22, function() --[[ Line: 93 ]]
                    -- upvalues: v24 (copy), l_TweenService_0 (ref), v15 (copy), v26 (copy), v27 (copy)
                    if v24 > 0 then
                        l_TweenService_0:Create(v15, TweenInfo.new(v24, Enum.EasingStyle[v26], Enum.EasingDirection.Out), {
                            Brightness = 0
                        }):Play();
                        task.delay(v24, function() --[[ Line: 99 ]]
                            -- upvalues: v15 (ref), v27 (ref)
                            v15.Enabled = false;
                            v15.Brightness = v27;
                        end);
                        return;
                    else
                        v15.Enabled = false;
                        return;
                    end;
                end);
                v13 = math.max(v13, v23 + v24 + v22);
            end;
        elseif v15:IsA("Beam") then
            local l_v15_Attributes_2 = v15:GetAttributes();
            local v29 = l_v15_Attributes_2.EnableDuration or 0;
            if v29 > 0 then
                local v30 = l_v15_Attributes_2.StartFade or 0;
                local v31 = l_v15_Attributes_2.EndFade or 0;
                local v32 = l_v15_Attributes_2.StartFadeStyle or "Cubic";
                local v33 = l_v15_Attributes_2.EndFadeStyle or "Cubic";
                local v34 = l_v15_Attributes_2.Brightness or v15.Brightness;
                if v30 > 0 then
                    v15.Brightness = 0;
                    l_TweenService_0:Create(v15, TweenInfo.new(v30, Enum.EasingStyle[v32], Enum.EasingDirection.Out), {
                        Brightness = v34
                    }):Play();
                else
                    v15.Brightness = v34;
                end;
                v15.Enabled = true;
                task.delay(v29, function() --[[ Line: 136 ]]
                    -- upvalues: v31 (copy), l_TweenService_0 (ref), v15 (copy), v33 (copy), v34 (copy)
                    if v31 > 0 then
                        l_TweenService_0:Create(v15, TweenInfo.new(v31, Enum.EasingStyle[v33], Enum.EasingDirection.Out), {
                            Brightness = 0
                        }):Play();
                        task.delay(v31, function() --[[ Line: 142 ]]
                            -- upvalues: v15 (ref), v34 (ref)
                            v15.Enabled = false;
                            v15.Brightness = v34;
                        end);
                        return;
                    else
                        v15.Enabled = false;
                        return;
                    end;
                end);
                v13 = math.max(v13, v30 + v31 + v29);
            end;
        end;
    end;
    task.delay(v13, v12.Destroy, v12);
end;
return v0;