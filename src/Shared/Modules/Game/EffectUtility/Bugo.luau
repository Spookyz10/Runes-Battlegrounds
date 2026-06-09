-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Bugo, time of decompilation: Tue Aug  5 05:07:08 2025 ]]
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local v2 = require(l_ReplicatedStorage_0.Modules.Game.Utility);
local function Debris(v3, v4) --[[ Line: 24 ]] --[[ Name: Debris ]]
    task.delay(v4, function() --[[ Line: 25 ]]
        -- upvalues: v3 (copy)
        if typeof(v3) == "Instance" and v3.Destroy then
            v3:Destroy();
        end;
    end);
    return v3;
end;
local function EmitParticle(v6, v7) --[[ Line: 34 ]] --[[ Name: EmitParticle ]]
    v6:Emit(v6:GetAttribute("EmitCount") or v6.Rate);
    return v7 < v6.Lifetime.Max and v6.Lifetime.Max or v7;
end;
local function v21(v9, v10, v11) --[[ Line: 39 ]] --[[ Name: Emit ]]
    if v10 then
        v9 = v9:Clone();
        if v9:IsA("Attachment") then
            v9.Parent = v10;
        else
            if typeof(v10) == "CFrame" then
                if v9:IsA("Model") then
                    v9:PivotTo(v10);
                else
                    v9.CFrame = v10;
                end;
            else
                local v12 = v9:IsA("Model") and v9.PrimaryPart or v9;
                local l_Weld_0 = Instance.new("Weld");
                l_Weld_0.Part0 = v10;
                l_Weld_0.Part1 = v12;
                l_Weld_0.Parent = v12;
            end;
            v9.Parent = workspace.Thrown;
        end;
    end;
    local v14 = 0;
    for _, v16 in v9:GetDescendants() do
        if v16:IsA("ParticleEmitter") then
            local l_v16_Attribute_0 = v16:GetAttribute("EmitDelay");
            if l_v16_Attribute_0 and l_v16_Attribute_0 ~= 0 then
                task.delay(l_v16_Attribute_0, function() --[[ Line: 74 ]]
                    -- upvalues: v9 (ref), v14 (ref), v16 (copy)
                    if v9 then
                        local l_v16_0 = v16;
                        local l_v14_0 = v14;
                        l_v16_0:Emit(l_v16_0:GetAttribute("EmitCount") or l_v16_0.Rate);
                        v14 = l_v14_0 < l_v16_0.Lifetime.Max and l_v16_0.Lifetime.Max or l_v14_0;
                    end;
                end);
            else
                local l_v14_1 = v14;
                v16:Emit(v16:GetAttribute("EmitCount") or v16.Rate);
                if l_v14_1 < v16.Lifetime.Max then
                    v14 = v16.Lifetime.Max;
                    if v14 then
                        continue;
                    end;
                end;
                v14 = l_v14_1;
            end;
        end;
    end;
    task.delay(v11 or v14, function() --[[ Line: 84 ]]
        -- upvalues: v9 (ref)
        if v9 then
            v9:Destroy();
        end;
    end);
    return v9;
end;
local function v35(v22, v23, v24, v25, v26) --[[ Line: 93 ]] --[[ Name: Enable ]]
    if v24 then
        v23 = v23:Clone();
        if typeof(v24) == "CFrame" then
            v23.CFrame = v24;
            v23.Parent = workspace.Thrown;
        elseif v23:IsA("BasePart") then
            local l_Weld_1 = Instance.new("Weld");
            l_Weld_1.Part0 = v24;
            l_Weld_1.Part1 = v23;
            l_Weld_1.Parent = v23;
            v23.Parent = v24;
        elseif v23:IsA("Attachment") then
            v23.Parent = v24;
        end;
    end;
    local v28 = {};
    local v29 = 0;
    for _, v31 in v23:GetDescendants() do
        if (typeof(v22) ~= "string" or v31:IsA(v22)) and (typeof(v22) ~= "table" or table.find(v22, v31.ClassName)) then
            v31.Enabled = not v26;
            if v25 then
                if not v31:IsA("Beam") then
                    local v32 = typeof(v31.Lifetime) == "NumberRange" and v31.Lifetime.Max or v31.Lifetime;
                    v29 = v29 < v32 and v32 or v29;
                end;
                table.insert(v28, v31);
            end;
        end;
    end;
    if v25 then
        task.delay(v25, function() --[[ Line: 133 ]]
            -- upvalues: v28 (copy), v26 (copy), v29 (ref), v23 (ref)
            for _, v34 in v28 do
                v34.Enabled = v26 and true or false;
            end;
            task.wait(v29);
            if v23 then
                v23:Destroy();
            end;
        end);
    end;
    return v23;
