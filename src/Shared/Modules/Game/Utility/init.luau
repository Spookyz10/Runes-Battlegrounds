local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
local v2 = require(l_ReplicatedStorage_0.Modules.Game.Job);
local v3 = {
    Faces = {
        [Enum.NormalId.Front] = Vector3.new(-0, -0, -1, -0), 
        [Enum.NormalId.Back] = Vector3.new(0, 0, 1, 0), 
        [Enum.NormalId.Top] = Vector3.new(0, 1, 0, 0), 
        [Enum.NormalId.Bottom] = Vector3.new(-0, -1, -0, -0), 
        [Enum.NormalId.Left] = Vector3.new(-1, -0, -0, -0), 
        [Enum.NormalId.Right] = Vector3.new(1, 0, 0, 0)
    }, 
    ControllerToKeyboardInputs = {
        [Enum.KeyCode.ButtonA] = Enum.KeyCode.Space, 
        [Enum.KeyCode.ButtonY] = Enum.KeyCode.Q, 
        [Enum.KeyCode.ButtonB] = Enum.UserInputType.MouseButton1, 
        [Enum.KeyCode.ButtonX] = Enum.KeyCode.F, 
        [Enum.KeyCode.ButtonL1] = Enum.KeyCode.One, 
        [Enum.KeyCode.ButtonL2] = Enum.KeyCode.Two, 
        [Enum.KeyCode.ButtonR1] = Enum.KeyCode.Three, 
        [Enum.KeyCode.ButtonR2] = Enum.KeyCode.Four, 
        [Enum.KeyCode.DPadRight] = Enum.KeyCode.Five, 
        [Enum.KeyCode.DPadUp] = Enum.KeyCode.G, 
        [Enum.KeyCode.DPadLeft] = Enum.KeyCode.R
    }, 
    KeyboardToControllerInputs = {
        [Enum.KeyCode.Space] = Enum.KeyCode.ButtonA, 
        [Enum.KeyCode.Q] = Enum.KeyCode.ButtonY, 
        [Enum.UserInputType.MouseButton1] = Enum.KeyCode.ButtonB, 
        [Enum.KeyCode.F] = Enum.KeyCode.ButtonX, 
        [Enum.KeyCode.One] = Enum.KeyCode.ButtonL1, 
        [Enum.KeyCode.Two] = Enum.KeyCode.ButtonL2, 
        [Enum.KeyCode.Three] = Enum.KeyCode.ButtonR1, 
        [Enum.KeyCode.Four] = Enum.KeyCode.ButtonR2, 
        [Enum.KeyCode.Five] = Enum.KeyCode.DPadRight, 
        [Enum.KeyCode.G] = Enum.KeyCode.DPadUp, 
        [Enum.KeyCode.R] = Enum.KeyCode.DPadLeft
    }, 
    Seed = Random.new(), 
    FullCircle = 6.283185307179586, 
    ShiftlockRenderPriority = Enum.RenderPriority.Camera.Value + 1, 
    CharacterRenderPriority = Enum.RenderPriority.Camera.Value + 2, 
    GroundParams = RaycastParams.new()
};
v3.VisualParams = RaycastParams.new();
v3.VisualParams.FilterType = Enum.RaycastFilterType.Include;

local l_Map_0 = workspace:FindFirstChild("Map");

if l_Map_0 then
    v3.VisualParams.FilterDescendantsInstances = {
        l_Map_0
    };
end;

