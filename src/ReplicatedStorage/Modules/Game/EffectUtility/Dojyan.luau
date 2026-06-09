-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Dojyan, time of decompilation: Tue Aug  5 05:07:07 2025 ]]
local v0 = {};
v0.EmitAndRemove = function(v1) --[[ Line: 3 ]] --[[ Name: EmitAndRemove ]]
    -- upvalues: v0 (copy)
    local v2 = v0.Emit(v1);
    task.delay(v2, v1.Destroy, v1);
end;
v0.Emit = function(v3) --[[ Line: 12 ]] --[[ Name: Emit ]]
    local v4 = 0;
    for _, v6 in pairs(v3:GetDescendants()) do
        if v6.ClassName == "ParticleEmitter" then
            local l_v6_Attributes_0 = v6:GetAttributes();
            local v8 = l_v6_Attributes_0.EmitCount or 1;
            local v9 = l_v6_Attributes_0.EnableDuration or 0;
            if v9 > 0 then
                v6.Enabled = true;
                task.delay(v9, function() --[[ Line: 25 ]]
                    -- upvalues: v6 (copy)
                    v6.Enabled = false;
                end);
            end;
            v6:Emit(v8);
            v4 = math.max(v4, (v6.Lifetime.Min + v6.Lifetime.Max + v9) / v6.TimeScale);
        end;
    end;
    return v4;
end;
v0.VFXCFramedWithItself = function(v10, v11) --[[ Line: 41 ]] --[[ Name: VFXCFramedWithItself ]]
    -- upvalues: v0 (copy)
    local v12 = v10:Clone();
    v12.CFrame = v11.CFrame * v10.CFrame;
    v12.Parent = workspace.Visuals;
    v0.EmitAndRemove(v12);
end;
return v0;