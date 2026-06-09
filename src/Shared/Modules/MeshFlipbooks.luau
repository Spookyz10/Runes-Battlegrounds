-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

local l_TweenService_0 = game:GetService("TweenService");
local l_Thrown_0 = game.Workspace.Thrown;
local l_RunService_0 = game:GetService("RunService");
local v3 = {};
v3.new = function(v4) --[[ Line: 13 ]] --[[ Name: new ]]
    local v5 = setmetatable({}, v3);
    v5.start = not v4 and tick() or nil;
    v5.freezeStart = nil;
    v5.freezeTimeSubtract = 0;
    return v5;
end;
v3.GetTimePassed = function(v6) --[[ Line: 22 ]] --[[ Name: GetTimePassed ]]
    return tick() - v6;
end;
v3.Reset = function(v7) --[[ Line: 27 ]] --[[ Name: Reset ]]
    v7.start = tick();
    v7.freezeStart = nil;
    v7.freezeTimeSubtract = 0;
end;
v3.UpdateFreezeTimeSub = function(v8) --[[ Line: 34 ]] --[[ Name: UpdateFreezeTimeSub ]]
    local l_freezeStart_0 = v8.freezeStart;
    if not l_freezeStart_0 then
        return false;
    else
        v8.freezeTimeSubtract = v8.freezeTimeSubtract + v3.GetTimePassed(l_freezeStart_0);
        v8.freezeStart = tick();
        return true;
    end;
end;
v3.Freeze = function(v10) --[[ Line: 45 ]] --[[ Name: Freeze ]]
    if v10:UpdateFreezeTimeSub() then
        return;
    else
        v10.freezeStart = tick();
        return;
    end;
end;
v3.Unfreeze = function(v11) --[[ Line: 54 ]] --[[ Name: Unfreeze ]]
    v11:UpdateFreezeTimeSub();
    v11.freezeStart = nil;
end;
v3.HasPassedTime = function(v12, v13, v14) --[[ Line: 60 ]] --[[ Name: HasPassedTime ]]
    if not v12.start or v13 <= v12() then
        if not v14 then
            v12:Reset();
        end;
        return true;
    else
        return false;
    end;
end;
v3.GetStopwatchTime = function(v15) --[[ Line: 72 ]] --[[ Name: GetStopwatchTime ]]
    local v16 = tick();
    v15.start = v15.start or v16;
    v15:UpdateFreezeTimeSub();
    return v3.GetTimePassed(v15.start) - v15.freezeTimeSubtract;
end;
v3.GetAlpha = function(v17, v18, v19, v20) --[[ Line: 81 ]] --[[ Name: GetAlpha ]]
    v20 = v20 or 0;
    local v21 = (v17() + v20) / v18;
    if v19 then
        return v21;
    else
        return (math.clamp(v21, 0, 1));
    end;
end;
v3.newTimer = function(v22, v23, v24) --[[ Line: 90 ]] --[[ Name: newTimer ]]
    v24 = v24 or 0;
    local v25 = v3.new();
    local v26 = v3.new();
    while not v25:HasPassedTime(v22 + v24, true) and not v23(v25:GetAlpha(v22, nil, v24), v25(), v26()) do
        v26:Reset();
        l_RunService_0.Heartbeat:Wait();
    end;
end;
v3.__index = v3;
v3.__call = function(v27) --[[ Line: 106 ]]
    return v27:GetStopwatchTime();
end;
local v30 = {
    Random = function(v28, v29) --[[ Line: 114 ]] --[[ Name: Random ]]
        return Random.new():NextNumber(v28 or 0.8, v29 or 1.2);
    end, 
    RandomReverseMutlipler = function() --[[ Line: 119 ]] --[[ Name: RandomReverseMutlipler ]]
        if math.random(0, 1) == 1 then
            return 1;
        else
            return -1;
        end;
    end
};
v30.RandomRotation = function() --[[ Line: 124 ]] --[[ Name: RandomRotation ]]
    return v30.Random(-6.283185307179586, 6.283185307179586);
end;
v30.Round = function(v31, v32) --[[ Line: 129 ]] --[[ Name: Round ]]
    v32 = v32 or 0;
    local v33 = math.round(v31 * 10 ^ v32) * 10 ^ (-v32);
    return (tonumber(string.format("%." .. v32 .. "f", v33)));
end;
v30.NumberToVector3 = function(v34) --[[ Line: 137 ]] --[[ Name: NumberToVector3 ]]
    return (Vector3.new(v34, v34, v34));
