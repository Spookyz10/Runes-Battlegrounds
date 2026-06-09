-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = require(v2.Packages.Modules.DevModules.Tjanime.Welding)
local v_u_4 = require(v2.Packages.Modules.DevModules.Tjanime.EffectsFunctions.Tweening)
local v_u_5 = require(v2.Packages.Modules.DevModules.Tjanime.mesh_emit)
local function v_u_11(p6, p7, p8, p9)
	for _, v10 in pairs(p6:GetDescendants()) do
		if v10:IsA(p7) then
			v10[p8] = p9
		end
	end
end
local function v_u_15(p12, p13)
	for _, v14 in pairs(p12:GetDescendants()) do
		if v14:IsA("Trail") then
			v14.Enabled = p13
		end
	end
end
local function v_u_18(p16)
	-- upvalues: (copy) v_u_5
	for _, v17 in pairs(p16:GetDescendants()) do
		if v17:IsA("Model") and v17:GetAttribute("AttributesAdded") == true then
			v_u_5.new(v17):Emit(v17:GetPivot())
		end
	end
end
local function v_u_22(p19, p20)
	for _, v21 in pairs(p19:GetDescendants()) do
		if v21:IsA("ParticleEmitter") then
			v21.Enabled = p20
		end
	end
end
function v_u_1.SetCollision(p23, p24)
	-- upvalues: (copy) v_u_11
	if p23.Object and p23.Type ~= "Attachment" then
		if p23.Type == "FullMesh" or p23.Type == "ParticlePart" then
			p23.Object.CanCollide = p24
		else
			v_u_11(p23.Object, "BasePart", "CanCollide", p24)
		end
	else
		return
	end
end
function v_u_1.SetSize(p25, p26)
	if p25.Object and p25.Type ~= "Attachment" then
		p25.Object.Size = p26
	end
end
function v_u_1.SetTransparency(p27, p28)
	-- upvalues: (copy) v_u_11
	if p27.Object and p27.Type ~= "Attachment" then
		if p27.Type == "FullMesh" or p27.Type == "ParticlePart" then
			p27.Object.Transparency = p28
		else
			v_u_11(p27.Object, "BasePart", "Transparency", p28)
		end
	else
		return
	end
end
function v_u_1.SetCFrame(p29, p30)
	if p29.Object and p29.Type ~= "Attachment" then
		if p29.Type == "FullMesh" or p29.Type == "ParticlePart" then
			p29.Object.CFrame = p30
		else
			p29.Object:PivotTo(p30)
		end
	else
		return
	end
end
function v_u_1.SetOrientation(p31, p32)
	if p31.Object and (p31.Type ~= "Attachment" and p31.Type ~= "Model") then
		p31.Object.Orientation = p32
	end
end
function v_u_1.SetAttachmentCFrame(p33, p34, p35)
	if p33.Object and p33.Type == "Attachment" then
		if p34 then
			p33.Object.WorldCFrame = p35
		else
			p33.Object.CFrame = p35
		end
	else
		return
	end
end
function v_u_1.SetAttachmentPosition(p36, p37, p38)
	if p36.Object and p36.Type == "Attachment" then
		if p37 then
			p36.Object.WorldPosition = p38
		else
			p36.Object.Position = p38
		end
	else
		return
	end
end
function v_u_1.ParentTo(p39, p40)
	if p39.Object then
		p39.Object.Parent = p40
	end
end
function v_u_1.SetOriginals(p41)
	if p41.Object and p41.Type ~= "Attachment" then
		if p41.Type == "Model" then
			for _, v42 in pairs(p41.Object:GetDescendants()) do
				if v42:IsA("BasePart") then
					local v43 = Instance.new("Vector3Value")
					v43.Name = "OriginalSize"
					v43.Parent = v42
					v43.Value = v42.Size
					local v44 = Instance.new("NumberValue")
					v44.Name = "OriginalTransparency"
					v44.Parent = v42
					v44.Value = v42.Transparency
				end
				if v42:IsA("SpecialMesh") then
					local v45 = Instance.new("Vector3Value")
					v45.Name = "OriginalScale"
					v45.Parent = v42
					v45.Value = v42.scale
				end
			end
			return
		elseif p41.Type == "MeshPart" then
			for _, v46 in pairs(p41.Object:GetDescendants()) do
				if v46:IsA("SpecialMesh") then
					local v47 = Instance.new("Vector3Value")
					v47.Name = "OriginalScale"
					v47.Parent = v46
					v47.Value = v46.scale
				end
			end
			local v48 = p41.Object
			local v49 = Instance.new("Vector3Value")
			v49.Name = "OriginalSize"
			v49.Parent = v48
			v49.Value = v48.Size
			local v50 = Instance.new("NumberValue")
			v50.Name = "OriginalTransparency"
			v50.Parent = v48
			v50.Value = v48.Transparency
		else
			local v51 = p41.Object
			local v52 = Instance.new("Vector3Value")
			v52.Name = "OriginalSize"
			v52.Parent = v51
			v52.Value = v51.Size
			local v53 = Instance.new("NumberValue")
			v53.Name = "OriginalTransparency"
			v53.Parent = v51
			v53.Value = v51.Transparency
		end
	else
		return
	end