end;
local function Mesh(v36, v37, v38) --[[ Line: 149 ]] --[[ Name: Mesh ]]
    local v39 = v36:Clone();
    if typeof(v37) == "CFrame" then
        v39.CFrame = v37;
    elseif typeof(v37) == "Vector3" then
        v39.Position = v37;
    else
        v39.Anchored = false;
        local l_Weld_2 = Instance.new("Weld");
        l_Weld_2.Part0 = v37;
        l_Weld_2.Part1 = v39;
        l_Weld_2.Parent = v39;
    end;
    v39.Parent = workspace.Thrown;
    if v38 then
        task.delay(v38, function() --[[ Line: 25 ]]
            -- upvalues: v39 (copy)
            if typeof(v39) == "Instance" and v39.Destroy then
                v39:Destroy();
            end;
        end);
    end;
    return v39;
end;
Tween = function(v42, v43, v44, v45, v46) --[[ Line: 174 ]] --[[ Name: Tween ]]
    -- upvalues: l_TweenService_0 (copy)
    local v47 = l_TweenService_0:Create(v42, TweenInfo.new(tonumber(v43), Enum.EasingStyle[v44], Enum.EasingDirection[v45]), v46);
    v47:Play();
    v47.Completed:Connect(function() --[[ Line: 178 ]] --[[ Name: Cleanup ]]
        -- upvalues: v47 (copy)
        v47:Destroy();
    end);
    return v47;
