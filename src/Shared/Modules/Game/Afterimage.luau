-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- [[ Script name: Afterimage, time of decompilation: Tue Aug  5 05:08:23 2025 ]]
local l_TweenService_0 = game:GetService("TweenService");
return function(v1, v2, v3, v4, v5) --[[ Line: 3 ]]
    -- upvalues: l_TweenService_0 (copy)
    local l_Position_0 = v1.HumanoidRootPart.Position;
    local l_Model_0 = Instance.new("Model");
    l_Model_0.Name = "Afterimage";
    local l_Humanoid_0 = Instance.new("Humanoid");
    l_Humanoid_0.DisplayDistanceType = "None";
    l_Humanoid_0.HealthDisplayType = "AlwaysOff";
    l_Humanoid_0.BreakJointsOnDeath = false;
    l_Humanoid_0.EvaluateStateMachine = false;
    l_Humanoid_0.RequiresNeck = false;
    l_Humanoid_0.AutomaticScalingEnabled = false;
    local l_Shirt_0 = v1:FindFirstChildOfClass("Shirt");
    local l_Pants_0 = v1:FindFirstChildOfClass("Pants");
    if l_Shirt_0 ~= nil then
        l_Shirt_0:Clone().Parent = l_Model_0;
    end;
    if l_Pants_0 ~= nil then
        l_Pants_0:Clone().Parent = l_Model_0;
    end;
    for _, v12 in ipairs(v1:GetDescendants()) do
        if v12:IsA("BasePart") and v12.Name ~= "HumanoidRootPart" and not v12:HasTag("RagdollCollider") then
            local v13 = v12:Clone();
            for _, v15 in ipairs(v13:GetChildren()) do
                if not v15:IsA("SpecialMesh") then
                    v15:Destroy();
                end;
            end;
            v13.CollisionGroup = "NoCollision";
            v13.Anchored = true;
            v13.CanCollide = false;
            v13.CanTouch = false;
            v13.CanQuery = false;
            v13.Massless = true;
            v13.CastShadow = false;
            v13.Archivable = true;
            v13.Transparency = 0;
            v13.Parent = l_Model_0;
            l_TweenService_0:Create(v13, TweenInfo.new(table.unpack(v2)), {
                Transparency = 1
            }):Play();
            task.delay(v4 / 60, function() --[[ Line: 48 ]]
                -- upvalues: l_TweenService_0 (ref), v13 (copy), v3 (copy), v12 (copy), v1 (copy), l_Position_0 (copy)
                l_TweenService_0:Create(v13, TweenInfo.new(table.unpack(v3)), {
                    CFrame = v12.CFrame - (v1.HumanoidRootPart.Position - l_Position_0)
                }):Play();
            end);
        elseif v12:IsA("CharacterMesh") then
            v12:Clone().Parent = l_Model_0;
        end;
    end;
    if v5 then
        task.spawn(v5, l_Model_0);
    end;
    l_Humanoid_0.Parent = l_Model_0;
    l_Model_0.Parent = workspace.Thrown;
    task.delay(v2[1], l_Model_0.Destroy, l_Model_0);
end;