end;
v30.ScaleValue = function(v35, v36, v37) --[[ Line: 141 ]] --[[ Name: ScaleValue ]]
    local v38 = {};
    local function _(v39) --[[ Line: 144 ]] --[[ Name: multiplyScaleValue ]]
        return v37 * v39 / v35;
    end;
    v38.NumberSequence = function() --[[ Line: 147 ]] --[[ Name: NumberSequence ]]
        local v41 = {};
        for v42, v43 in pairs(v36.Keypoints) do
            local l_new_0 = NumberSequenceKeypoint.new;
            local l_Time_0 = v43.Time;
            local l_Value_0 = v43.Value;
            local v47 = v37 * l_Value_0 / v35;
            local l_Envelope_0 = v43.Envelope;
            v41[v42] = l_new_0(l_Time_0, v47, v37 * l_Envelope_0 / v35);
        end;
        return NumberSequence.new(v41);
    end;
    v38.NumberRange = function() --[[ Line: 155 ]] --[[ Name: NumberRange ]]
        local l_new_1 = NumberRange.new;
        local l_Min_0 = v36.Min;
        local v51 = v37 * l_Min_0 / v35;
        local l_Max_0 = v36.Max;
        return l_new_1(v51, v37 * l_Max_0 / v35);
    end;
    v38.Default = function() --[[ Line: 162 ]] --[[ Name: Default ]]
        return v37 * v36 / v35;
    end;
    return (v38[typeof(v36)] or v38.Default)();
end;
v30.GetRootScaleValues = function(v53) --[[ Line: 169 ]] --[[ Name: GetRootScaleValues ]]
    return Vector3.new(2, 2, 1, 0).Magnitude, v53.Magnitude;
end;
v30.GetLargestAxis = function(v54) --[[ Line: 173 ]] --[[ Name: GetLargestAxis ]]
    local v55 = {
        size = v54.X, 
        name = "X"
    };
    local function _(v56) --[[ Line: 175 ]] --[[ Name: checkLargest ]]
        local v57 = v54[v56];
        if v55.size <= v57 then
            v55.size = v57;
            v55.name = v56;
        end;
    end;
    local l_Y_0 = v54.Y;
    if v55.size <= l_Y_0 then
        v55.size = l_Y_0;
        v55.name = "Y";
    end;
    l_Y_0 = v54.Z;
    if v55.size <= l_Y_0 then
        v55.size = l_Y_0;
        v55.name = "Z";
    end;
    return v55.size, v55.name;
end;
v30.SineBetween = function(v60, v61, v62, v63, v64) --[[ Line: 187 ]] --[[ Name: SineBetween ]]
    return ((v61 - v62) * math.sin(v60 * v63 + v64) + v61 + v62) / 2;
end;
local v65 = {};
v65.__index = v65;
v65.new = function(v66, v67) --[[ Line: 202 ]] --[[ Name: new ]]
    local v68 = setmetatable({}, v65);
    v68.ImageObject = v66;
    v68.TextureParamName = v67 or "Texture";
    return v68;
end;
v65.Play = function(v69, v70, v71, v72, v73) --[[ Line: 220 ]] --[[ Name: Play ]]
    local v74 = v3.new();
    local function _() --[[ Line: 223 ]] --[[ Name: setNewTexture ]]
        local v75 = v74() / v71;
        if v72 then
            v75 = v72(v75);
        end;
        v69.ImageObject[v69.TextureParamName] = v65.GetTextureFromAlpha(v70, v75);
    end;
    task.spawn(function() --[[ Line: 231 ]]
        while not v74:HasPassedTime(v71) do
            local v77 = v74() / v71;
            if v72 then
                v77 = v72(v77);
            end;
            v69.ImageObject[v69.TextureParamName] = v65.GetTextureFromAlpha(v70, v77);
            task.wait();
        end;
        if v73 then
            v69:Delete();
        end;
    end);
end;
v65.Delete = function(v78) --[[ Line: 245 ]] --[[ Name: Delete ]]
    for v79, _ in v78 do
        v78[v79] = nil;
    end;
end;
v65.GetTextureFromAlpha = function(v81, v82) --[[ Line: 257 ]] --[[ Name: GetTextureFromAlpha ]]
    local v83 = #v81;
    return v81[math.clamp(math.round(v82 * v83), 1, v83)];
