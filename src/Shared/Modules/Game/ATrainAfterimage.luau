
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
local _ = require(l_ReplicatedStorage_0.Modules.Game.Utility)
local v3 = {};
local v4 = nil;
local function v12(_) --[[ Line: 9 ]] --[[ Name: StateStepped ]]
    -- upvalues: v3 (copy)
    for v6, v7 in v3 do
        if not v6:IsDescendantOf(workspace) then
            v7:Destroy();
        else
            for _, v9 in v7.Afterimages do
                for v10, v11 in v9.CharacterParts do
                    v11.CFrame = v7.CharacterParts[v10].CFrame + Vector3.new(math.sin(tick() * 40) * 0.8 * v9.TheMethod, math.sin(tick() * 0.2) * 0.1, math.cos(tick() * 37.5) * 0.5 * -v9.TheMethod);
                end;
            end;
        end;
    end;
end;
local v13 = {
    "Fire", 
    "Sparkles", 
    "Smoke", 
    "ParticleEmitter", 
    "Sound", 
    "Trail", 
    "Beam", 
    "Attachment", 
    "WeldConstraint", 
    "BillboardGui"
};
local v14 = nil;
local _ = nil;
v14 = function(v16, v17) --[[ Line: 26 ]] --[[ Name: CleanInstance ]]
    -- upvalues: v13 (copy), v14 (ref)
    if v17:IsA("LuaSourceContainer") or v17:IsA("JointInstance") or v17:IsA("Constraint") or table.find(v13, v17.ClassName) then
        v17:Destroy();
        return true;
    elseif v17:IsA("Decal") and not table.find(v16.CharacterTextures, v17) then
        table.insert(v16.CharacterTextures, v17);
        return;
    else
        for _, v19 in v17:GetChildren() do
            v14(v16, v19);
        end;
        return;
    end;
end;
local v23 = {
    __index = {
        Destroy = function(v20) --[[ Line: 40 ]] --[[ Name: Destroy ]]
            -- upvalues: v3 (copy)
            for _, v22 in v20.Afterimages do
                v22.Model:Destroy();
            end;
            v3[v20.Model] = nil;
        end
    }
};
return function(v24, v25) --[[ Line: 47 ]]
    -- upvalues: v3 (copy), v23 (copy), v4 (ref), l_RunService_0 (copy), v12 (copy)
    if v25 then
        if v3[v24] then
            return;
        else
            local v26 = setmetatable({
                Model = v24, 
                CharacterParts = {}, 
                CharacterOthers = {}, 
                Afterimages = {}
            }, v23);
            for _, v28 in v24:GetDescendants() do
                if v28:IsA("BasePart") and not v28:GetAttribute("AfterimageIgnore") then
                    table.insert(v26.CharacterParts, v28);
                end;
            end;
            for _, v30 in v24:GetChildren() do
                if v30:IsA("Clothing") or v30:IsA("ShirtTemplate") or v30:IsA("CharacterMesh") or v30:IsA("BodyColors") then
                    table.insert(v26.CharacterOthers, v30);
                end;
            end;
            for v31 = 1, 2 do
                local v32 = {
                    TheMethod = v31 == 1 and -1 or 1, 
                    Model = nil, 
                    Humanoid = nil, 
                    CharacterParts = {}, 
                    CharacterTextures = {}, 
                    CharacterOthers = {}
                };
                local l_Model_0 = Instance.new("Model");
                local l_Humanoid_0 = Instance.new("Humanoid");
                l_Humanoid_0.DisplayDistanceType = "None";
                l_Humanoid_0.HealthDisplayType = "AlwaysOff";
                l_Humanoid_0.BreakJointsOnDeath = false;
                l_Humanoid_0.EvaluateStateMachine = false;
                l_Humanoid_0.RequiresNeck = false;
                l_Humanoid_0.AutomaticScalingEnabled = false;
                l_Humanoid_0.Parent = l_Model_0;
                if v31 == 1 then
                    for _, v36 in v26.CharacterParts do
                        local v37 = Instance.fromExisting(v36);
                        for _, v39 in v36:GetChildren() do
                            if v39:IsA("DataModelMesh") or v39:IsA("SurfaceAppearance") then
                                Instance.fromExisting(v39).Parent = v37;
                            elseif v39:IsA("Texture") then
                                local v40 = Instance.fromExisting(v39);
                                v40.Parent = v37;
                                table.insert(v32.CharacterTextures, v40);
                            end;
                        end;
                        v37.CollisionGroup = "NoCollision";
                        v37.Anchored = true;
                        v37.CanCollide = false;
                        v37.CanTouch = false;
                        v37.CanQuery = false;
                        v37.Massless = true;
                        v37.CastShadow = false;
                        v37.Archivable = true;
                        v37.Transparency = math.lerp(v36.Transparency, 1, 0.7);
                        table.insert(v32.CharacterParts, v37);
                        v37.Parent = l_Model_0;
                    end;
                else
                    for _, v42 in v26.Afterimages[1].CharacterParts do
                        local v43 = v42:Clone();
                        v43.Parent = l_Model_0;
                        table.insert(v32.CharacterParts, v43);
                    end;
                end;
                for _, v45 in v32.CharacterTextures do
                    v45.Transparency = math.lerp(v45.Transparency, 1, 0.7);
                end;
                for _, v47 in v26.CharacterOthers do
                    Instance.fromExisting(v47).Parent = l_Model_0;
                end;
                v32.Model = l_Model_0;
                v32.Humanoid = l_Humanoid_0;
                l_Model_0.Parent = workspace.Thrown;
                table.insert(v26.Afterimages, v32);
            end;
            if not v4 then
                v4 = l_RunService_0.RenderStepped:Connect(v12);
            end;
            v3[v24] = v26;
            return;
        end;
    else
        local v48 = v3[v24];
        if v48 then
            v48:Destroy();
        end;
        if v4 and next(v3) == nil then
            v4:Disconnect();
            v4 = nil;
            return;
        else
            return;
        end;
    end;
end;