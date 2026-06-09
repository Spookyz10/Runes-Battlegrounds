-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Utils, time of decompilation: Wed Jun 18 20:48:16 2025 ]]
local v26 = {
    FixMesh = function(_, v1) --[[ Line: 3 ]] --[[ Name: FixMesh ]]
        local l_Highlight_0 = Instance.new("Highlight");
        l_Highlight_0.Parent = v1;
        l_Highlight_0.OutlineTransparency = 1;
        l_Highlight_0.FillTransparency = 1;
        return l_Highlight_0;
    end, 
    scaleModel = function(_, v4, v5) --[[ Line: 11 ]] --[[ Name: scaleModel ]]
        local v6 = false;
        if typeof(v4) == "Instance" then
            v6 = v4:IsA("Model");
        end;
        assert(v6, "Input must be a Model");
        v6 = false;
        if typeof(v5) == "number" then
            v6 = v5 > 0;
        end;
        assert(v6, "Scale must be a positive number");
        local function v11(v7) --[[ Line: 15 ]] --[[ Name: scaleAttributes ]]
            -- upvalues: v5 (copy)
            local v8 = {
                "VertexColor", 
                "Transparency", 
                "delay", 
                "Repeat", 
                "time"
            };
            for v9, v10 in v7:GetAttributes() do
                if not table.find(v8, v9) then
                    if typeof(v10) == "Vector3" then
                        v7:SetAttribute(v9, v10 * v5);
                    elseif typeof(v10) == "number" then
                        v7:SetAttribute(v9, v10 * v5);
                    end;
                end;
            end;
        end;
        v4:ScaleTo(v5);
        for _, v13 in v4:GetDescendants() do
            v11(v13);
        end;
    end, 
    delta_weld = function(_, v15, v16, v17, v18) --[[ Line: 49 ]] --[[ Name: delta_weld ]]
        local v19 = nil;
        v19 = game["Run Service"].Heartbeat:Connect(function() --[[ Line: 50 ]]
            -- upvalues: v16 (copy), v19 (ref), v15 (copy), v17 (copy)
            if not v16 then
                v19:Disconnect();
            end;
            local v20 = nil;
            if typeof(v15) == "function" then
                v20 = v15();
            elseif typeof(v15) == "Instance" then
                v20 = if v15:IsA("Model") then v15.PrimaryPart.CFrame else v15.CFrame;
            elseif typeof(v15) == "CFrame" then
                v20 = v15;
            end;
            if v16:IsA("Model") then
                v16:PivotTo(v20 * v17);
                return;
            else
                v16.CFrame = v20 * (v17 and v17 or CFrame.new());
                return;
            end;
        end);
        if v18 then
            task.delay(v18, function() --[[ Line: 77 ]]
                -- upvalues: v19 (ref)
                if v19 and typeof(v19) == "RBXScriptConnection" then
                    v19:Disconnect();
                end;
            end);
        end;
        return {
            Destory = function() --[[ Line: 86 ]] --[[ Name: Destory ]]
                -- upvalues: v19 (ref)
                if v19 then
                    v19:Disconnect();
                end;
            end, 
            Connection = v19
        };
    end, 
    createinfo = function(_, v22) --[[ Line: 96 ]] --[[ Name: createinfo ]]
        local l_v22_Attributes_0 = v22:GetAttributes();
        return TweenInfo.new(l_v22_Attributes_0.time, Enum.EasingStyle[l_v22_Attributes_0.style], Enum.EasingDirection[l_v22_Attributes_0.direction], tonumber(l_v22_Attributes_0.Repeat), l_v22_Attributes_0.reverse, (tonumber(l_v22_Attributes_0.delay)));
    end, 
    RaycastParams = {
        Map = function() --[[ Line: 102 ]] --[[ Name: Map ]]
            local v24 = RaycastParams.new();
            v24.FilterType = Enum.RaycastFilterType.Include;
            v24.FilterDescendantsInstances = {
                workspace.Map
            };
            return v24;
        end
    }, 
    OverlapParams = {
        Map = function() --[[ Line: 112 ]] --[[ Name: Map ]]
            local v25 = OverlapParams.new();
            v25.FilterType = Enum.RaycastFilterType.Include;
            v25.FilterDescendantsInstances = {
                workspace.Map.FixedMap
            };
            return v25;
        end
    }
};
v26.RequestRaycastParams = function(v27) --[[ Line: 121 ]]
    -- upvalues: v26 (copy)
    assert(v26.RaycastParams[v27], "Requested raycast params does not exist - " .. v27);
    return v26.RaycastParams[v27] ~= nil and v26.RaycastParams[v27]() or nil;
end;
v26.RequestOverlapParams = function(v28) --[[ Line: 126 ]]
    -- upvalues: v26 (copy)
    assert(v26.OverlapParams[v28], "Requested raycast params does not exist - " .. v28);
    return v26.OverlapParams[v28] ~= nil and v26.OverlapParams[v28]() or nil;
end;
return v26;