v3.DestructionRespawnTime = 20;
if l_RunService_0:IsClient() then
    local l_UserGameSettings_0 = UserSettings():GetService("UserGameSettings");
    local v15 = 10;
    local l_l_UserGameSettings_0_0 = l_UserGameSettings_0 --[[ copy: 9 -> 13 ]];
    do
        local l_v15_0 = v15;
        local function v19() --[[ Line: 133 ]] --[[ Name: Upd ]]
            -- upvalues: l_l_UserGameSettings_0_0 (copy), l_v15_0 (ref)
            local l_SavedQualityLevel_0 = l_l_UserGameSettings_0_0.SavedQualityLevel;
            l_v15_0 = l_SavedQualityLevel_0 == Enum.SavedQualitySetting.Automatic and l_v15_0 / 2 or l_SavedQualityLevel_0.Value;
        end;
        l_UserGameSettings_0:GetPropertyChangedSignal("SavedQualityLevel"):Connect(v19);
        local l_SavedQualityLevel_1 = l_UserGameSettings_0.SavedQualityLevel;
        l_v15_0 = l_SavedQualityLevel_1 == Enum.SavedQualitySetting.Automatic and l_v15_0 / 2 or l_SavedQualityLevel_1.Value;
        v3.GetQuality = function() --[[ Line: 141 ]] --[[ Name: GetQuality ]]
            -- upvalues: l_v15_0 (ref)
            return l_v15_0;
        end;
    end;
end;
v3.CloseThreadSafe = function(v21) --[[ Line: 146 ]] --[[ Name: CloseThreadSafe ]]
    if v21 ~= nil and coroutine.status(v21) == "suspended" then
        task.cancel(v21);
    end;
end;
v3.biDirRandom = function(v22) --[[ Line: 152 ]] --[[ Name: biDirRandom ]]
    return v22 - math.random() * v22 * 2;
end;
v3.QuadBezier = function(v23, v24, v25, v26) --[[ Line: 156 ]] --[[ Name: QuadBezier ]]
    local v27 = 1 - v23;
    return v27 ^ 2 * v24 + v27 * 2 * v23 * v25 + v23 ^ 2 * v26;
end;
v3.WithinTime = function(v28, v29) --[[ Line: 162 ]] --[[ Name: WithinTime ]]
    local v30 = true;
    if v28 ~= -1 then
        v30 = time() - v28 < v29;
    end;
    return v30;
end;
v3.BeyondTime = function(v31, v32) --[[ Line: 166 ]] --[[ Name: BeyondTime ]]
    local v33 = true;
    if v31 ~= -1 then
        v33 = v32 < time() - v31;
    end;
    return v33;
end;
v3.NumberRangeRandom = function(v34) --[[ Line: 170 ]] --[[ Name: NumberRangeRandom ]]
    -- upvalues: v3 (copy)
    return v3.Seed:NextNumber(v34.Min, v34.Max);
end;
v3.BetweenNumberRange = function(v35, v36) --[[ Line: 174 ]] --[[ Name: BetweenNumberRange ]]
    local v37 = true;
    if v36 >= v35.Min then
        v37 = v35.Max < v36;
    end;
    return not v37;
end;
v3.XOR = function(v38, v39) --[[ Line: 178 ]] --[[ Name: XOR ]]
    return not v38 and v39 or v38 and not v39;
end;
v3.DecimalRound = function(v40, v41) --[[ Line: 182 ]] --[[ Name: DecimalRound ]]
    local v42 = 10 ^ (v41 or 1);
    return math.round(v40 * v42) / v42;
end;
v3.GetTotalWeight = function(v43) --[[ Line: 188 ]] --[[ Name: GetTotalWeight ]]
    local v44 = 0;
    for _, v46 in ipairs(v43) do
        v44 = v44 + v46:GetAttribute("Weight");
    end;
    return v44;
end;
v3.GetRandomByWeight = function(v47) --[[ Line: 198 ]] --[[ Name: GetRandomByWeight ]]
    -- upvalues: v3 (copy)
    local v48 = v3.GetTotalWeight(v47);
    local v49 = math.random(0, v48);
    for _, v51 in ipairs(v47) do
        v48 = v48 - v51:GetAttribute("Weight");
        if v48 <= v49 then
            return v51;
        end;
    end;
    return nil;
end;
v3.AlphaClamp = function(v52) --[[ Line: 213 ]] --[[ Name: AlphaClamp ]]
    return (math.clamp(v52, 0, 1));