end;
local v48 = nil;
v48 = {
    Meshes = function(v49, v50, v51) --[[ Line: 191 ]] --[[ Name: Meshes ]]
        -- upvalues: v48 (ref)
        local l_CFrame_0 = v50.CFrame;
        local l_Start_0 = v49.Start;
        local l_End_0 = v49.End;
        local l_v49_Attribute_0 = v49:GetAttribute("StartTransparency");
        local l_v49_Attribute_1 = v49:GetAttribute("Distortion");
        local l_v49_Attribute_2 = v49:GetAttribute("Duration");
        local l_v49_Attribute_3 = v49:GetAttribute("Welded");
        local v59 = v49:GetAttribute("Part_TweenParams"):split(",");
        local v60 = v59[1];
        local v61 = v59[2];
        local v62 = l_Start_0:Clone();
        local l_v62_0 = v62 --[[ copy: 14 -> 21 ]];
        task.delay(l_v49_Attribute_2, function() --[[ Line: 25 ]]
            -- upvalues: l_v62_0 (copy)
            if typeof(l_v62_0) == "Instance" and l_v62_0.Destroy then
                l_v62_0:Destroy();
            end;
        end);
        local l_v62_1 = v62;
        if l_v49_Attribute_1 then
            v62 = Instance.new("Highlight");
            v62.Enabled = false;
            v62.Parent = l_v62_1;
        end;
        if l_v49_Attribute_3 then
            v62 = Instance.new("Weld");
            v62.Part0 = v50;
            v62.Part1 = l_v62_1;
            v62.C0 = l_Start_0.CFrame;
            v62.Parent = l_v62_1;
            Tween(v62, l_v49_Attribute_2, v60, v61, {
                C0 = l_End_0.CFrame
            });
        else
            l_v62_1.CFrame = l_CFrame_0 * l_Start_0.CFrame;
        end;
        v62 = l_v62_1:IsA("Part");
        if v62 then
            local v65 = v49:GetAttribute("Mesh_TweenParams"):split(",");
            local v66 = v65[1];
            local v67 = v65[2];
            local v68 = v49:GetAttribute("Decal_TweenParams"):split(",");
            local v69 = v68[1];
            local v70 = v68[2];
            l_v62_1.Decal.Transparency = l_v49_Attribute_0;
            Tween(l_v62_1.Decal, l_v49_Attribute_2, v69, v70, {
                Transparency = tonumber(v49:GetAttribute("EndTransparency")) or 1
            });
            Tween(l_v62_1.Mesh, l_v49_Attribute_2, v66, v67, {
                Scale = l_End_0.Mesh.Scale
            });
        else
            l_v62_1.Transparency = l_v49_Attribute_0;
        end;
        Tween(l_v62_1, l_v49_Attribute_2, v60, v61, {
            CFrame = not l_v49_Attribute_3 and l_CFrame_0 * l_End_0.CFrame or nil, 
            Size = l_End_0.Size, 
            Transparency = not v62 and v49:GetAttribute("EndTransparency") or 1
        });
        l_v62_1.Parent = workspace.Thrown;
        local v71 = v51 or v49:GetAttribute("RepeatCount");
        local l_v49_Attribute_4 = v49:GetAttribute("RepeatDelay");
        if v71 and v71 > 0 then
            if l_v49_Attribute_4 then
                task.delay(l_v49_Attribute_4, v48.Meshes, v49, v50, v71 - 1);
                return;
            else
                v48.Meshes(v49, v50, v71 - 1);
            end;
        end;
    end, 
    Emit = function(v73, v74) --[[ Line: 264 ]] --[[ Name: Emit ]]
        -- upvalues: v2 (copy), v21 (copy)
        local l_v73_Attribute_0 = v73:GetAttribute("Parent");
        local l_v73_Attribute_1 = v73:GetAttribute("Raycast");
        local l_v74_0 = v74;
        if l_v73_Attribute_0 then
            l_v74_0 = v74.Parent;
            for _, v79 in l_v73_Attribute_0:split(".") do
                if not l_v74_0 then
                    return;
                else
                    l_v74_0 = l_v74_0:FindFirstChild(v79);
                end;
            end;
        end;
        if l_v73_Attribute_1 then
            local l_Position_0 = (v74.CFrame * v73.CFrame).Position;
            local v81 = workspace:Raycast(l_Position_0, l_v73_Attribute_1, v2.VisualParams);
            if not v81 then
                return;
            else
                local v82 = v73:GetAttribute("RaycastHitOffset") or Vector3.new(0, 0, 0, 0);
                l_v74_0 = CFrame.new(v81.Position + v82) * (v74.CFrame - v74.Position);
            end;
        end;
        v21(v73, l_v74_0);
    end, 
    Enabled = function(v83, v84) --[[ Line: 296 ]] --[[ Name: Enabled ]]
        -- upvalues: v35 (copy)
        local l_v83_Attribute_0 = v83:GetAttribute("Parent");
        local l_Parent_0 = v84.Parent;
        if l_v83_Attribute_0 then
            for _, v88 in l_v83_Attribute_0:split(".") do
                if not l_Parent_0 then
                    return;
                else
                    l_Parent_0 = l_Parent_0:FindFirstChild(v88);
                end;
            end;
        end;
        if not l_Parent_0 then
            return;
        else
            local v89 = tonumber(v83:GetAttribute("Time"));
            v35({
                "ParticleEmitter", 
                "Trail", 
                "Beam"
            }, v83, l_Parent_0, v89);
            return;
        end;
    end
};
return function(v90, v91) --[[ Line: 319 ]]
    -- upvalues: v48 (ref)
    for _, v93 in v90:GetChildren() do
        if v48[v93.Name] then
            for _, v95 in v93:GetChildren() do
                v48[v93.Name](v95, v91);
            end;
        end;
    end;
end;