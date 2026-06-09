local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService")
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer
local v6 = require(l_ReplicatedStorage_0.Modules.Utility)

local v15 = {
    AenoirEmit = require(script.AenoirEmit), 
    Arc = require(script.Arc), 
    Dojyan = require(script.Dojyan), 
    Toggle = function(v8, v9, v10) --[[ Line: 20 ]] --[[ Name: Toggle ]]
        if v10 then
            for _, v12 in ipairs(v8:GetChildren()) do
                if v12:IsA("ParticleEmitter") or v12:IsA("Trail") or v12:IsA("Beam") or v12:IsA("PointLight") then
                    v12.Enabled = v9;
                end;
            end;
            return;
        else
            for _, v14 in ipairs(v8:GetDescendants()) do
                if v14:IsA("ParticleEmitter") or v14:IsA("Trail") or v14:IsA("Beam") or v14:IsA("PointLight") then
                    v14.Enabled = v9;
                end;
            end;
            return;
        end;
    end
}

v15.ToggleForTime = function(v16, v17, v18, v19)
    v15.Toggle(v16, true, v18);
	task.delay(v17, v15.Toggle, v16, false, v18)
	
    if not v19 then
        task.delay(v17 * 2, v16.Destroy, v16)
    end
end

local function v27(v20, _, v22, v23)
    local l_IsLoaded_0 = v20.IsLoaded;
	local v25 = false
	
    local function v26()
        if v23 then
            v23(v20.TimeLength);
        end;
        v20:Play()
	end
	
    if not l_IsLoaded_0 then
        if not v25 and v22 and v22.Parent ~= nil and v22.ClassName == "Part" then
            v20.Parent = v22
            v25 = true
		end
		
        v20.Loaded:Once(v26)
        return
    else
        if v23 then
            v23(v20.TimeLength)
		end
		
        v20:Play()
        return
    end
end
v15.Emit = function(v28, v29) --[[ Line: 73 ]] --[[ Name: Emit ]]
    -- upvalues: v5 (copy), v27 (copy)
    local v30 = 0;
    local v31 = {};
    for _, v33 in ipairs(v28:GetDescendants()) do
        if v33:IsA("ParticleEmitter") then
            v33.Name = "Particle";
            v31[v33] = true;
            if v33:GetAttribute("EmitDuration") ~= nil and v33:GetAttribute("EmitDuration") ~= 0 then
                v33.Enabled = true;
                task.delay(v33:GetAttribute("EmitDuration"), function() --[[ Line: 86 ]]
                    -- upvalues: v33 (copy)
                    v33.Enabled = false;
                end);
                local v34 = (v33:GetAttribute("EmitDuration") + (v33.Lifetime.Min + v33.Lifetime.Max)) / v33.TimeScale;
                v30 = math.max(v30, v34);
            else
                local v35 = v33:GetAttribute("EmitCount") or 1;
                local v36 = v33:GetAttribute("EmitDelay") or 0;
                if v36 ~= 0 then
                    task.delay(v36, v33.Emit, v33, v35);
                    local v37 = (v36 + (v33.Lifetime.Min + v33.Lifetime.Max)) / v33.TimeScale;
                    v30 = math.max(v30, v37);
                else
                    v33:Emit(v35);
                    local v38 = (v33.Lifetime.Min + v33.Lifetime.Max) / v33.TimeScale;
                    v30 = math.max(v30, v38);
                end;
            end;
        elseif v33:IsA("Sound") then
            v33.Name = "Sound";
            v27(v33, v28, v28, function(v39) --[[ Line: 108 ]]
                -- upvalues: v30 (ref)
                v30 = math.max(v30, v39);
            end);
            v31[v33] = true;
        end;
    end;
    if not v29 then
        task.delay(v30, v28.Destroy, v28);
    end;
    return v31, v30;
end;
v15.CloneAndEmit = function(v40, v41) --[[ Line: 123 ]] --[[ Name: CloneAndEmit ]]
    -- upvalues: v15 (copy)
    local v42 = v40:Clone();
    v42.Parent = v41;
    if v40:IsA("ParticleEmitter") then
        v42:Emit(v42:GetAttribute("EmitCount") or 1);
        return v42;
    else
        v15.Emit(v42);
        return v42;
    end;
end;
v15.CloneAndToggle = function(v49, v50, v51, v52) --[[ Line: 193 ]] --[[ Name: CloneAndToggle ]]
	-- upvalues: v15 (copy)
	local v53 = v49:Clone();
	v53.Parent = v50;
	v15.Toggle(v49, v51 or true, v52);
	return v53;
