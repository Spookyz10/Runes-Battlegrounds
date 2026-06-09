-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: ImpactFrames, time of decompilation: Wed Jun 18 20:48:17 2025 ]]
local v0 = RaycastParams.new();
v0.FilterType = Enum.RaycastFilterType.Include;
v0.FilterDescendantsInstances = {
    workspace.Map
};
return function(v1) --[[ Line: 5 ]]
    local l_Folder_0 = v1.Folder;
    local v3 = v1.Number ~= nil and v1.Number or 0.025;
    local v4 = v1.DisableTween or false;
    local v5 = v1.tweeninfo or TweenInfo.new(v3, Enum.EasingStyle.Sine);
    local v6 = {};
    for _, v8 in pairs(l_Folder_0:GetChildren()) do
        v6[tonumber(v8.Name)] = v8;
    end;
    local v9 = Instance.new("BlurEffect", workspace.CurrentCamera);
    v9.Size = v1.Blur or 0;
    local function v15() --[[ Line: 21 ]] --[[ Name: excuteframes ]]
        -- upvalues: v6 (copy), v4 (copy), v3 (copy), v9 (copy), v5 (copy)
        for _, v11 in ipairs(v6) do
            local l_CurrentCamera_0 = workspace.CurrentCamera;
            local v13 = v11:Clone();
            v13.Parent = l_CurrentCamera_0;
            if v4 then
                task.wait(v3);
                v13:Destroy();
            else
                game.TweenService:Create(v9, v5, {
                    Size = 0
                }):Play();
                local v14 = game.TweenService:Create(v13, v5, {
                    Brightness = 0, 
                    Contrast = 0, 
                    Saturation = 0, 
                    TintColor = Color3.new(1, 1, 1)
                });
                v14:Play();
                v14.Completed:Wait();
                v13:Destroy();
            end;
        end;
        v9:Destroy();
    end;
    if v1.yeild then
        v15();
        return;
    else
        task.spawn(v15);
        return;
    end;
end;