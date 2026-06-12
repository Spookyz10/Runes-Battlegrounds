local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local l_TweenService_0 = game:GetService("TweenService")
local l_RunService_0 = game:GetService("RunService")
local v3 = require(l_ReplicatedStorage_0.Modules.Game.Job)
local v4 = require(script.Parent.AenoirMesh)
local v5 = Random.new()

local v8 = {
    Increment = function(v6) --[[ Line: 12 ]] --[[ Name: Increment ]]
        v6.Items = v6.Items + 1;
    end, 
    Decrement = function(v7) --[[ Line: 16 ]] --[[ Name: Decrement ]]
        v7.Items = v7.Items - 1;
        if v7.Items <= 0 then
            v7.Job:Destroy();
            if v7.Finished then
                v7.Finished();
            end;
        end;
    end
}
local function v15(v9, v10) --[[ Line: 28 ]] --[[ Name: EvaluateNumberSequence ]]
    local l_Keypoints_0 = v9.Keypoints;
    if v10 <= 0 then
        return l_Keypoints_0[1].Value;
    elseif v10 >= 1 then
        return l_Keypoints_0[#l_Keypoints_0].Value;
    else
        for v12 = 1, #l_Keypoints_0 - 1 do
            local v13 = l_Keypoints_0[v12];
            local v14 = l_Keypoints_0[v12 + 1];
            if v13.Time <= v10 and v10 <= v14.Time then
                return (math.lerp(v13.Value, v14.Value, (v10 - v13.Time) / (v14.Time - v13.Time)));
            end;
        end;
        error("NumberSequence could not return a value");
        return;
    end;
end;
local function v16(v17, v18, v19) --[[ Line: 49 ]] --[[ Name: EmitSingle ]]
    -- upvalues: v8 (copy), l_TweenService_0 (copy), v5 (copy), v15 (copy), l_RunService_0 (copy), v16 (copy), v4 (copy)
    v17.Archivable = false;
    local l_v17_Attributes_0 = v17:GetAttributes();
    local v21 = l_v17_Attributes_0.EmitDelay or 0;
    if v21 ~= 0 then
        task.wait(v21);
    end;
    if v17:IsA("ParticleEmitter") then
        v17.Parent = v18;
        local l_EmitCount_0 = l_v17_Attributes_0.EmitCount;
        local l_EmitUptime_0 = l_v17_Attributes_0.EmitUptime;
        v8.Increment(v19);
        task.delay(v17.Lifetime.Max + (l_EmitUptime_0 or 0), function() --[[ Line: 66 ]]
            -- upvalues: v8 (ref), v19 (copy), v17 (copy)
            v8.Decrement(v19);
            v17:Destroy();
        end);
        if l_EmitCount_0 then
            v17:Emit(l_EmitCount_0);
        end;
        if l_EmitUptime_0 then
            v17.Enabled = true;
            task.delay(l_EmitUptime_0, function() --[[ Line: 78 ]]
                -- upvalues: v17 (copy)
                v17.Enabled = false;
            end);
            return;
        end;
    elseif v17:IsA("Sound") then
        v17.Parent = v18;
        if not v17.IsLoaded then
            v17.Loaded:Wait();
        end;
        v17:Play();
        if l_v17_Attributes_0.Pitch then
            v17.PlaybackSpeed = l_v17_Attributes_0.Pitch.Min + math.random() * (l_v17_Attributes_0.Pitch.Max - l_v17_Attributes_0.Pitch.Min);
        end;
        if l_v17_Attributes_0.FadeIn then
            local l_Volume_0 = v17.Volume;
            v17.Volume = 0;
            local l_l_Volume_0_0 = l_Volume_0 --[[ copy: 5 -> 10 ]];
            task.delay(l_v17_Attributes_0.FadeIn.Min, function() --[[ Line: 100 ]]
                -- upvalues: l_TweenService_0 (ref), v17 (copy), l_v17_Attributes_0 (copy), l_l_Volume_0_0 (copy)
                l_TweenService_0:Create(v17, TweenInfo.new(l_v17_Attributes_0.FadeIn.Max - l_v17_Attributes_0.FadeIn.Min), {
                    Volume = l_l_Volume_0_0
                }):Play();
            end);
        end;
        if l_v17_Attributes_0.FadeOut then
            task.delay(l_v17_Attributes_0.FadeOut.Min, function() --[[ Line: 109 ]]
                -- upvalues: l_TweenService_0 (ref), v17 (copy), l_v17_Attributes_0 (copy)
                l_TweenService_0:Create(v17, TweenInfo.new(l_v17_Attributes_0.FadeOut.Max - l_v17_Attributes_0.FadeOut.Min), {
                    Volume = 0
                }):Play();
            end);
        end;
        local v26 = if l_v17_Attributes_0.FadeOut then l_v17_Attributes_0.FadeOut.Max else v17.TimeLength;
        v8.Increment(v19);
        task.delay(v26, function() --[[ Line: 120 ]]
            -- upvalues: v8 (ref), v19 (copy), v17 (copy)
            v8.Decrement(v19);
            v17:Destroy();
        end);
        return;
    elseif v17:IsA("Light") then
        v17.Parent = v18;
        local v27 = 1;
        local l_Brightness_0 = v17.Brightness;
        if l_v17_Attributes_0.Lifetime then
            v27 = v5:NextNumber(l_v17_Attributes_0.Lifetime.Min, l_v17_Attributes_0.Lifetime.Max);
        end;
        if l_v17_Attributes_0.Brightness then
            local v29 = 0;
            local v30 = nil;
            do
                local l_v29_0, l_v30_0 = v29, v30;
                local function v34(v33) --[[ Line: 138 ]] --[[ Name: EffectStep ]]
                    -- upvalues: l_v29_0 (ref), v27 (ref), l_v30_0 (ref), v17 (copy), v15 (ref), l_v17_Attributes_0 (copy), l_Brightness_0 (copy)
                    l_v29_0 = l_v29_0 + v33;
                    if v27 < l_v29_0 then
                        l_v30_0:Disconnect();
                    end;
                    v17.Brightness = v15(l_v17_Attributes_0.Brightness, l_v29_0 / v27) * l_Brightness_0;
                end;
                l_v29_0 = l_v29_0 + 0;
                if v27 < l_v29_0 then
                    l_v30_0:Disconnect();
                end;
                v17.Brightness = v15(l_v17_Attributes_0.Brightness, l_v29_0 / v27) * l_Brightness_0;
                l_v30_0 = l_RunService_0.PostSimulation:Connect(v34);
            end;
        end;
        v17.Enabled = true;
        v8.Increment(v19);
        task.delay(v27, function() --[[ Line: 155 ]]
            -- upvalues: v8 (ref), v19 (copy), v17 (copy)
            v8.Decrement(v19);
            v17:Destroy();
        end);
        return;
    elseif v17:IsA("Folder") then
        local l_v17_Children_0 = v17:GetChildren();
        local v36 = l_v17_Children_0[math.random(#l_v17_Children_0)];
        if v36 then
            v16(v36, v18, v19);
            return;
        end;
    elseif v17:IsA("Model") then
        v4.new(v17):emit(v18);
        return;
    else
        for _, v38 in v17:GetChildren() do
            v16(v38, v18, v19);
        end;
    end;
end;
return function(v39, v40, v41) --[[ Line: 178 ]] --[[ Name: Emit ]]
    -- upvalues: v3 (copy), v16 (copy)
    local v42 = {
        Items = 0, 
        Job = v3.new(), 
        Finished = v41
    };
    local v43 = nil;
    if typeof(v40) == "CFrame" then
        v43 = Instance.new("Attachment");
        v43.CFrame = v40;
        v43.Parent = workspace.Terrain;
        v42.Job:Task(v43);
    else
        v43 = v40;
    end;
    v42.Job:Task(task.delay(15, v42.Job.Destroy, v42.Job));
    for _, v45 in v39:Clone():GetChildren() do
        task.spawn(v16, v45, v43, v42);
    end;
end;