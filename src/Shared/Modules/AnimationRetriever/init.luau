local v0 = {};
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer;
local v3 = require(l_ReplicatedStorage_0.Modules.Job);
local v4 = require(script.AenoirUtil);
local v5 = {};
v0.RemoveActive = function(v6, _) --[[ Line: 13 ]] --[[ Name: RemoveActive ]]
	-- upvalues: v5 (copy)
	if v5[v6] then
		v5[v6]:Destroy();
	end;
end;
v0.new = function(v8, v9) --[[ Line: 34 ]] --[[ Name: new ]]
    -- upvalues: v0 (copy), v4 (copy), v3 (copy), v5 (copy), l_LocalPlayer_0 (copy)
    if v8 == nil or v8.Parent == nil then
        return error("animation retriever: failed to get model");
    else
        local l_Name_0 = v9.Name;
        v0.RemoveActive(v8, l_Name_0);
        local v11 = v8 and v8:FindFirstChild("Torso");
        local v12 = v8 and v8:FindFirstChild("Humanoid");
        local v13 = v8 and v8:FindFirstChild("HumanoidRootPart");
        local v14 = v12 and v12:FindFirstChild("Animator");
        if v11 == nil or v12 == nil or v13 == nil or v14 == nil then
            return error("animation retriever: failed to get model children");
        else
            local v15 = v4.WaitForAnimation(v14, v9.AnimationId, 3);
            if v15 == nil then
                return error("animation retriever: failed to get server animation on client with the name " .. v15.Name .. ", probably isn't playing");
            else
                local v16 = v3.new();
                local v17 = v3.Extend(v16);
                v16:Task(function() --[[ Line: 62 ]]
                    -- upvalues: v5 (ref), v8 (copy)
                    if v5[v8] then
                        v5[v8] = nil;
                    end;
                end);
                v16:Task(v8.AncestryChanged:Connect(function(_, v19) --[[ Line: 68 ]]
                    -- upvalues: v0 (ref), v8 (copy), l_Name_0 (copy)
                    if v19 == nil then
                        v0.RemoveActive(v8, l_Name_0);
                    end;
                end));
                v16:Task(v15.Stopped:Connect(function() --[[ Line: 74 ]]
                    -- upvalues: v0 (ref), v8 (copy), l_Name_0 (copy)
                    v0.RemoveActive(v8, l_Name_0);
                end));
                v5[v8] = v16;
                return {
                    Animation = v15, 
                    MainJob = v16, 
                    Job = v17, 
                    Model = v8, 
                    Torso = v11, 
                    Humanoid = v12, 
                    RootPart = v13, 
                    Animator = v14, 
                    IsLocalSource = l_LocalPlayer_0.Character == v8
                };
            end;
        end;
    end;
end;
return v0;