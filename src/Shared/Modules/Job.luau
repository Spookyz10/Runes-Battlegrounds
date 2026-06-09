local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
local v3 = {};
local v4 = {};
v4.__index = v4;
v4.Task = function(v5, v6) --[[ Line: 28 ]] --[[ Name: Task ]]
    if v5.Destroyed then
        v5:CleanTask(v6);
        return v6;
    else
        if v6 ~= nil then
            v5.Tasks[v6] = true;
        end;
        return v6;
    end;
end;
v4.BindToRender = function(v7, v8, v9, v10) --[[ Line: 40 ]] --[[ Name: BindToRender ]]
    -- upvalues: l_RunService_0 (copy)
    l_RunService_0:BindToRenderStep(v8, v9, v10);
    v7:Task(function() --[[ Line: 43 ]]
        -- upvalues: l_RunService_0 (ref), v8 (copy)
        l_RunService_0:UnbindFromRenderStep(v8);
    end);
end;
v4.CleanTask = function(_, v12) --[[ Line: 50 ]] --[[ Name: CleanTask ]]
    local v13 = typeof(v12);
    if v13 == "function" then
        task.spawn(v12);
    end;
    if v13 == "RBXScriptConnection" then
        if v12.Connected then
            v12:Disconnect();
            return;
        end;
    elseif v13 == "thread" then
        if coroutine.status(v12) == "suspended" then
            task.cancel(v12);
            return;
        end;
    elseif v13 == "table" then
        if v12.IsACameraShakeInstance and v12.StartFadeOut and v12.IsShaking and v12:IsShaking() then
            v12:StartFadeOut(0.05);
        end;
        if v12.Destroy then
            v12:Destroy();
            return;
        end;
    elseif v13 == "Tween" then
        v12:Canccel();
        v12:Destroy();
        return;
    elseif v13 == "Instance" then
        v12:Destroy();
    end;
end;
v4.Clean = function(v14) --[[ Line: 93 ]] --[[ Name: Clean ]]
    for v15 in v14.Tasks do
        v14.Tasks[v15] = nil;
        v14:CleanTask(v15);
    end;
    table.clear(v14.Tasks);
end;
v4.Destroy = function(v16) --[[ Line: 102 ]] --[[ Name: Destroy ]]
    v16.Destroyed = true;
    v16:Clean();
end;
v4.Extend = function(v17) --[[ Line: 107 ]] --[[ Name: Extend ]]
    -- upvalues: v3 (copy)
    return v3.Extend(v17);
end;
v3.new = function() --[[ Line: 113 ]] --[[ Name: new ]]
    -- upvalues: v4 (copy)
    local v18 = setmetatable({}, v4);
    v18.Destroyed = false;
    v18.Tasks = {};
    return v18;
end;
v3.Extend = function(v19) --[[ Line: 122 ]] --[[ Name: Extend ]]
    -- upvalues: v3 (copy)
    local v20 = v3.new();
    v19:Task(v20);
    return v20;
end;
table.freeze(v3);
table.freeze(v4);
return v3;