end;
v65.SetTextureFromAlpha = function(v84, v85, v86) --[[ Line: 270 ]] --[[ Name: SetTextureFromAlpha ]]
    v84.ImageObject[v84.TextureParamName] = v65.GetTextureFromAlpha(v85, v86);
end;
local v87 = {
    Wind0 = {
        [1] = "rbxassetid://11461678568", 
        [2] = "rbxassetid://11461678488", 
        [3] = "rbxassetid://11461678409", 
        [4] = "rbxassetid://11461678313", 
        [5] = "rbxassetid://11461678244", 
        [6] = "rbxassetid://11461675803", 
        [7] = "rbxassetid://11461675738", 
        [8] = "rbxassetid://11461675605", 
        [9] = "rbxassetid://11461675546", 
        [10] = "rbxassetid://11461675422", 
        [11] = "rbxassetid://11461675356"
    }, 
    Wind1 = {
        "rbxassetid://12709087413", 
        "rbxassetid://12709089414", 
        "rbxassetid://12709091338", 
        "rbxassetid://12709052082", 
        "rbxassetid://12709051925", 
        "rbxassetid://12709051840", 
        "rbxassetid://12709046645", 
        "rbxassetid://12709046514", 
        "rbxassetid://12709046410", 
        "rbxassetid://12709046344", 
        "rbxassetid://12709046207", 
        "rbxassetid://12709046012", 
        "rbxassetid://12709041406", 
        "rbxassetid://12709041294", 
        "rbxassetid://12709041173", 
        "rbxassetid://12709041095", 
        "rbxassetid://12709040977", 
        "rbxassetid://12709040841", 
        "rbxassetid://12709035460", 
        "rbxassetid://12709035361", 
        "rbxassetid://12709035226", 
        "rbxassetid://12709035099", 
        "rbxassetid://12709034940", 
        "rbxassetid://12709034804", 
        "rbxassetid://12709029886", 
        "rbxassetid://12709029739", 
        "rbxassetid://12709029558", 
        "rbxassetid://12709029448", 
        "rbxassetid://12709029377", 
        "rbxassetid://12709029200"
    }, 
    Wind2 = {
        [1] = "rbxassetid://13470338298", 
        [2] = "rbxassetid://13470338205", 
        [3] = "rbxassetid://13470338069", 
        [4] = "rbxassetid://13470337936", 
        [5] = "rbxassetid://13470337799", 
        [6] = "rbxassetid://13470337705", 
        [7] = "rbxassetid://13470337605", 
        [8] = "rbxassetid://13470337504", 
        [9] = "rbxassetid://13470337307", 
        [10] = "rbxassetid://13470337065", 
        [11] = "rbxassetid://13470336871", 
        [12] = "rbxassetid://13470336729", 
        [13] = "rbxassetid://13470336566", 
        [14] = "rbxassetid://13470336437", 
        [15] = "rbxassetid://13470336294", 
        [16] = "rbxassetid://13470336113", 
        [17] = "rbxassetid://13470336008", 
        [18] = "rbxassetid://13470335851", 
        [19] = "rbxassetid://13470335752", 
        [20] = "rbxassetid://13470335638"
    }, 
    Wind3 = {
        [1] = "rbxassetid://15583581350", 
        [2] = "rbxassetid://15583581268", 
        [3] = "rbxassetid://15583581163", 
        [4] = "rbxassetid://15583581073", 
        [5] = "rbxassetid://15583580947", 
        [6] = "rbxassetid://15583580830", 
        [7] = "rbxassetid://15583580724", 
        [8] = "rbxassetid://15583580608", 
        [9] = "rbxassetid://15583580488", 
        [10] = "rbxassetid://15583580288", 
        [11] = "rbxassetid://15583580138", 
        [12] = "rbxassetid://15583580039", 
        [13] = "rbxassetid://15583579925", 
        [14] = "rbxassetid://15583579776", 
        [15] = "rbxassetid://15583579583", 
        [16] = "rbxassetid://15583579386", 
        [17] = "rbxassetid://15583579213", 
        [18] = "rbxassetid://15583579007", 
        [19] = "rbxassetid://15583578841", 
        [20] = "rbxassetid://15583578616", 
        [21] = "rbxassetid://15583578452", 
        [22] = "rbxassetid://15583578183"
    }, 
    DiceyWind0 = {
        [1] = "rbxassetid://13769737333", 
        [2] = "rbxassetid://13769737186", 
        [3] = "rbxassetid://13769737005", 
        [4] = "rbxassetid://13769736812", 
        [5] = "rbxassetid://13769759577", 
        [6] = "rbxassetid://13769736174", 
        [7] = "rbxassetid://13769735915", 
        [8] = "rbxassetid://13769735699", 
        [9] = "rbxassetid://13769735432", 
        [10] = "rbxassetid://13769735245", 
        [11] = "rbxassetid://13769734982"
    }, 
    Slash0 = {
        [1] = "rbxassetid://13204898262", 
        [2] = "rbxassetid://13204897736", 
        [3] = "rbxassetid://13204897313", 
        [4] = "rbxassetid://13204896833", 
        [5] = "rbxassetid://13204896227", 
        [6] = "rbxassetid://13204895744", 
        [7] = "rbxassetid://13204895210", 
        [8] = "rbxassetid://13204894750", 
        [9] = "rbxassetid://13204894286", 
        [10] = "rbxassetid://13204893811", 
        [11] = "rbxassetid://13204893290", 
        [12] = "rbxassetid://13204892795", 
        [13] = "rbxassetid://13204892226", 
        [14] = "rbxassetid://13204891702", 
        [15] = "rbxassetid://13204891035", 
        [16] = "rbxassetid://13204890584", 
        [17] = "rbxassetid://13204890049", 
        [18] = "rbxassetid://13204889468", 
        [19] = "rbxassetid://13204888992"
    }, 
    SlashWind0 = {
        "rbxassetid://14127444698", 
        "rbxassetid://14127393320", 
        "rbxassetid://14127393204", 
        "rbxassetid://14127393113", 
        "rbxassetid://14127392987", 
        "rbxassetid://14127392831", 
        "rbxassetid://14127392695", 
        "rbxassetid://14127392572", 
        "rbxassetid://14127392433", 
        "rbxassetid://14127392308", 
        "rbxassetid://14127448226", 
        "rbxassetid://14127392018", 
        "rbxassetid://14127391892"
    }, 
    UpLines0 = {
        [1] = "rbxassetid://14334428426", 
        [2] = "rbxassetid://14334428426", 
        [3] = "rbxassetid://14334428243", 
        [4] = "rbxassetid://14334428107", 
        [5] = "rbxassetid://14334427908", 
        [6] = "rbxassetid://14334427593", 
        [7] = "rbxassetid://14334427593", 
        [8] = "rbxassetid://14334427409", 
        [9] = "rbxassetid://14334427313", 
        [10] = "rbxassetid://14334427189", 
        [11] = "rbxassetid://14334427002", 
        [12] = "rbxassetid://14334427002", 
        [13] = "rbxassetid://14334426739", 
        [14] = "rbxassetid://14334426626"
    }, 
    UpLines1 = {
        "rbxassetid://16349253150", 
        "rbxassetid://16349253003", 
        "rbxassetid://16349252865", 
        "rbxassetid://16349252630", 
        "rbxassetid://16349252435", 
        "rbxassetid://16349252319", 
        "rbxassetid://16349252232", 
        "rbxassetid://16349252127", 
        "rbxassetid://16349251934", 
        "rbxassetid://16349251721", 
        "rbxassetid://16349251510", 
        "rbxassetid://16349251398", 
        "rbxassetid://16349251243", 
        "rbxassetid://16349251093", 
        "rbxassetid://16349250958"
    }, 
    DotDissolve = {
        [1] = "rbxassetid://15494257040", 
        [2] = "rbxassetid://15494256947", 
        [3] = "rbxassetid://15494256825", 
        [4] = "rbxassetid://15494254516", 
        [5] = "rbxassetid://15494254445", 
        [6] = "rbxassetid://15494254370", 
        [7] = "rbxassetid://15494254273", 
        [8] = "rbxassetid://15494254222", 
        [9] = "rbxassetid://15494254167", 
        [10] = "rbxassetid://15494254118", 
        [11] = "rbxassetid://15494254073", 
        [12] = "rbxassetid://15494254030", 
        [13] = "rbxassetid://15494253978", 
        [14] = "rbxassetid://15494253921", 
        [15] = "rbxassetid://15494253857", 
        [16] = "rbxassetid://15494253812", 
        [17] = "rbxassetid://15494253754", 
        [18] = "rbxassetid://15494253685", 
        [19] = "rbxassetid://15494253626", 
        [20] = "rbxassetid://15494253569", 
        [21] = "rbxassetid://15494253511", 
        [22] = "rbxassetid://15494253430", 
        [23] = "rbxassetid://15494253331", 
        [24] = "rbxassetid://15494253331", 
        [25] = "rbxassetid://15494253227", 
        [26] = "rbxassetid://15494285181", 
        [27] = "rbxassetid://15494289522", 
        [28] = "rbxassetid://15494253021", 
        [29] = "rbxassetid://15494252936"
    }, 
    SphereWind0 = {
        "rbxassetid://15117059121", 
        "rbxassetid://15117060921", 
        "rbxassetid://15117061899", 
        "rbxassetid://15117062959", 
        "rbxassetid://15117062959", 
        "rbxassetid://15117065207", 
        "rbxassetid://15117066547", 
        "rbxassetid://15117067537"
    }
};
v87.__index = v87;
v87.new = function(v88, v89, v90, v91, v92, v93) --[[ Line: 502 ]] --[[ Name: new ]]
    local v94 = setmetatable({}, v87);
    v92 = v92 or Vector3.new(0.5, 0);
    v93 = v93 or Color3.fromRGB(330, 510, 498);
    local v95 = game.ReplicatedStorage.Resources.Suiryu.TwinFangs.FlipbookMeshes[v88]:Clone();
    local l_Mesh_0 = v95.Mesh;
    local l_Decal_0 = v95.Decal;
    local l_CFrameValue_0 = Instance.new("CFrameValue");
    local function v101() --[[ Line: 511 ]] --[[ Name: updateCF ]]
        local l_WeldPart_0 = v94.WeldPart;
        local l_Value_1 = l_CFrameValue_0.Value;
        v95.CFrame = if l_WeldPart_0 then l_WeldPart_0.CFrame:ToWorldSpace(l_Value_1) else l_Value_1;
    end;
    local v105 = v90 and v90.Changed:Connect(function(v102) --[[ Line: 518 ]]
        if v102 ~= "CFrame" then
            return;
        else
            local l_WeldPart_1 = v94.WeldPart;
            local l_Value_2 = l_CFrameValue_0.Value;
            v95.CFrame = if l_WeldPart_1 then l_WeldPart_1.CFrame:ToWorldSpace(l_Value_2) else l_Value_2;
            return;
        end;
    end);
    l_CFrameValue_0.Changed:Connect(v101);
    local v106 = v65.new(l_Decal_0);
    v94.Part = v95;
    v94.Mesh = l_Mesh_0;
    v94.Decal = l_Decal_0;
    v94.Flipbook = v106;
    v94.Textures = v89;
    v94.CFValue = l_CFrameValue_0;
    v94.WeldPart = v90;
    v94.WeldPartStartCF = v90 and v90.CFrame;
    v94.WeldUpdate = v105;
    l_Mesh_0.Scale = v92;
    l_Decal_0.Color3 = v93;
    l_CFrameValue_0.Value = v94:ConvertCFrame(v91);
    v95.Parent = l_Thrown_0;
    v94:SetTextureFromAlpha(0);
    return v94;