end
function v_u_1.Destroy(p_u_54, p55)
	if p_u_54.Object then
		if p55 == nil or p55 <= 0 then
			p_u_54.Object:Destroy()
		else
			task.delay(p55, function()
				-- upvalues: (ref) p_u_54
				p_u_54.Object:Destroy()
			end)
		end
	end
end
function v_u_1.Emit(p56)
	-- upvalues: (copy) v_u_18
	if p56.Object then
		v_u_18(p56.Object)
		for _, v_u_57 in pairs(p56.Object:GetDescendants()) do
			if v_u_57:IsA("ParticleEmitter") then
				task.delay(v_u_57:GetAttribute("EmitDelay"), function()
					-- upvalues: (copy) v_u_57
					v_u_57:Emit(v_u_57:GetAttribute("EmitCount"))
				end)
			end
			if v_u_57:IsA("Sound") then
				v_u_57:Play()
			end
		end
	end
end
function v_u_1.EmitV2(p58)
	if p58.Object then
		for _, v_u_59 in pairs(p58.Object:GetDescendants()) do
			if v_u_59:IsA("ParticleEmitter") and v_u_59:GetAttribute("EmitDuration") then
				task.delay(v_u_59:GetAttribute("EmitDelay"), function()
					-- upvalues: (copy) v_u_59
					if v_u_59:GetAttribute("EmitDuration") > 0 then
						v_u_59.Enabled = true
						task.delay(v_u_59:GetAttribute("EmitDuration"), function()
							-- upvalues: (ref) v_u_59
							v_u_59.Enabled = false
						end)
					end
				end)
			end
		end
	end
end
function v_u_1.SelectiveEmit(p60, p61)
	if p60.Object then
		for _, v_u_62 in pairs(p60.Object:GetDescendants()) do
			if v_u_62.Name == p61 then
				if v_u_62:IsA("ParticleEmitter") then
					task.delay(v_u_62:GetAttribute("EmitDelay"), function()
						-- upvalues: (copy) v_u_62
						v_u_62:Emit(v_u_62:GetAttribute("EmitCount"))
					end)
				else
					p60:Emit()
				end
			end
		end
	end
end
function v_u_1.Enable(p63)
	-- upvalues: (copy) v_u_22
	if p63.Object then
		v_u_22(p63.Object, true)
	end
end
function v_u_1.Disable(p64)
	-- upvalues: (copy) v_u_22
	if p64.Object then
		v_u_22(p64.Object, false)
	end
end
function v_u_1.EnableBeams(p65, _, p66)
	if p65.Object then
		for _, v67 in pairs(p65.Object:GetDescendants()) do
			if v67:IsA("Beam") then
				v67.Enabled = true
				local v68 = v67.Brightness
				local v69 = v67.LightEmission
				v67.Brightness = 0
				v67.LightEmission = 1
				local v70 = TweenInfo.new(p66)
				game:GetService("TweenService"):Create(v67, v70, {
					["LightEmission"] = v69,
					["Brightness"] = v68
				}):Play()
			end
			if v67:IsA("Trail") then
				v67.Enabled = true
			end
		end
	end
end
local v_u_80 = {
	["Linear"] = function(p71)
		return p71
	end,
	["Quad"] = function(p72)
		return p72 * p72
	end,
	["Cubic"] = function(p73)
		return p73 * p73 * p73
	end,
	["Quart"] = function(p74)
		return p74 * p74 * p74 * p74
	end,
	["Quint"] = function(p75)
		return p75 * p75 * p75 * p75 * p75
	end,
	["Sine"] = function(p76)
		local v77 = p76 * 3.141592653589793 / 2
		return 1 - math.cos(v77)
	end,
	["Exp"] = function(p78)
		if p78 == 0 then
			return 0
		end
		local v79 = 10 * (p78 - 1)
		return math.pow(2, v79)
	end
}
local function v_u_84(p81, p82, p83)
	if p83 == "In" then
		return p82(p81)
	elseif p83 == "Out" then
		return 1 - p82(1 - p81)
	elseif p83 == "InOut" then
		if p81 < 0.5 then
			return p82(p81 * 2) / 2
		else
			return 1 - p82((1 - p81) * 2) / 2
		end
	else
		return p81
	end