end;
v15.EmitAttachment = v15.Emit;
v15.EmitEffects = function(v43, v44, v45, v46) --[[ Line: 144 ]] --[[ Name: EmitEffects ]]
    -- upvalues: v27 (copy), v5 (copy), l_LocalPlayer_0 (copy), l_ReplicatedStorage_0 (copy)
    local v47 = 0;
    local v48 = {};
    local l_Attachment_0 = Instance.new("Attachment");
    if v45 ~= nil then
        if typeof(v45) == "Vector3" then
            l_Attachment_0.WorldPosition = v45;
        elseif typeof(v45) == "CFrame" then
            l_Attachment_0.WorldCFrame = v45;
        end;
    elseif v46 ~= nil then
        if typeof(v46) == "Vector3" then
            l_Attachment_0.Position = v46;
        elseif typeof(v46) == "CFrame" then
            l_Attachment_0.CFrame = v46;
        end;
    end;
    l_Attachment_0.Parent = v44;
    local function v59() --[[ Line: 169 ]] --[[ Name: Search ]]
        -- upvalues: v43 (copy), l_Attachment_0 (copy), v27 (ref), v44 (copy), v47 (ref), v48 (copy), v5 (ref)
        for _, v51 in ipairs(v43:GetChildren()) do
            if v51:IsA("Folder") and v51.Name == "Random" then
                local v52 = v51[math.random(1, #v51:GetChildren())]:Clone();
                v52.Name = "RandomSound";
                v52.Parent = l_Attachment_0;
                v27(v52, v43, v44, function(v53) --[[ Line: 176 ]]
                    -- upvalues: v47 (ref)
                    v47 = math.max(v47, v53);
                end);
                v48[v52] = true;
            elseif v51:IsA("ParticleEmitter") then
                local v54 = v51:Clone();
                v54.Name = "Particle";
                v54.Parent = l_Attachment_0;
                if v54:GetAttribute("EmitDuration") ~= nil and v54:GetAttribute("EmitDuration") ~= 0 then
                    v54.Enabled = true;
                    task.delay(v54:GetAttribute("EmitDuration"), function() --[[ Line: 191 ]]
                        -- upvalues: v54 (copy)
                        v54.Enabled = false;
                    end);
                    v47 = math.max(v47, (v54:GetAttribute("EmitDuration") + (v54.Lifetime.Min + v54.Lifetime.Max)) / v54.TimeScale);
                else
                    local v55 = v54:GetAttribute("EmitCount") or 1;
                    local v56 = v54:GetAttribute("EmitDelay") or 0;
                    if v56 ~= 0 then
                        task.delay(v56, v54.Emit, v54, v55);
                        v47 = math.max(v47, (v56 + (v54.Lifetime.Min + v54.Lifetime.Max)) / v54.TimeScale);
                    else
                        v54:Emit(v55);
                        v47 = math.max(v47, (v54.Lifetime.Min + v54.Lifetime.Max) / v54.TimeScale);
                    end;
                end;
                v48[v54] = true;
            elseif v51:IsA("Sound") then
                local v57 = v51:Clone();
                v57.Name = "Sound";
                v57.Parent = l_Attachment_0;
                v27(v57, v43, v44, function(v58) --[[ Line: 216 ]]
                    -- upvalues: v47 (ref)
                    v47 = math.max(v47, v58);
                end);
                v48[v57] = true;
            end;
        end;
    end;
    if l_LocalPlayer_0 then
        if l_LocalPlayer_0:GetAttribute("Blood") then
            v59();
        end;
    else
        v59();
    end;
    task.delay(v47, l_Attachment_0.Destroy, l_Attachment_0);
    return v48, l_Attachment_0;
end;
v15.EmitEffectsOnBasePart = function(v60, v61) --[[ Line: 238 ]] --[[ Name: EmitEffectsOnBasePart ]]
    -- upvalues: v27 (copy), v5 (copy)
    local v62 = {};
    for _, v64 in ipairs(v60:GetChildren()) do
        if v64:IsA("Folder") and v64.Name == "Random" then
            local v65 = v64[math.random(1, #v64:GetChildren())]:Clone();
            v65.Name = "RandomSound";
            v65.Parent = v61;
            v27(v65, v60, v61, function(v66) --[[ Line: 247 ]]
                -- upvalues: v65 (copy)
                task.delay(v66, v65.Destroy, v65);
            end);
            table.insert(v62, v65);
        elseif v64:IsA("ParticleEmitter") then
            local v67 = v64:Clone();
            v67.Name = "Particle";
            table.insert(v62, v67);
            v67.Parent = v61;
            if v67:GetAttribute("EmitDuration") ~= nil and v67:GetAttribute("EmitDuration") ~= 0 then
                v67.Enabled = true;
                task.delay(v67:GetAttribute("EmitDuration"), function() --[[ Line: 264 ]]
                    -- upvalues: v67 (copy)
                    v67.Enabled = false;
                end);
                task.delay(v67.Lifetime.Min + v67.Lifetime.Max, v67.Destroy, v67);
            else
                local v68 = v67:GetAttribute("EmitCount") or 1;
                local v69 = v67:GetAttribute("EmitDelay") or 0;
                if v69 ~= 0 then
                    task.delay(v69, v67.Emit, v67, v68);
                    task.delay(v69 + (v67.Lifetime.Min + v67.Lifetime.Max), v67.Destroy, v67);
                else
                    v67:Emit(v68);
                    task.delay(v67.Lifetime.Min + v67.Lifetime.Max, v67.Destroy, v67);
                end;
            end;
        elseif v64:IsA("Sound") then
            local v70 = v64:Clone();
            v70.Name = "Sound";
            v70.Parent = v61;
            v27(v70, v60, v61, function(v71) --[[ Line: 288 ]]
                -- upvalues: v70 (copy)
                task.delay(v71, v70.Destroy, v70);
            end);
            table.insert(v62, v70);
        end;
    end;
    return v62;
end;
v15.Weld = require(script.FakeWeld).new;
v15.WeldArmTrail = function(v72) 
    if not v72:IsA("BasePart") then
        warn("cannot do trail on a non limb");
        return nil;
    else
        local v73 = l_ReplicatedStorage_0.Resources.Effects.Parts.Arm:Clone()
        v73.Name = v72.Name .. " Trail";
        v73.CFrame = v72.CFrame;
        v15.Weld(v73, v72);
        v73.Parent = workspace.Thrown;
        v15.Toggle(v73, true);
        return v73;
    end;
end;
v15.WeldTrailsToAllLimbs = function(v74, v75) --[[ Line: 346 ]] --[[ Name: WeldTrailsToAllLimbs ]]
    -- upvalues: v15 (copy)
    local v76 = {};
    for _, v78 in ipairs(v74:GetChildren()) do
        if v78:IsA("BasePart") and v78.Name ~= "HumanoidRootPart" then
            local v79 = v15.WeldArmTrail(v78);
            table.insert(v76, v79);
            if v75 ~= nil then
                task.delay(v75, function() --[[ Line: 355 ]]
                    -- upvalues: v79 (copy)
                    for _, v81 in v79:GetChildren() do
                        if v81:IsA("Trail") then
                            v81.Enabled = false;
                        end;
                    end;
                    task.delay(1, v79.Destroy, v79);
                end);
            end;
        end;
    end;
    return v76;
end;
v15.AddSFX = function(v92, v93, v94) --[[ Line: 413 ]] --[[ Name: AddSFX ]]
    -- upvalues: l_TweenService_0 (copy)
    local v95 = v92:Clone();
    v95.Parent = v93;
    v95:Play();
    if v94 ~= nil and v94 > 0 then
        local v96 = TweenInfo.new(v94, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
        return {
            Destroy = function() --[[ Line: 422 ]] --[[ Name: Destroy ]]
                -- upvalues: v95 (copy), l_TweenService_0 (ref), v96 (copy)
                if v95.Volume > 0 and v95.IsPlaying then
                    local v97 = l_TweenService_0:Create(v95, v96, {
                        Volume = 0
                    });
                    v97.Completed:Connect(function(v98) --[[ Line: 426 ]]
                        -- upvalues: v97 (copy), v95 (ref)
                        if v98 == Enum.PlaybackState.Completed then
                            v97:Destroy();
                            v95:Destroy();
                        end;
                    end);
                    v97:Play();
                    return;
                else
                    v95:Destroy();
                    return;
                end;
            end
        };
    else
        return v95;
    end;
end;
v15.Distance_Close = function(v99, v100) --[[ Line: 444 ]] --[[ Name: Distance_Close ]]
    -- upvalues: l_LocalPlayer_0 (copy)
    if l_LocalPlayer_0.Character == v99 then
        return true;
    else
        return l_LocalPlayer_0:DistanceFromCharacter(v99.PrimaryPart.Position) < (v100 or 17.5);
    end;
end;
v15.Distance_Far = function(v101, v102) --[[ Line: 448 ]] --[[ Name: Distance_Far ]]
    -- upvalues: l_LocalPlayer_0 (copy)
    if l_LocalPlayer_0.Character == v101 then
        return true;
    else
        return l_LocalPlayer_0:DistanceFromCharacter(v101.PrimaryPart.Position) < (v102 or 75);
    end;
end;
v15.SetPrimary = function(v132)
	return function(v133, ...)
		local l_Character_0 = l_LocalPlayer_0.Character;
		if not l_Character_0 then
			return;
		else
			for _, v136 in ipairs(v132) do
				if l_Character_0 == v136 then
					if typeof(v133) == "function" then
						v133(...);
						return;
					else
						break;
					end;
				end;
			end;
			return;
		end;
	end;
end;
v15.ToggleImpactFrames = function(v103, v104) --[[ Line: 462 ]] --[[ Name: ToggleImpactFrames ]]
    if v104 then
        v103.AnchorPoint = Vector2.new(0, 1);
        for _, v106 in ipairs(v103:GetDescendants()) do
            if v106:IsA("ImageLabel") then
                v106.Visible = true;
            end;
        end;
        return;
    else
        for _, v108 in ipairs(v103:GetDescendants()) do
            if v108:IsA("ImageLabel") then
                v108.Visible = false;
            end;
        end;
        v103.AnchorPoint = Vector2.zero;
        return;
    end;
end;
v15.EmitImpactFrames = function(v109, v110) --[[ Line: 482 ]] --[[ Name: EmitImpactFrames ]]
    v109.AnchorPoint = Vector2.zero;
    for v111 = 1, #v109:GetChildren() do
        task.wait(1 / (v110 or 24));
        v109[v111].Visible = false;
    end;
end;
return v15;