end;
v87.Tween = function(v107, v108, v109, v110, v111) --[[ Line: 547 ]] --[[ Name: Tween ]]
    local v112 = l_TweenService_0:Create(v107[v108], v109, v110);
    if not v111 then
        v112:Play();
    end;
    return v112;
end;
v87.TweenDecal = function(v113, v114, v115, v116) --[[ Line: 555 ]] --[[ Name: TweenDecal ]]
    return v113:Tween("Decal", v114, v115, v116);
end;
v87.TweenPart = function(v117, v118, v119, v120) --[[ Line: 559 ]] --[[ Name: TweenPart ]]
    return v117:Tween("Part", v118, v119, v120);
end;
v87.TweenMesh = function(v121, v122, v123, v124) --[[ Line: 563 ]] --[[ Name: TweenMesh ]]
    return v121:Tween("Mesh", v122, v123, v124);
end;
v87.TweenTransparency = function(v125, v126, v127, v128) --[[ Line: 567 ]] --[[ Name: TweenTransparency ]]
    return v125:TweenDecal(v127, {
        Transparency = v126
    }, v128);
end;
v87.TweenCFrame = function(v129, v130, v131, v132) --[[ Line: 571 ]] --[[ Name: TweenCFrame ]]
    return v129:Tween("CFValue", v131, {
        Value = v129:ConvertCFrame(v130)
    }, v132);
