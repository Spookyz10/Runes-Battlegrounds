local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local l_RunService_0 = game:GetService("RunService");
local v3 = {
    Immune = false
};
local v4 = nil;
local l_CurrentCamera_0 = workspace.CurrentCamera;
local function Cancel() --[[ Line: 15 ]] --[[ Name: Cancel ]]
    -- upvalues: v4 (ref)
    if v4 ~= nil then
        v4:Cancel();
        v4 = nil;
    end;
end;
v3.Tween = function(v8, v9, v10) --[[ Line: 24 ]] --[[ Name: Tween ]]
    -- upvalues: v3 (copy), v4 (ref), l_TweenService_0 (copy), l_CurrentCamera_0 (copy)
    if v3.Immune then
        return;
    else
        if v10 and v4 ~= nil then
            v4:Cancel();
            v4 = nil;
        end;
        v4 = l_TweenService_0:Create(l_CurrentCamera_0, TweenInfo.new(table.unpack(v9)), {
            FieldOfView = v8 or 70
        });
        v4:Play();
        v4.Completed:Once(function() --[[ Line: 36 ]]
            -- upvalues: v4 (ref)
            if v4 then
                v4:Destroy();
                v4 = nil;
            end;
        end);
        return;
    end;
end;
v3.Set = function(v11) --[[ Line: 44 ]] --[[ Name: Set ]]
    -- upvalues: v3 (copy), v4 (ref), l_CurrentCamera_0 (copy)
    if v3.Immune then
        return;
    else
        if v4 ~= nil then
            v4:Cancel();
            v4 = nil;
        end;
        l_CurrentCamera_0.FieldOfView = v11;
        return;
    end;
end;
v3.Reset = function() --[[ Line: 51 ]] --[[ Name: Reset ]]
    -- upvalues: v3 (copy), v4 (ref), l_CurrentCamera_0 (copy)
    if v3.Immune then
        return;
    else
        if v4 ~= nil then
            v4:Cancel();
            v4 = nil;
        end;
        l_CurrentCamera_0.FieldOfView = 70;
        return;
    end;
end;
v3.AnimateWithMoonFile = function(v12, v13, v14) --[[ Line: 60 ]] --[[ Name: AnimateWithMoonFile ]]
    -- upvalues: v3 (copy), l_RunService_0 (copy), l_CurrentCamera_0 (copy)
    v3.Immune = true;
    v14 = v14 or 0;
    local v15 = nil;
    local v16 = false;
    local v17 = false;
    local function v18() --[[ Line: 73 ]] --[[ Name: Clean ]]
        -- upvalues: v16 (ref), v15 (ref), v3 (ref), v13 (copy)
        if v16 then
            return;
        else
            v16 = true;
            v15:Disconnect();
            v3.Immune = false;
            if not v13 then
                v3.Tween(70, {
                    0.5, 
                    Enum.EasingStyle.Quart, 
                    Enum.EasingDirection.Out
                });
            end;
            return;
        end;
    end;
    local v19 = os.clock();
    local v20 = #v12:GetChildren();
    v15 = l_RunService_0.PreRender:Connect(function() --[[ Line: 91 ]]
        -- upvalues: v17 (ref), v19 (copy), v20 (copy), v18 (copy), l_CurrentCamera_0 (ref), v12 (copy), v14 (ref)
        if v17 then
            return;
        else
            local v21 = math.ceil((os.clock() - v19) / 0.016666666666666666);
            if v20 <= v21 then
                return v18();
            else
                l_CurrentCamera_0.FieldOfView = v12[v21].Value + v14;
                return;
            end;
        end;
    end);
    l_CurrentCamera_0.FieldOfView = v12["0"].Value + v14;
    return v18, function(v22) --[[ Line: 108 ]]
        -- upvalues: v17 (ref)
        v17 = v22;
    end;
end;
return v3;