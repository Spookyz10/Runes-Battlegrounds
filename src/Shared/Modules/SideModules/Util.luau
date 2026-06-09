local l_RunService_0 = game:GetService("RunService");
local l_TweenService_0 = game:GetService("TweenService");
local v2 = {};
local v3 = {};
local v4 = {};
local v5 = Random.new(12312);
v2.EmitParticlesAlt = function(_, v7)
    for _, v9 in pairs(v7:GetDescendants()) do
        if v9:IsA("ParticleEmitter") then
            v9:Emit(v9:GetAttribute("EmitCount"), v9:GetAttribute("EmitDelay"));
        end;
    end;
end;
v2.AddToCoreLoop = function(_, v11)
    table.insert(v3, v11);
end;
v2.FetchQuickPart = function(_)
    local l_Part_0 = Instance.new("Part");
    l_Part_0.Anchored = false;
    l_Part_0.CanCollide = false;
    l_Part_0.Transparency = 1;
    l_Part_0.CanCollide = false;
    l_Part_0.CastShadow = false;
    l_Part_0.Massless = true;
    l_Part_0.CanQuery = false;
    return l_Part_0;
end;
v2.AddTempFunction = function(_, v15, v16)
    local v17 = nil;
    if not v16 then

    end;
    v17 = {
        callback = v15, 
        Creation = os.clock(), 
        HasWarned = false, 
        traceback = debug.traceback()
    };
    table.insert(v4, v17);
end;
v2.BindWithSpacing = function(_, v19, v20, v21, v22)
    local v23 = os.clock();
    local l_v23_0 = v23;
    local v25 = false;
    v2:AddTempFunction(function()
        local v26 = os.clock() - l_v23_0;
        if v20 < v26 then
            l_v23_0 = os.clock() + v20;
            local v27 = (os.clock() - v23) / v21;
            local v28 = Lerp(1, 0, v27);
            v19((os.clock() - v23) / v21, v26, v28, os.clock() - v23);
        end;
        if not v25 and v21 < os.clock() - v23 then
            v25 = true;
            if v22 then
                v22((os.clock() - v23) / v21, v26);
            end;
            return true;
        else
            return ;
        end;
    end);
end;
v2.FadePointLightIn = function(_, v30, v31)
    local l_Brightness_0 = v30.Brightness;
    local l_Range_0 = v30.Range;
    v30.Brightness = 0;
    v30.Range = 0;
    l_TweenService_0:Create(v30, TweenInfo.new(v31), {
        Brightness = l_Brightness_0, 
        Range = l_Range_0
    }):Play();
end;
v2.DisableAllVisuals = function(_, v35)
    for _, v37 in ipairs(v35:GetDescendants()) do
        if not (not v37:IsA("ParticleEmitter") and not v37:IsA("Beam") and not v37:IsA("Trail")) or v37:IsA("PointLight") then
            v37.Enabled = false;
        end;
    end;
end;
v2.EnabledAllVisuals = function(_, v39)
    for _, v41 in pairs(v39:GetDescendants()) do
        if not (not v41:IsA("ParticleEmitter") and not v41:IsA("Beam") and not v41:IsA("Trail")) or v41:IsA("PointLight") then
            v41.Enabled = true;
        end;
    end;
end;
v2.EmitAllParticles = function(_, v43)
    for _, v45 in ipairs(v43:GetDescendants()) do
        if v45:IsA("ParticleEmitter") then
            v45:Emit(v45.Rate);
        end;
    end;
end;
v2.ScaleParticles = function(_, v47, v48)
    for _, v50 in pairs(v47:GetDescendants()) do
        if v50:IsA("ParticleEmitter") then
            local v51 = {};
            for v52 = 1, #v50.Size.Keypoints do
                table.insert(v51, NumberSequenceKeypoint.new(v50.Size.Keypoints[v52].Time, v50.Size.Keypoints[v52].Value * v48, v50.Size.Keypoints[v52].Envelope));
            end;
            v50.Speed = NumberRange.new(v50.Speed.Min * v48, v50.Speed.Max * v48);
            v50.Acceleration = v50.Acceleration * v48;
            v50.Size = NumberSequence.new(v51);
            table.clear(v51);
        end;
    end;
end;
Lerp = function(v53, v54, v55)
    return v53 + (v54 - v53) * v55;
end;
v2.Lerp = function(_, v57, v58, v59)
    return v57 + (v58 - v57) * v59;
end;
v2.ReturnRandomAngle = function(_)
    return CFrame.Angles(v5:NextNumber(-360, 360), v5:NextNumber(-360, 360), v5:NextNumber(-360, 360));
end;
v2.ConvertNormalPosToCF = function(_, v62, v63)
    local l_UpVector_0 = CFrame.lookAt(v63, v63 + v62).UpVector;
    local v65 = l_UpVector_0:Cross(v62);
    return CFrame.fromMatrix(v63, -v65, v62, l_UpVector_0);
end;
v2.UnixConnection2 = function(_, v67, v68, v69, v70)
    local v71 = false;
    local v72 = false;
    local v73 = tick();
    v2:AddTempFunction(function(v74)
        v71 = v73 + v67 <= tick();
        if v68 and (not (not v69 or not v69()) or v69 == nil) and not v71 then
            local v75 = (tick() - v73) / v67;
            v68(v75, v74, Lerp(1, 0, v75), tick() - v73);
            return ;
        elseif not v72 then
            v72 = true;
            if v68 and v71 then
                v68(1, v74, 0, v67);
            end;
            if v70 then
                v70(1, v74, 0);
            end;
            return true;
        else
            return ;
        end;
    end);
end;
v2.UnixConnection = function(_, v77, v78, v79, v80)
    local v81 = nil;
    v81 = if l_RunService_0:IsClient() then l_RunService_0.RenderStepped else l_RunService_0.Heartbeat;
    local v82 = nil;
    local v83 = false;
    local v84 = os.clock();
    local v85 = false;
    v82 = v81:Connect(function(v86)
        if not v85 then
            v85 = true;
            v83 = v84 + v77 <= os.clock();
            if v78 and (not (not v79 or not v79()) or v79 == nil) and not v83 then
                local v87 = (os.clock() - v84) / v77;
                v78(v87, v86, Lerp(1, 0, v87), os.clock() - v84);
            else
                v82:Disconnect();
                if v78 and v83 then
                    v78(1, v86, 0, v77);
                end;
                if v80 then
                    v80(1, v86, 0);
                end;
            end;
            v85 = false;
        end;
    end);
    return v82;
end;
v2.UnixWithFrequency = function(_, v89, v90, v91, v92)
    local v93 = os.clock();
    local v94 = nil;
    v94 = if l_RunService_0:IsServer() then l_RunService_0.Heartbeat else l_RunService_0.RenderStepped;
    local l_v93_0 = v93;
    local v96 = nil;
    v96 = v94:Connect(function(_)
        local v98 = os.clock() - l_v93_0;
        if v90 < v98 then
            l_v93_0 = os.clock();
            v91((os.clock() - v93) / v89, v98);
        end;
        if v96 and v89 < os.clock() - v93 then
            v96:Disconnect();
            v96 = nil;
            if v92 then
                v92(1, v98);
            end;
        end;
    end);
end;
local _ = nil;
(if l_RunService_0:IsServer() then l_RunService_0.Heartbeat else l_RunService_0.RenderStepped):Connect(function(v100)
    for _, v102 in pairs(v3) do
        v102(v100);
    end;
    for _, v104 in pairs(v4) do
        if v104.callback(v100) then
            table.remove(v4, table.find(v4, v104));
        end;
    end;
end);
return v2;