end;
v87.SetTransparency = function(v133, v134) --[[ Line: 576 ]] --[[ Name: SetTransparency ]]
    v133.Decal.Transparency = v134;
end;
v87.SetCFrame = function(v135, v136) --[[ Line: 580 ]] --[[ Name: SetCFrame ]]
    local v137 = v135:ConvertCFrame(v136);
    v135.CFValue.Value = v137;
end;
v87.ConvertCFrame = function(v138, v139) --[[ Line: 585 ]] --[[ Name: ConvertCFrame ]]
    local l_WeldPart_2 = v138.WeldPart;
    local _ = nil;
    if l_WeldPart_2 then
        return (v138.WeldPartStartCF:ToObjectSpace(v139));
    else
        return v139;
    end;
end;
v87.TweenSize = function(v142, v143, v144, v145) --[[ Line: 596 ]] --[[ Name: TweenSize ]]
    return v142:TweenMesh(v144, {
        Scale = v143
    }, v145);
end;
v87.Play = function(v146, v147, v148, v149, v150) --[[ Line: 600 ]] --[[ Name: Play ]]
    v146.WeldPartStartCF = v146.WeldPart and v146.WeldPart.CFrame;
    v146.Flipbook:Play(v146.Textures or v150, v147, v148, true);
    if not v149 then
        task.delay(v147, function() --[[ Line: 604 ]]
            v146:Destroy();
        end);
    end;
