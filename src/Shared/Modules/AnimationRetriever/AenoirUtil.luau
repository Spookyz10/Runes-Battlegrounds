local v0 = {};
local _ = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
v0.get_asset_id = function(v4) --[[ Line: 8 ]] --[[ Name: get_asset_id ]]
    v4 = v4:lower();
    local v5 = v4:match("^(%d+)$") or v4:match("^rbxassetid://(%d+)$") or v4:match("^http://www%.roblox%.com/asset/%?id=(%d+)$") or v4:match("^https://www%.roblox%.com/library/(%d+)") or v4:match("^https://create%.roblox%.com/marketplace/asset/(%d+)");
    if v5 then
        return (tonumber(v5));
    else
        return nil;
    end;
end;
v0.GetAnimationId = function(v6) --[[ Line: 24 ]] --[[ Name: GetAnimationId ]]
    return (tonumber(string.match(v6, "(%d+)$")));
end;
v0.WaitForAnimation = function(v7, v8, v9) --[[ Line: 28 ]] --[[ Name: WaitForAnimation ]]
    -- upvalues: v0 (copy)
    if typeof(v8) == "string" then
        v8 = v0.GetAnimationId(v8);
    end;
    local v10 = v0.GetAnimationFromId(v7, v8);
    if not v10 then
        local v11 = coroutine.running();
        local v12 = true;
        local v13 = nil;
        local v14 = nil;
        do
            local l_v12_0, l_v13_0, l_v14_0 = v12, v13, v14;
            local function _() --[[ Line: 39 ]] --[[ Name: WorkDone ]]
                -- upvalues: l_v14_0 (ref), l_v13_0 (ref)
                if l_v14_0 and l_v14_0.Connected then
                    l_v14_0:Disconnect();
                end;
                if l_v13_0 and coroutine.status(l_v13_0) == "suspended" then
                    task.cancel(l_v13_0);
                    l_v13_0 = nil;
                end;
            end;
            local function v20(v19) --[[ Line: 50 ]] --[[ Name: Resume ]]
                -- upvalues: l_v14_0 (ref), l_v13_0 (ref), l_v12_0 (ref), v11 (copy)
                if l_v14_0 and l_v14_0.Connected then
                    l_v14_0:Disconnect();
                end;
                if l_v13_0 and coroutine.status(l_v13_0) == "suspended" then
                    task.cancel(l_v13_0);
                    l_v13_0 = nil;
                end;
                if l_v12_0 then
                    l_v12_0 = not l_v12_0;
                    coroutine.resume(v11, v19);
                end;
            end;
            l_v14_0 = v7.AnimationPlayed:Connect(function(v21) --[[ Line: 59 ]]
                -- upvalues: v0 (ref), v8 (ref), l_v14_0 (ref), l_v13_0 (ref), l_v12_0 (ref), v11 (copy)
                if v21.Animation and v0.GetAnimationId(v21.Animation.AnimationId) == v8 then
                    if l_v14_0 and l_v14_0.Connected then
                        l_v14_0:Disconnect();
                    end;
                    if l_v13_0 and coroutine.status(l_v13_0) == "suspended" then
                        task.cancel(l_v13_0);
                        l_v13_0 = nil;
                    end;
                    if l_v12_0 then
                        l_v12_0 = not l_v12_0;
                        coroutine.resume(v11, v21);
                    end;
                end;
            end);
            l_v13_0 = task.delay(v9 or 15, v20);
            v10 = coroutine.yield();
            if l_v14_0 and l_v14_0.Connected then
                l_v14_0:Disconnect();
            end;
            if l_v13_0 and coroutine.status(l_v13_0) == "suspended" then
                task.cancel(l_v13_0);
                l_v13_0 = nil;
            end;
        end;
    end;
    return v10;
end;
v0.EventFrequency = function(v22, v23, v24) --[[ Line: 73 ]] --[[ Name: EventFrequency ]]
    local v25 = 0;
    return v22:Connect(function(v26) --[[ Line: 76 ]]
        -- upvalues: v25 (ref), v23 (copy), v24 (copy)
        v25 = v25 + v26;
        if v23 < v25 then
            v25 = v25 - v23;
            v24(v26);
        end;
    end);
end;
v0.WaitForAnimationLoaded = function(v27, v28) --[[ Line: 86 ]] --[[ Name: WaitForAnimationLoaded ]]
    local v29 = 0;
    local v30 = v28 or 5;
    repeat
        v29 = v29 + task.wait();
    until v27.Length ~= 0 and v29 < v30;
end;
v0.GetAnimationFromId = function(v31, v32) --[[ Line: 96 ]] --[[ Name: GetAnimationFromId ]]
    -- upvalues: v0 (copy)
    for _, v34 in v31:GetPlayingAnimationTracks() do
        if v34.Animation and v34.IsPlaying and v0.GetAnimationId(v34.Animation.AnimationId) == v32 then
            return v34;
        end;
    end;
    return nil;
end;
v0.StopEffects = function(v35) --[[ Line: 106 ]] --[[ Name: StopEffects ]]
    for _, v37 in v35:GetDescendants() do
        if v37:IsA("ParticleEmitter") or v37:IsA("Beam") or v37:IsA("Light") then
            v37.Enabled = false;
        elseif v37:IsA("Sound") then
            v37:Stop();
        end;
    end;
end;
v0.Unit = function(v38, v39) --[[ Line: 117 ]] --[[ Name: Unit ]]
    if v38.Magnitude < 1.0E-7 then
        return v39 or Vector3.new(0, 0, 0, 0);
    else
        return v38.Unit;
    end;
