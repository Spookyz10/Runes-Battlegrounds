-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Job, time of decompilation: Tue Aug  5 05:08:56 2025 ]]
--!native
local l_RunService_0 = game:GetService("RunService");
local v1 = {};
v1.__index = v1;
v1.Task = function(v2, v3) --[[ Line: 23 ]] --[[ Name: Task ]]
    if v2.Destroyed then
        v2:CleanTask(v3);
        return v3;
    else
        if v3 ~= nil then
            v2.Tasks[v3] = true;
        end;
        return v3;
    end;
end;
v1.BindToRender = function(v4, v5, v6, v7) --[[ Line: 43 ]] --[[ Name: BindToRender ]]
    -- upvalues: l_RunService_0 (copy)
    l_RunService_0:BindToRenderStep(v5, v6, v7);
    v4:Task(function() --[[ Line: 46 ]]
        -- upvalues: l_RunService_0 (ref), v5 (copy)
        l_RunService_0:UnbindFromRenderStep(v5);
    end);
end;
v1.CleanTask = function(_, v9) --[[ Line: 53 ]] --[[ Name: CleanTask ]]
    local v10 = typeof(v9);
    if v10 == "function" then
        task.spawn(v9);
    end;
    if v10 == "RBXScriptConnection" then
        if v9.Connected then
            v9:Disconnect();
            return;
        end;
    elseif v10 == "thread" then
        if coroutine.status(v9) == "suspended" then
            task.cancel(v9);
            return;
        end;
    elseif v10 == "table" then
        if v9.IsACameraShakeInstance and v9.StartFadeOut and v9.IsShaking and v9:IsShaking() then
            v9:StartFadeOut(0.05);
        end;
        if v9.Destroy then
            v9:Destroy();
            return;
        end;
    elseif v10 == "Tween" then
        v9:Cancel();
        v9:Destroy();
        return;
    elseif v10 == "Instance" then
        v9:Destroy();
    end;
end;
v1.Clean = function(v11) --[[ Line: 96 ]] --[[ Name: Clean ]]
    for v12 in v11.Tasks do
        v11:CleanTask(v12);
    end;
    table.clear(v11.Tasks);
end;
v1.Destroy = function(v13) --[[ Line: 104 ]] --[[ Name: Destroy ]]
    v13.Destroyed = true;
    v13:Clean();
end;
local v15 = {
    new = function() --[[ Line: 113 ]] --[[ Name: new ]]
        -- upvalues: v1 (copy)
        local v14 = setmetatable({}, v1);
        v14.Destroyed = false;
        v14.Tasks = {};
        return v14;
    end
};
v15.Extend = function(v16) --[[ Line: 122 ]] --[[ Name: Extend ]]
    -- upvalues: v15 (copy)
    local v17 = v15.new();
    v16:Task(v17);
    return v17;
end;
table.freeze(v15);
table.freeze(v1);
return v15;