end;
v87.SetTextureFromAlpha = function(v151, v152) --[[ Line: 610 ]] --[[ Name: SetTextureFromAlpha ]]
    v151.Flipbook:SetTextureFromAlpha(v151.Textures, v152);
end;
v87.Destroy = function(v153) --[[ Line: 614 ]] --[[ Name: Destroy ]]
    v153.CFValue:Destroy();
    v153.Part:Destroy();
    if v153.WeldUpdate then
        v153.WeldUpdate:Disconnect();
    end;
    for v154, _ in v153 do
        v153[v154] = nil;
    end;
end;
v87.LoadSphereFlipbook = function(...) --[[ Line: 626 ]] --[[ Name: LoadSphereFlipbook ]]
    return v87.LoadFlipbook("Sphere", ...);
end;
v87.CreateWind0Flipbook = function(...) --[[ Line: 630 ]] --[[ Name: CreateWind0Flipbook ]]
    return v87.new("Cone", v87.Wind0, ...);
end;
v87.CreateWind1Flipbook = function(...) --[[ Line: 634 ]] --[[ Name: CreateWind1Flipbook ]]
    return v87.new("Sphere", v87.Wind1, ...);
end;
v87.CreateWind2Flipbook = function(...) --[[ Line: 638 ]] --[[ Name: CreateWind2Flipbook ]]
    return v87.new("Sphere", v87.Wind2, ...);
end;
v87.CreateWind3Flipbook = function(...) --[[ Line: 642 ]] --[[ Name: CreateWind3Flipbook ]]
    return v87.new("Sphere", v87.Wind3, ...);
end;
v87.CreateDiceyWindFlipbook = function(...) --[[ Line: 647 ]] --[[ Name: CreateDiceyWindFlipbook ]]
    return v87.new("Sphere", v87.DiceyWind0, ...);
end;
v87.CreateSlashWind0Flippbok = function(...) --[[ Line: 651 ]] --[[ Name: CreateSlashWind0Flippbok ]]
    return v87.new("Sphere", v87.SlashWind0, ...);
end;
v87.CreateAnimatedWind = function(v156, v157, v158, v159, v160, v161, v162) --[[ Line: 655 ]] --[[ Name: CreateAnimatedWind ]]
    local v163 = v156 * CFrame.Angles(0, v30.RandomRotation(), 0) * CFrame.new(0, v158, 0);
    local v164 = (v161 or v87.CreateWind2Flipbook)(nil, v163, Vector3.new(0, v157.Y, 0), Color3.new(1, 1, 1));
    v164:Play(v160);
    v164:TweenSize(v157, TweenInfo.new(v160, Enum.EasingStyle.Cubic));
    v164:SetTransparency(v162 or 0.95);
    v164:TweenCFrame(v163 * CFrame.Angles(0, 1.5707963267948966 * v30.RandomReverseMutlipler(), 0) * CFrame.new(0, v159, 0), TweenInfo.new(v160));
    return v164;
end;
return v87;