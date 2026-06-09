-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
local v_u_2 = game:GetService("RunService")
local v_u_3 = game:GetService("Debris")
local v_u_13 = {
	["Linear"] = function(p4)
		return p4
	end,
	["Quad"] = function(p5)
		return p5 * p5
	end,
	["Cubic"] = function(p6)
		return p6 * p6 * p6
	end,
	["Quart"] = function(p7)
		return p7 * p7 * p7 * p7
	end,
	["Quint"] = function(p8)
		return p8 * p8 * p8 * p8 * p8
	end,
	["Sine"] = function(p9)
		local v10 = p9 * 3.141592653589793 / 2
		return 1 - math.cos(v10)
	end,
	["Exp"] = function(p11)
		if p11 == 0 then
			return 0
		end
		local v12 = 10 * (p11 - 1)
		return math.pow(2, v12)
	end
}
local function v_u_17(p14, p15, p16)
	if p16 == "In" then
		return p15(p14)
	elseif p16 == "Out" then
		return 1 - p15(1 - p14)
	elseif p16 == "InOut" then
		if p14 < 0.5 then
			return p15(p14 * 2) / 2
		else
			return 1 - p15((1 - p14) * 2) / 2
		end
	else
		return p14
	end
end
local function v_u_22(p18)
	local v19 = p18:Clone()
	v19.Name = p18.Name .. "_BeamClone"
	local v20 = workspace:FindFirstChild("Thrown")
	if not v20 then
		v20 = Instance.new("Folder")
		v20.Name = "Thrown"
		v20.Parent = workspace
	end
	v19.Parent = v20
	for _, v21 in ipairs(v19:GetDescendants()) do
		if v21:IsA("Beam") then
			v21.Enabled = false
		end
	end
	return v19
end
function v_u_1.new(p23)
	-- upvalues: (copy) v_u_1
	local v24
	if p23 then
		v24 = p23:IsA("BasePart")
	else
		v24 = p23
	end
	assert(v24, "BeamEmit.new requires a BasePart")
	local v25 = v_u_1
	return setmetatable({
		["Object"] = p23
	}, v25)
end
function v_u_1.TweenTextureSpeed(_, p26, p_u_27, p_u_28, p_u_29, p30, p31)
	-- upvalues: (copy) v_u_13, (copy) v_u_17, (copy) v_u_2
	local v_u_32 = v_u_13[p30] or v_u_13.Linear
	local v_u_33 = p31 or "Out"
	for _, v_u_34 in ipairs(p26:GetDescendants()) do
		if v_u_34:IsA("Beam") then
			local v_u_35 = v_u_34.TextureSpeed
			task.spawn(function()
				-- upvalues: (copy) p_u_27, (ref) v_u_17, (copy) v_u_32, (copy) v_u_33, (copy) p_u_28, (copy) p_u_29, (copy) v_u_34, (ref) v_u_2, (copy) v_u_35
				local v36 = tick()
				repeat
					local v37 = (tick() - v36) / p_u_27
					local v38 = math.clamp(v37, 0, 1)
					local v39 = v_u_17(v38, v_u_32, v_u_33)
					v_u_34.TextureSpeed = p_u_28 + (p_u_29 - p_u_28) * v39
					v_u_2.Heartbeat:Wait()
				until v38 >= 1
				v_u_34.TextureSpeed = v_u_35
			end)
		end
	end
end
function v_u_1.FadeBeams(_, p40, p_u_41, p42, p43)
	-- upvalues: (copy) v_u_13, (copy) v_u_17, (copy) v_u_2
	local v_u_44 = v_u_13[p42] or v_u_13.Linear
	local v_u_45 = p43 or "Out"
	for _, v_u_46 in ipairs(p40:GetDescendants()) do
		if v_u_46:IsA("Beam") then
			task.spawn(function()
				-- upvalues: (copy) v_u_46, (copy) p_u_41, (ref) v_u_17, (copy) v_u_44, (copy) v_u_45, (ref) v_u_2
				local v47 = v_u_46.Transparency
				local v48 = v47.Keypoints
				local v49 = {}
				for v50 = 1, #v48 do
					v49[v50] = v48[v50].Value
				end
				local v51 = tick()
				v_u_46.Enabled = true
				while true do
					local v52 = (tick() - v51) / p_u_41
					local v53 = math.clamp(v52, 0, 1)
					local v54 = v_u_17(v53, v_u_44, v_u_45)
					local v55 = {}
					for v56 = 1, #v48 do
						local v57 = v48[v56]
						local v58 = v49[v56] + (1 - v49[v56]) * v54
						v55[v56] = NumberSequenceKeypoint.new(v57.Time, v58, v57.Envelope)
					end
					v_u_46.Transparency = NumberSequence.new(v55)
					v_u_2.Heartbeat:Wait()
					if v53 >= 1 then
						v_u_46.Enabled = false
						v_u_46.Transparency = v47
						return
					end
				end
			end)
		end
	end
