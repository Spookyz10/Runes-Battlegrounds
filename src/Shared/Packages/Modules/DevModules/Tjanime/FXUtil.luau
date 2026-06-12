-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
local function v_u_5(p2, p3)
	for _, v4 in pairs(p2:GetDescendants()) do
		if v4:IsA("Trail") then
			v4.Enabled = p3
		end
	end
end
local function v_u_9(p6, p7)
	for _, v8 in pairs(p6:GetDescendants()) do
		if v8:IsA("ParticleEmitter") then
			v8.Enabled = p7
		end
	end
end
function v_u_1.Emit(_, p10)
	for _, v_u_11 in pairs(p10:GetDescendants()) do
		if v_u_11:IsA("ParticleEmitter") then
			task.delay(v_u_11:GetAttribute("EmitDelay"), function()
				-- upvalues: (copy) v_u_11
				v_u_11:Emit(v_u_11:GetAttribute("EmitCount"))
			end)
		end
		if v_u_11:IsA("Sound") then
			v_u_11:Play()
		end
	end
end
function v_u_1.EmitV2(_, p12)
	for _, v_u_13 in pairs(p12:GetDescendants()) do
		if v_u_13:IsA("ParticleEmitter") and (v_u_13:GetAttribute("EmitDuration") and v_u_13:GetAttribute("EmitDuration") > 0) then
			task.delay(v_u_13:GetAttribute("EmitDelay"), function()
				-- upvalues: (copy) v_u_13
				v_u_13.Enabled = true
				task.delay(v_u_13:GetAttribute("EmitDuration"), function()
					-- upvalues: (ref) v_u_13
					v_u_13.Enabled = false
				end)
			end)
		end
	end
end
function v_u_1.SelectiveEmit(_, p14, p15)
	-- upvalues: (copy) v_u_1
	for _, v_u_16 in pairs(p14:GetDescendants()) do
		if v_u_16.Name == p15 then
			if v_u_16:IsA("ParticleEmitter") then
				task.delay(v_u_16:GetAttribute("EmitDelay"), function()
					-- upvalues: (copy) v_u_16
					v_u_16:Emit(v_u_16:GetAttribute("EmitCount"))
				end)
			else
				v_u_1:Emit(p14)
			end
		end
	end
end
function v_u_1.Enable(_, p17)
	-- upvalues: (copy) v_u_9
	v_u_9(p17, true)
end
function v_u_1.Disable(_, p18)
	-- upvalues: (copy) v_u_9
	v_u_9(p18, false)
end
function v_u_1.EnableBeams(_, p19, p20)
	for _, v21 in pairs(p19:GetDescendants()) do
		if v21:IsA("Beam") then
			v21.Enabled = true
			local v22 = v21.Brightness
			local v23 = v21.LightEmission
			v21.Brightness = 0
			v21.LightEmission = 1
			local v24 = TweenInfo.new(p20)
			game:GetService("TweenService"):Create(v21, v24, {
				["LightEmission"] = v23,
				["Brightness"] = v22
			}):Play()
		end
		if v21:IsA("Trail") then
			v21.Enabled = true
		end
	end
end
local v_u_34 = {
	["Linear"] = function(p25)
		return p25
	end,
	["Quad"] = function(p26)
		return p26 * p26
	end,
	["Cubic"] = function(p27)
		return p27 * p27 * p27
	end,
	["Quart"] = function(p28)
		return p28 * p28 * p28 * p28
	end,
	["Quint"] = function(p29)
		return p29 * p29 * p29 * p29 * p29
	end,
	["Sine"] = function(p30)
		local v31 = p30 * 3.141592653589793 / 2
		return 1 - math.cos(v31)
	end,
	["Exp"] = function(p32)
		if p32 == 0 then
			return 0
		end
		local v33 = 10 * (p32 - 1)
		return math.pow(2, v33)
	end
}
local function v_u_38(p35, p36, p37)
	if p37 == "In" then
		return p36(p35)
	elseif p37 == "Out" then
		return 1 - p36(1 - p35)
	elseif p37 == "InOut" then
		if p35 < 0.5 then
			return p36(p35 * 2) / 2
		else
			return 1 - p36((1 - p35) * 2) / 2
		end
	else
		return p35
	end
end
function v_u_1.DisableBeams(_, p39, p_u_40, p41, p42)
	-- upvalues: (copy) v_u_34, (copy) v_u_38
	local v_u_43 = v_u_34[p41 or "Linear"] or v_u_34.Linear
	local v_u_44 = p42 or "Out"
	for _, v_u_45 in pairs(p39:GetDescendants()) do
		if v_u_45:IsA("Beam") then
			task.spawn(function()
				-- upvalues: (copy) v_u_45, (copy) p_u_40, (ref) v_u_38, (copy) v_u_43, (ref) v_u_44
				local v46 = v_u_45
				local v47 = v46.Transparency.Keypoints
				local v48 = {}
				for v49, v50 in ipairs(v47) do
					v48[v49] = v50.Value
				end
				local v51 = tick()
				while true do
					local v52 = (tick() - v51) / p_u_40
					local v53 = math.clamp(v52, 0, 1)
					local v54 = v_u_38(v53, v_u_43, v_u_44)
					local v55 = {}
					for v56, v57 in ipairs(v47) do
						local v58 = v48[v56] + (1 - v48[v56]) * v54
						v55[v56] = NumberSequenceKeypoint.new(v57.Time, v58)
					end
					v46.Enabled = false
					v46.Transparency = NumberSequence.new(v55)
					v46.Enabled = true
					task.wait()
					if v53 >= 1 then
						warn("Beam effect completed")
						return
					end
				end
			end)
		end
	end
end
function v_u_1.EnableTrails(_, p59)
	-- upvalues: (copy) v_u_5
	v_u_5(p59, true)
end
function v_u_1.DisableTrails(_, p60)
	-- upvalues: (copy) v_u_5
	v_u_5(p60, false)
end
return v_u_1
