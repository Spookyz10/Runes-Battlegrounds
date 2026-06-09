-- Saved by UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw

return function(v0, v1, _, v3, v4) --[[ Line: 2 ]] --[[ Name: Raycast ]]
    local v5 = RaycastParams.new();
    v5.FilterDescendantsInstances = v3 or {
        workspace.Map
    };
    v5.FilterType = Enum.RaycastFilterType.Include;
    local v6 = nil;
    v6 = if not v4 then workspace:Raycast(v0, v1, v5) else workspace:Blockcast(CFrame.new(v0), v4, v1, v5);
    if v6 then
        return v6;
    else
        return;
    end;
end;