end
function v_u_1.DisableBeams(p85, p_u_86, p87, p88)
	-- upvalues: (copy) v_u_80, (copy) v_u_84
	if p85.Object then
		local v_u_89 = v_u_80[p87 or "Linear"] or v_u_80.Linear
		local v_u_90 = p88 or "Out"
		for _, v_u_91 in pairs(p85.Object:GetDescendants()) do
			if v_u_91:IsA("Beam") then
				task.spawn(function()
					-- upvalues: (copy) v_u_91, (copy) p_u_86, (ref) v_u_84, (copy) v_u_89, (ref) v_u_90
					local v92 = v_u_91.Transparency
					local v93 = v_u_91
					local v94 = v93.Transparency.Keypoints
					local v95 = {}
					for v96, v97 in ipairs(v94) do
						v95[v96] = v97.Value
					end
					local v98 = tick()
					while true do
						local v99 = (tick() - v98) / p_u_86
						local v100 = math.clamp(v99, 0, 1)
						local v101 = v_u_84(v100, v_u_89, v_u_90)
						local v102 = {}
						for v103, v104 in ipairs(v94) do
							local v105 = v95[v103] + (1 - v95[v103]) * v101
							v102[v103] = NumberSequenceKeypoint.new(v104.Time, v105)
						end
						v93.Transparency = NumberSequence.new(v102)
						task.wait()
						if v100 >= 1 then
							v93.Enabled = false
							v93.Transparency = v92
							return
						end
					end
				end)
			end
		end
	end
end
function v_u_1.SlowBeams(p106, p107, p108, p109, p110, p111)
	-- upvalues: (copy) v_u_4
	if p106.Object then
		for _, v112 in pairs(p106.Object:GetDescendants()) do
			if v112:IsA("Beam") then
				local v113 = v_u_4.TweenProperty
				local v114 = {}
				local v115
				if p111 then
					v115 = v112.TextureSpeed / p110
				else
					v115 = p110
				end
				v114.TextureSpeed = v115
				v113(v112, p107, p108, p109, v114):Play()
			end
		end
	end
end
function v_u_1.EnableBeamsV2(p116, p_u_117, p118, p119, p_u_120)
	-- upvalues: (copy) v_u_80, (copy) v_u_84
	if p116.Object then
		local v_u_121 = v_u_80[p118 or "Linear"] or v_u_80.Linear
		local v_u_122 = p119 or "Out"
		for _, v_u_123 in pairs(p116.Object:GetDescendants()) do
			if v_u_123:IsA("Beam") then
				task.spawn(function()
					-- upvalues: (copy) v_u_123, (copy) p_u_120, (copy) p_u_117, (ref) v_u_84, (copy) v_u_121, (ref) v_u_122
					local v124 = v_u_123
					local v125 = v124.Transparency.Keypoints
					local v126 = p_u_120
					local v127 = typeof(v126) == "NumberSequence"
					local v128 = v127 and p_u_120.Keypoints or nil
					local v129 = {}
					local v130 = {}
					for v131, v132 in ipairs(v125) do
						v129[v131] = NumberSequenceKeypoint.new(v132.Time, 1)
						local v133 = p_u_120
						local v134
						if typeof(v133) == "number" then
							v134 = p_u_120
						elseif v127 and v128[v131] then
							v134 = v128[v131].Value
						else
							v134 = v132.Value
						end
						v130[v131] = NumberSequenceKeypoint.new(v132.Time, v134)
					end
					v124.Transparency = NumberSequence.new(v129)
					v124.Enabled = true
					local v135 = tick()
					while true do
						local v136 = (tick() - v135) / p_u_117
						local v137 = math.clamp(v136, 0, 1)
						local v138 = v_u_84(v137, v_u_121, v_u_122)
						local v139 = {}
						for v140 = 1, #v129 do
							local v141 = v129[v140].Value
							local v142 = v141 + (v130[v140].Value - v141) * v138
							v139[v140] = NumberSequenceKeypoint.new(v129[v140].Time, v142)
						end
						v124.Transparency = NumberSequence.new(v139)
						task.wait()
						if v137 >= 1 then
							v124.Transparency = NumberSequence.new(v130)
							return
						end
					end
				end)
			end
		end
	end
end
function v_u_1.EnableTrails(p143, p144)
	-- upvalues: (copy) v_u_15
	if p143.Object then
		v_u_15(p144, true)
	end
end
function v_u_1.DisableTrails(p145, p146)
	-- upvalues: (copy) v_u_15
	if p145.Object then
		v_u_15(p146, false)
	end
end
function v_u_1.WeldTo(p147, p148, p149, p150)
	-- upvalues: (copy) v_u_3
	if p147.Object and p147.Type ~= "Attachment" then
		local v151 = nil
		if p149 == "Normal" then
			return v_u_3.NormalWeld(p148, p147.Object, p150, p148.Name)
		end
		if p149 == "Constraint" then
			return v_u_3.WeldConstraint(p148, p147.Object, p148.Name)
		end
		if p149 == "Motor6D" then
			v151 = v_u_3.Motor6D(p148, p147.Object, p150, p148.Name)
		end
		return v151
	end
end
function v_u_1.CreateEffect(p152, p153, p154, p155)
	-- upvalues: (copy) v_u_1
	local v156 = {
		["Type"] = p152,
		["Object"] = p153:Clone()
	}
	local v157 = v_u_1
	local v158 = setmetatable(v156, v157)
	v158:SetCFrame(p154)
	v158:ParentTo(p155)
	v158:SetOriginals()
	return v158
end
return v_u_1