end
function v_u_1.ShrinkBeams(_, p59, p_u_60, p61, p62)
	-- upvalues: (copy) v_u_13, (copy) v_u_17, (copy) v_u_2
	local v_u_63 = v_u_13[p61] or v_u_13.Linear
	local v_u_64 = p62 or "Out"
	for _, v_u_65 in ipairs(p59:GetDescendants()) do
		if v_u_65:IsA("Beam") then
			task.spawn(function()
				-- upvalues: (copy) v_u_65, (copy) p_u_60, (ref) v_u_17, (copy) v_u_63, (copy) v_u_64, (ref) v_u_2
				local v66 = v_u_65.Width0
				local v67 = v_u_65.Width1
				v_u_65.Enabled = true
				local v68 = tick()
				repeat
					local v69 = (tick() - v68) / p_u_60
					local v70 = math.clamp(v69, 0, 1)
					local v71 = v_u_17(v70, v_u_63, v_u_64)
					v_u_65.Width0 = v66 * (1 - v71)
					v_u_65.Width1 = v67 * (1 - v71)
					v_u_2.Heartbeat:Wait()
				until v70 >= 1
				v_u_65.Enabled = false
				v_u_65.Width0 = v66
				v_u_65.Width1 = v67
			end)
		end
	end
end
function v_u_1.TweenRotation(_, p_u_72, p_u_73, p74, p75, p76, p77, p78)
	-- upvalues: (copy) v_u_13, (copy) v_u_17, (copy) v_u_2
	local v_u_79 = v_u_13[p77] or v_u_13.Linear
	local v_u_80 = p78 or "Out"
	local v_u_81 = p_u_72.CFrame
	local v_u_82 = math.rad(p74 or 0)
	local v_u_83 = math.rad(p75 or 0)
	local v_u_84 = math.rad(p76 or 0)
	if v_u_82 ~= 0 or (v_u_83 ~= 0 or v_u_84 ~= 0) then
		task.spawn(function()
			-- upvalues: (copy) p_u_73, (ref) v_u_17, (copy) v_u_79, (copy) v_u_80, (copy) p_u_72, (copy) v_u_81, (copy) v_u_82, (copy) v_u_83, (copy) v_u_84, (ref) v_u_2
			local v85 = tick()
			repeat
				local v86 = (tick() - v85) / (p_u_73 > 0 and p_u_73 or 0.001)
				local v87 = math.clamp(v86, 0, 1)
				local v88 = v_u_17(v87, v_u_79, v_u_80)
				p_u_72.CFrame = v_u_81 * CFrame.Angles(v_u_82 * v88, v_u_83 * v88, v_u_84 * v88)
				v_u_2.Heartbeat:Wait()
			until v87 >= 1
		end)
	end
end
function v_u_1.Emit(p89, p90)
	-- upvalues: (copy) v_u_22, (copy) v_u_3
	if p89.Object then
		local v91 = p89.Object
		local v92 = tonumber(v91:GetAttribute("Lifetime")) or 1
		local v93 = v91:GetAttribute("EasingStyle") or "Linear"
		local v94 = tostring(v93)
		local v95 = v91:GetAttribute("EasingDirection") or "Out"
		local v96 = tostring(v95)
		local v97 = v91:GetAttribute("TransparencyEasingStyle") or (v91:GetAttribute("TransparencyEasing Style") or "Linear")
		local v98 = tostring(v97)
		local v99 = v91:GetAttribute("TransparencyEasingDirection") or "Out"
		local v100 = tostring(v99)
		local v101 = v91:GetAttribute("Shrink")
		local v102 = tonumber(v91:GetAttribute("RotX")) or 0
		local v103 = tonumber(v91:GetAttribute("RotY")) or 0
		local v104 = tonumber(v91:GetAttribute("RotZ")) or 0
		local v105 = tonumber(v91:GetAttribute("StartSpeed")) or 0
		local v106 = tonumber(v91:GetAttribute("EndSpeed")) or 0
		local v107 = v_u_22(v91)
		if p90 ~= nil then
			v107.CFrame = p90
		end
		p89:TweenRotation(v107, v92, v102, v103, v104, v94, v96)
		if v105 ~= v106 then
			p89:TweenTextureSpeed(v107, v92, v105, v106, v94, v96)
		end
		if v101 == true or tostring(v101) == "true" then
			p89:ShrinkBeams(v107, v92, v94, v96)
		else
			p89:FadeBeams(v107, v92, v98, v100)
		end
		v_u_3:AddItem(v107, v92 + 0.15)
	end
end
return v_u_1