end;
v0.CreateAttachment = function(v40, v41) --[[ Line: 121 ]] --[[ Name: CreateAttachment ]]
    local l_Attachment_0 = Instance.new("Attachment");
    l_Attachment_0.CFrame = v40;
    l_Attachment_0.Parent = v41;
    return l_Attachment_0;
end;
v0.CreatePsuedoAttachment = function(v43) --[[ Line: 129 ]] --[[ Name: CreatePsuedoAttachment ]]
    -- upvalues: l_RunService_0 (copy)
    local l_Attachment_1 = Instance.new("Attachment");
    l_Attachment_1.WorldCFrame = v43.WorldCFrame;
    l_Attachment_1.Parent = workspace.Terrain;
    local v46 = l_RunService_0.PreRender:Connect(function(_) --[[ Line: 134 ]]
        -- upvalues: l_Attachment_1 (copy), v43 (copy)
        l_Attachment_1.WorldCFrame = v43.WorldCFrame;
    end);
    l_Attachment_1.Destroying:Once(function() --[[ Line: 138 ]]
        -- upvalues: v46 (copy)
        v46:Disconnect();
    end);
    return l_Attachment_1;
end;
v0.GetModelParts = function(v50) --[[ Line: 155 ]] --[[ Name: GetModelParts ]]
    local v51 = {};
    for _, v53 in v50:GetDescendants() do
        if v53:IsA("BasePart") then
            table.insert(v51, v53);
        end;
    end;
    return v51;
end;
v0.GetModelPartDecals = function(v54) --[[ Line: 165 ]] --[[ Name: GetModelPartDecals ]]
    local v55 = {};
    for _, v57 in v54:GetDescendants() do
        if v57.Name ~= "HumanoidRootPart" and (v57:IsA("BasePart") or v57:IsA("Decal")) then
            table.insert(v55, v57);
        end;
    end;
    return v55;
end;
v0.RemoveAllTagsOnInstance = function(v58) --[[ Line: 175 ]] --[[ Name: RemoveAllTagsOnInstance ]]
    for _, v60 in v58:GetTags() do
        v58:RemoveTag(v60);
    end;
end;
v0.CloneCharacter = function(v61) --[[ Line: 181 ]] --[[ Name: CloneCharacter ]]
    -- upvalues: v0 (copy)
    v61.Archivable = true;
    local v62 = v61:Clone();
    v62.Archivable = false;
    v61.Archivable = false;
    v0.CleanAfterimage(v62, 0);
    return v62;
end;
v0.CleanAfterimage = function(v63, v64) --[[ Line: 194 ]] --[[ Name: CleanAfterimage ]]
    -- upvalues: v0 (copy)
    local v65 = v0.GetModelParts(v63);
    local v66 = v0.GetModelPartDecals(v63);
    if v64 ~= nil then
        for _, v68 in v66 do
            if not v68:GetAttribute("Transparent") then
                v68.Transparency = v64;
            end;
        end;
    end;
    for _, v70 in v63:GetChildren() do
        if not v70:IsA("Shirt") and not v70:IsA("Pants") and not v70:IsA("BodyColors") and not v70:IsA("Part") and not v70:IsA("Humanoid") and not v70:IsA("Accessory") then
            v70:Destroy();
        end;
    end;
    for _, v72 in v63:GetDescendants() do
        if v72:IsA("Constraint") or v72:IsA("BodyMover") or v72:IsA("ParticleEmitter") or v72:IsA("Sound") or v72:IsA("BillboardGui") or v72:IsA("BallSocketConstraint") or v72:IsA("LuaSourceContainer") then
            v72:Destroy();
        end;
    end;
    v63.Humanoid.RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0, 0);
    v63.Humanoid.RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0, 0);
    v63.Humanoid.EvaluateStateMachine = false;
    v63.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
    v63.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff;
    v0.RemoveAllTagsOnInstance(v63.Humanoid);
    local function v75() --[[ Line: 229 ]] --[[ Name: SetCanCollide ]]
        -- upvalues: v65 (copy), v0 (ref)
        for _, v74 in v65 do
            v74.AssemblyLinearVelocity = Vector3.new(0, 0, 0, 0);
            v74.AssemblyAngularVelocity = Vector3.new(0, 0, 0, 0);
            v0.RemoveAllTagsOnInstance(v74);
            v74.CollisionGroup = "NoCollision";
            v74.CanCollide = false;
            v74.CanQuery = false;
            v74.CanTouch = false;
        end;
    end;
    v75();
    v63.AncestryChanged:Connect(v75);
    return v65, v66;
end;
local function v78(v76, v77) --[[ Line: 249 ]] --[[ Name: Enlarge ]]
    return v76.Time, v76.Value * v77, v76.Envelope * v77;
end;
v0.ScaleNumberSequence = function(v79, v80) --[[ Line: 253 ]] --[[ Name: ScaleNumberSequence ]]
    -- upvalues: v0 (copy), v78 (copy)
    return v0.TransformNumberSequence(v79, v78, v80);
end;
v0.TransformNumberSequence = function(v81, v82, ...) --[[ Line: 257 ]] --[[ Name: TransformNumberSequence ]]
    local v83 = {};
    for _, v85 in ipairs(v81.Keypoints) do
        table.insert(v83, NumberSequenceKeypoint.new(v82(v85, ...)));
    end;
    return NumberSequence.new(v83);
end;
return v0;