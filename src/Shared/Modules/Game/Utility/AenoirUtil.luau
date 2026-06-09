-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: AenoirUtil, time of decompilation: Tue Aug  5 05:08:56 2025 ]]
local v0 = {};
local _ = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
local v3 = require(script.Parent);
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
v0.GetAnimationFromId = function(v22, v23) --[[ Line: 73 ]] --[[ Name: GetAnimationFromId ]]
    -- upvalues: v0 (copy)
    for _, v25 in v22:GetPlayingAnimationTracks() do
        if v25.Animation and v25.IsPlaying and v0.GetAnimationId(v25.Animation.AnimationId) == v23 then
            return v25;
        end;
    end;
    return nil;
end;
v0.StopEffects = function(v26) --[[ Line: 83 ]] --[[ Name: StopEffects ]]
    for _, v28 in v26:GetDescendants() do
        if v28:IsA("ParticleEmitter") or v28:IsA("Beam") then
            v28.Enabled = false;
        elseif v28:IsA("Sound") then
            v28:Stop();
        end;
    end;
end;
v0.Unit = function(v29, v30) --[[ Line: 94 ]] --[[ Name: Unit ]]
    if v29.Magnitude < 1.0E-7 then
        return v30 or Vector3.new(0, 0, 0, 0);
    else
        return v29.Unit;
    end;
end;
v0.CreateAttachment = function(v31, v32) --[[ Line: 98 ]] --[[ Name: CreateAttachment ]]
    local l_Attachment_0 = Instance.new("Attachment");
    l_Attachment_0.CFrame = v31;
    l_Attachment_0.Parent = v32;
    return l_Attachment_0;
end;
v0.CreatePsuedoAttachment = function(v34) --[[ Line: 106 ]] --[[ Name: CreatePsuedoAttachment ]]
    -- upvalues: l_RunService_0 (copy)
    local l_Attachment_1 = Instance.new("Attachment");
    l_Attachment_1.WorldCFrame = v34.WorldCFrame;
    l_Attachment_1.Parent = workspace.Terrain;
    local v37 = l_RunService_0.PreRender:Connect(function(_) --[[ Line: 111 ]]
        -- upvalues: l_Attachment_1 (copy), v34 (copy)
        l_Attachment_1.WorldCFrame = v34.WorldCFrame;
    end);
    l_Attachment_1.Destroying:Once(function() --[[ Line: 115 ]]
        -- upvalues: v37 (copy)
        v37:Disconnect();
    end);
    return l_Attachment_1;
end;
v0.CastOnGround = function(v38, v39) --[[ Line: 122 ]] --[[ Name: CastOnGround ]]
    -- upvalues: v3 (copy)
    local v40 = workspace:Raycast(v38, Vector3.new(-0, -1, -0, -0) * v39, v3.VisualParams);
    if v40 then
        return CFrame.lookAlong(v40.Position, v40.Normal) + v40.Normal * 0.1, v40;
    else
        return CFrame.lookAlong(v38, (Vector3.new(0, 1, 0, 0))), v40;
    end;
end;
v0.GetModelParts = function(v41) --[[ Line: 132 ]] --[[ Name: GetModelParts ]]
    local v42 = {};
    for _, v44 in v41:GetDescendants() do
        if v44:IsA("BasePart") then
            table.insert(v42, v44);
        end;
    end;
    return v42;
end;
v0.GetModelPartDecals = function(v45) --[[ Line: 142 ]] --[[ Name: GetModelPartDecals ]]
    local v46 = {};
    for _, v48 in v45:GetDescendants() do
        if v48.Name ~= "HumanoidRootPart" and (v48:IsA("BasePart") or v48:IsA("Decal")) then
            table.insert(v46, v48);
        end;
    end;
    return v46;
end;
v0.RemoveAllTagsOnInstance = function(v49) --[[ Line: 152 ]] --[[ Name: RemoveAllTagsOnInstance ]]
    for _, v51 in v49:GetTags() do
        v49:RemoveTag(v51);
    end;
end;
v0.CleanAfterimage = function(v52, v53) --[[ Line: 158 ]] --[[ Name: CleanAfterimage ]]
    -- upvalues: v0 (copy)
    local v54 = v0.GetModelParts(v52);
    local v55 = v0.GetModelPartDecals(v52);
    if v53 ~= nil then
        for _, v57 in v55 do
            v57.Transparency = v53;
        end;
    end;
    for _, v59 in v52:GetChildren() do
        if not v59:IsA("Shirt") and not v59:IsA("Pants") and not v59:IsA("BodyColors") and not v59:IsA("Part") and not v59:IsA("Humanoid") and not v59:IsA("Accessory") then
            v59:Destroy();
        end;
    end;
    for _, v61 in v52:GetDescendants() do
        if v61:IsA("Constraint") or v61:IsA("BodyMover") or v61:IsA("ParticleEmitter") or v61:IsA("Sound") or v61:IsA("BillboardGui") or v61:IsA("BallSocketConstraint") or v61:IsA("LuaSourceContainer") then
            v61:Destroy();
        end;
    end;
    v52.Humanoid.RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0, 0);
    v52.Humanoid.RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0, 0);
    v52.Humanoid.EvaluateStateMachine = false;
    v52.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
    v52.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff;
    v0.RemoveAllTagsOnInstance(v52.Humanoid);
    local function v64() --[[ Line: 189 ]] --[[ Name: SetCanCollide ]]
        -- upvalues: v54 (copy), v0 (ref)
        for _, v63 in v54 do
            v63.AssemblyLinearVelocity = Vector3.new(0, 0, 0, 0);
            v63.AssemblyAngularVelocity = Vector3.new(0, 0, 0, 0);
            v0.RemoveAllTagsOnInstance(v63);
            v63.CollisionGroup = "NoCollision";
            v63.CanCollide = false;
            v63.CanQuery = false;
            v63.CanTouch = false;
        end;
    end;
    v64();
    v52.AncestryChanged:Connect(v64);
    return v54, v55;
end;
return v0;