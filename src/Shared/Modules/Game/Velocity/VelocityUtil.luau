-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: VelocityUtil, time of decompilation: Tue Aug  5 05:09:05 2025 ]]
local v3 = {
    Clear = function(v0) --[[ Line: 3 ]] --[[ Name: Clear ]]
        for _, v2 in ipairs(v0:GetChildren()) do
            if v2:IsA("BodyVelocity") then
                v2:Destroy();
            end;
        end;
    end
};
v3.Create = function(v4, v5) --[[ Line: 13 ]] --[[ Name: Create ]]
    -- upvalues: v3 (copy)
    v3.Clear(v4);
    local l_BodyVelocity_0 = Instance.new("BodyVelocity");
    if v5 then
        l_BodyVelocity_0.Name = v5;
    end;
    return l_BodyVelocity_0;
end;
return v3;