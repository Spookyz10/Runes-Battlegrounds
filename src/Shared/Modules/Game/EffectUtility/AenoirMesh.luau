-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: AenoirMesh, time of decompilation: Tue Aug  5 05:07:07 2025 ]]
local _ = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local v2 = Random.new();
local v3 = {};
v3.__index = v3;
v3.new = function(v4, v5) --[[ Line: 57 ]] --[[ Name: new ]]
    -- upvalues: v3 (copy)
    if not v5 then
        v5 = v4:GetAttributes();
    end;
    return (setmetatable({
        source = v4, 
        finish = v4.End, 
        start = v4.Start, 
        info = v5
    }, v3));
end;
v3.destroy = function(v6) --[[ Line: 76 ]] --[[ Name: destroy ]]
    table.clear(v6);
    setmetatable(v6, nil);
end;
v3.get_tween_info = function(v7, v8) --[[ Line: 81 ]] --[[ Name: get_tween_info ]]
    local v9 = string.split(v8 or "", ",");
    local v10 = Enum.EasingStyle:FromName(v9[1] or "");
    local v11 = Enum.EasingDirection:FromName(v9[2] or "");
    return TweenInfo.new(v7 or 1, v10 or Enum.EasingStyle.Quad, v11 or Enum.EasingDirection.Out);
end;
local function _(v12) --[[ Line: 93 ]] --[[ Name: get_cframe ]]
    if v12:IsA("PVInstance") then
        return (v12:GetPivot());
    else
        return v12.WorldCFrame;
    end;
end;
v3.emit = function(v14, v15) --[[ Line: 97 ]] --[[ Name: emit ]]
    task.spawn(v14.emit_particle, v14, if v15:IsA("PVInstance") then v15:GetPivot() else v15.WorldCFrame);
    if v14.info.EmitDuration and v14.info.EmitDuration > 0 and v14.info.Rate then
        local v18 = task.spawn(function() --[[ Line: 101 ]]
            -- upvalues: v14 (copy), v15 (copy)
            while task.wait(1 / v14.info.Rate) do
                local l_v14_0 = v14;
                local l_v15_0 = v15;
                l_v14_0:emit_particle(if l_v15_0:IsA("PVInstance") then l_v15_0:GetPivot() else l_v15_0.WorldCFrame);
            end;
        end);
        task.delay(v14.info.EmitDuration, function() --[[ Line: 107 ]]
            -- upvalues: v18 (copy)
            if coroutine.status(v18) == "suspended" then
                task.cancel(v18);
            end;
        end);
    end;
end;
v3.emit_particle = function(v19, v20) --[[ Line: 115 ]] --[[ Name: emit_particle ]]
    -- upvalues: v3 (copy), v2 (copy), l_TweenService_0 (copy)
    local v21 = v19.start:Clone();
    local l_Mesh_0 = v21:FindFirstChild("Mesh");
    local l_Decal_0 = v21:FindFirstChild("Decal");
    local l_Mesh_1 = v19.finish:FindFirstChild("Mesh");
    local _ = v19.finish:FindFirstChild("Decal");
    local v26 = v3.get_tween_info(v19.info.Duration, v19.info.Part_TweenParams);
    local _ = v3.get_tween_info(v19.info.Duration, v19.info.Mesh_TweenParams) or v26;
    local _ = v3.get_tween_info(v19.info.Duration, v19.info.Decal_TweenParams) or v26;
    local v29 = if v19.info.Random then CFrame.lookAlong(Vector3.new(0, 0, 0, 0), v2:NextUnitVector()) else CFrame.identity;
    local v30 = if v19.info.Random then CFrame.lookAlong(Vector3.new(0, 0, 0, 0), v2:NextUnitVector()) else CFrame.identity;
    local l_Pivot_0 = v19.source:GetPivot();
    local v32 = v20 * l_Pivot_0:ToObjectSpace(v19.finish.CFrame) * v29;
    local v33 = v20 * l_Pivot_0:ToObjectSpace(v21.CFrame) * v30;
    if l_Decal_0 then
        l_Decal_0.Transparency = v19.info.Decal_StartTransparency;
    end;
    v21.CFrame = v33;
    v21.Size = v21.Size * 1;
    v21.CanCollide = false;
    v21.CanQuery = false;
    v21.CanTouch = false;
    v21.CollisionGroup = "Effects";
    v21.Name = "MeshFX";
    v21.Transparency = v19.info.Mesh_StartTransparency;
    v21.Parent = workspace.Visuals;
    l_TweenService_0:Create(v21, v26, {
        Size = v19.finish.Size * 1, 
        CFrame = v32
    }):Play();
    l_TweenService_0:Create(v21, v26, {
        Transparency = v19.info.Mesh_EndTransparency
    }):Play();
    if l_Mesh_0 then
        l_TweenService_0:Create(l_Mesh_0, v26, {
            Scale = l_Mesh_1.Scale * 1, 
            Offset = l_Mesh_1.Offset
        }):Play();
    end;
    if l_Decal_0 then
        l_TweenService_0:Create(l_Decal_0, v26, {
            Transparency = v19.info.Decal_EndTransparency
        }):Play();
    end;
    task.delay(v26.Time, function() --[[ Line: 181 ]]
        -- upvalues: v21 (ref)
        v21:Destroy();
        v21 = nil;
    end);
end;
table.freeze(v3);
return v3;