end;
v3.InterpolateNumberSequenceValues = function(v53, v54, v55) --[[ Line: 217 ]] --[[ Name: InterpolateNumberSequenceValues ]]
    local v56 = table.create(#v53.Keypoints);
    for v57, v58 in ipairs(v53.Keypoints) do
        v56[v57] = NumberSequenceKeypoint.new(v58.Time, v58.Value + (v55 - v58.Value) * v54, v58.Envelope);
    end;
    return NumberSequence.new(v56);
end;
v3.VectorToRotation = function(v59) --[[ Line: 231 ]] --[[ Name: VectorToRotation ]]
    return CFrame.lookAt(Vector3.new(0, 0, 0, 0), v59);
end;
v3.RaycastWithDebug = function(v60, v61, v62) --[[ Line: 235 ]] --[[ Name: RaycastWithDebug ]]
    local v63 = workspace:Raycast(v60, v61, v62);
    local l_ConeHandleAdornment_0 = Instance.new("ConeHandleAdornment");
    l_ConeHandleAdornment_0.CFrame = CFrame.lookAlong(v60, v61);
    l_ConeHandleAdornment_0.Height = v61.Magnitude;
    l_ConeHandleAdornment_0.Radius = 0.25;
    l_ConeHandleAdornment_0.Transparency = 0.5;
    l_ConeHandleAdornment_0.Color3 = Color3.new();
    l_ConeHandleAdornment_0.Adornee = workspace.Terrain;
    l_ConeHandleAdornment_0.Parent = workspace.Terrain;
    task.delay(12, l_ConeHandleAdornment_0.Destroy, l_ConeHandleAdornment_0);
    return v63;
end;
v3.CaseSplit = function(v65, v66, v67) --[[ Line: 252 ]] --[[ Name: CaseSplit ]]
    local v68 = 0;
    local v69 = {};
    local v70 = {};
    local v71 = 1;
    for v72 = 1, #v65 do
        local v73 = string.sub(v65, v72, v72);
        if v67 == v73 then
            if #v69 == 0 then
                table.insert(v69, v73);
                v71 = 2;
            else
                table.remove(v69, #v69);
            end;
        end;
        if #v69 == 0 and v73 == v66 then
            table.insert(v70, (string.sub(v65, v68 + v71, v72 - v71)));
            v71 = 1;
            v68 = v72;
        end;
    end;
    table.insert(v70, (string.sub(v65, v68 + v71, -v71)));
    return v70;
end;
v3.PickRandom = function(v74, v75) --[[ Line: 284 ]] --[[ Name: PickRandom ]]
    local v76 = nil;
    local v77 = -1;
    local v78 = math.random(1, #v74);
    while v77 <= #v74 do
        v77 = v77 + 1;
        v76 = v74[(v78 + v77) % #v74 + 1];
        if v75(v76) then
            break;
        end;
    end;
    if v77 <= #v74 then
        return v76;
    else
        return nil;
    end;
end;
v3.TableCount = function(v79) --[[ Line: 305 ]] --[[ Name: TableCount ]]
    local v80 = 0;
    for _ in pairs(v79) do
        v80 = v80 + 1;
    end;
    return v80;
end;
v3.DeepCopy = function(v82) --[[ Line: 315 ]] --[[ Name: DeepCopy ]]
    -- upvalues: v3 (copy)
    assert(typeof(v82) == "table", "t is not a table");
    local v83 = {};
    for v84, v85 in v82 do
        if typeof(v85) == "table" then
            v83[v84] = v3.DeepCopy(v85);
        else
            v83[v84] = v85;
        end;
    end;
    return v83;
end;
v3.StopAutoRotate = function(v86, v87) --[[ Line: 331 ]] --[[ Name: StopAutoRotate ]]
    local l_Configuration_0 = Instance.new("Configuration");
    l_Configuration_0.Name = "StopAutoRotate";
    if v87 then
        l_Configuration_0:AddTag(v87);
    end;
    l_Configuration_0.Parent = v86;
    return l_Configuration_0;
end;
v3.BindSignalDisconnectToInstanceDestroying = function(v89, v90, v91) --[[ Line: 344 ]] --[[ Name: BindSignalDisconnectToInstanceDestroying ]]
    -- upvalues: v2 (copy)
    local v92 = v2.new();
    local function v93() --[[ Line: 347 ]] --[[ Name: DeleteWhen ]]
        -- upvalues: v90 (copy), v92 (copy)
        if v90.Parent == nil then
            v92:Destroy();
        end;
    end;
    task.defer(v93);
    v92:Task(v90:GetPropertyChangedSignal("Parent"):Connect(v93));
    v92:Task(v89:Connect(v91));
    return v92;
end;
v3.IsNumberKey = function(v94) --[[ Line: 360 ]] --[[ Name: IsNumberKey ]]
    local v95 = false;
    if v94.Value >= 48 then
        v95 = v94.Value <= 57;
    end;
    return v95;
end;
v3.GetNumberKeyFromNumber = function(v96) --[[ Line: 364 ]] --[[ Name: GetNumberKeyFromNumber ]]
    -- upvalues: v3 (copy)
    local v97 = Enum.KeyCode:FromValue(v96 + 48);
    if v97 == nil or not v3.IsNumberKey(v97) then
        return nil;
    else
        return v97;
    end;
end;
v3.TranslateInput = function(v98) --[[ Line: 374 ]] --[[ Name: TranslateInput ]]
    return (not (v98.UserInputType ~= Enum.UserInputType.Keyboard) or v98.UserInputType == Enum.UserInputType.Gamepad1) and v98.KeyCode or v98.UserInputType;
end;
v3.GetNumberFromNumberKey = function(v99) --[[ Line: 378 ]] --[[ Name: GetNumberFromNumberKey ]]
    -- upvalues: v3 (copy)
    if not v3.IsNumberKey(v99) then
        return nil;
    else
        return v99.Value - 48;
    end;
end;
v3.GetTrackById = function(v100, v101) --[[ Line: 387 ]] --[[ Name: GetTrackById ]]
    if v100 == nil or typeof(v100) ~= "string" then
        return error("you did not pass an animation id or its not a string");
    else
        local v102 = nil;
        for _, v104 in ipairs(v101:GetPlayingAnimationTracks()) do
            if v104.Animation.AnimationId == v100 and v104.IsPlaying then
                return v104;
            end;
        end;
        return v102;
    end;
end;
v3.ConvertStringAttributeFriendly = function(v105) --[[ Line: 404 ]] --[[ Name: ConvertStringAttributeFriendly ]]
    return string.gsub(v105, "[%c%%%.,'!? %-]", "");
end;
v3.SafeCall = function(v106) --[[ Line: 408 ]] --[[ Name: SafeCall ]]
    local l_status_0, l_result_0 = pcall(v106);
    if not l_status_0 then
        warn(l_result_0);
    end;
    return l_result_0;
end;
v3.cmap = function(v109, v110, v111, v112, v113) --[[ Line: 418 ]] --[[ Name: cmap ]]
    return (math.clamp(math.map(v109, v110, v111, v112, v113), v112, v113));
end;
v3.IsFacingOnAWall = function(v114, v115) --[[ Line: 422 ]] --[[ Name: IsFacingOnAWall ]]
    -- upvalues: v3 (copy)
    local v116 = workspace:Raycast(v114.Position, v114.CFrame.LookVector * 2.5, v115 or v3.VisualParams);
    local v117 = false;
    if v116 ~= nil then
        v117 = v116.Instance.CanCollide;
    end;
    return v117;
end;
local function _(v118) --[[ Line: 428 ]] --[[ Name: FormatInt ]]
    return string.format("%02i", v118);
end;
v3.ConvertToHMS = function(v120) --[[ Line: 432 ]] --[[ Name: ConvertToHMS ]]
    local v121 = (v120 - v120 % 60) / 60;
    v120 = v120 - v121 * 60;
    local v122 = (v121 - v121 % 60) / 60;
    v121 = v121 - v122 * 60;
    return string.format("%02i", v122) .. ":" .. string.format("%02i", v121) .. ":" .. string.format("%02i", v120);
end;
return v3;