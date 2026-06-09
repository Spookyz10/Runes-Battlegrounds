local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local _ = game:GetService("RunService");
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer;
local v5 = require(l_ReplicatedStorage_0.Modules.Blood);
local v15 = {
    Arc = require(script.Arc), 
    Toggle = function(v8, v9, v10) --[[ Line: 22 ]] --[[ Name: Toggle ]]
        assert(v8, "No Item");
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
};
v15.Weld = require(script.FakeWeld).new;
v15.Emit = function(v26, v27) --[[ Name: Emit ]]
	-- upvalues: v5 (copy)
	local v28 = false;
	local v29 = nil;
	local v30 = 0;
	local v31 = {};
	local function v33(v32) --[[ Name: UpdateLifetime ]]
		-- upvalues: v29 (ref), v30 (ref), v28 (ref), v26 (copy)
		if v29 then
			task.cancel(v29);
		end;
		v30 = math.max(v30, v32);
		if v28 then
			v29 = task.delay(v30, v26.Destroy, v26);
		end;
	end;
	for _, v35 in ipairs(v26:GetDescendants()) do
		if v35:IsA("ParticleEmitter") and v5.ParticleSupportsBlood(v35) then
			v35.Name = "Particle";
			v31[v35] = true;
			if v35:GetAttribute("EmitDuration") ~= nil and v35:GetAttribute("EmitDuration") ~= 0 then
				v35.Enabled = true;
				task.delay(v35:GetAttribute("EmitDuration"), function()
					-- upvalues: v35 (copy)
					v35.Enabled = false;
				end);
				local v36 = (v35:GetAttribute("EmitDuration") + (v35.Lifetime.Min + v35.Lifetime.Max)) / v35.TimeScale;
				if v29 then
					task.cancel(v29);
				end;
				v30 = math.max(v30, v36);
				if v28 then
					v29 = task.delay(v30, v26.Destroy, v26);
				end;
			else
				local v37 = v35:GetAttribute("EmitCount") or 1;
				local v38 = v35:GetAttribute("EmitDelay") or 0;
				if v38 ~= 0 then
					task.delay(v38, v35.Emit, v35, v37);
					local v39 = (v38 + (v35.Lifetime.Min + v35.Lifetime.Max)) / v35.TimeScale;
					if v29 then
						task.cancel(v29);
					end;
					v30 = math.max(v30, v39);
					if v28 then
						v29 = task.delay(v30, v26.Destroy, v26);
					end;
				else
					v35:Emit(v37);
					local v40 = (v35.Lifetime.Min + v35.Lifetime.Max) / v35.TimeScale;
					if v29 then
						task.cancel(v29);
					end;
					v30 = math.max(v30, v40);
					if v28 then
						v29 = task.delay(v30, v26.Destroy, v26);
					end;
				end;
			end;
		elseif v35:IsA("Sound") then
			v35.Name = "Sound";
			local l_IsLoaded_1 = v35.IsLoaded;
			local function v42() --[[ Name: Play ]]
				-- upvalues: v33 (copy), v35 (copy)
				if v33 then
					v33(v35.TimeLength);
				end;
				v35:Play();
			end;
			if not l_IsLoaded_1 then
				v35.Loaded:Once(v42);
			else
				if v33 then
					local l_TimeLength_0 = v35.TimeLength;
					if v29 then
						task.cancel(v29);
					end;
					v30 = math.max(v30, l_TimeLength_0);
					if v28 then
						v29 = task.delay(v30, v26.Destroy, v26);
					end;
				end;
				v35:Play();
			end;
			if not l_IsLoaded_1 then
				if v29 then
					task.cancel(v29);
				end;
				v30 = math.max(v30, 60);
				if v28 then
					v29 = task.delay(v30, v26.Destroy, v26);
				end;
			end;
			v31[v35] = true;
		end;
	end;
	if not v27 then
		v28 = true;
		local l_v30_0 = v30;
		if v29 then
			task.cancel(v29);
		end;
		v30 = math.max(v30, l_v30_0);
		if v28 then
			v29 = task.delay(v30, v26.Destroy, v26);
		end;
	end;
	return v31, v30;
end;
return v15;