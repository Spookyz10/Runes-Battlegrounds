-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: ToggleFX, time of decompilation: Wed Jun 18 20:48:16 2025 ]]
return function(v0, v1) --[[ Line: 1 ]]
    for _, v3 in v0:GetDescendants() do
        if v3:IsA("ParticleEmitter") then
            v3.Enabled = v1;
        end;
    end;
end;