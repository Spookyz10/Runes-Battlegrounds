-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v1 = game:GetService("ReplicatedStorage")
local v2 = {}
local v_u_3 = require(v1.Packages.Modules.DevModules.Tjanime.EffectsFunctions.Tweening)
function v2.Wind1(p4, p5, p6, p7, p8, p9, p10, p11)
	-- upvalues: (copy) v_u_3
	local v12 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v13 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v14
	if p9 then
		v14 = p4.Mesh
	else
		v14 = p4
	end
	local v15
	if p10 then
		v15 = p4.Decal
	else
		v15 = p4
	end
	local v16
	if p9 then
		v16 = {}
		local v17 = p4.Mesh.Scale.X * 1.25
		local v18 = p4.Mesh.Scale.Z * 1.25
		v16.Scale = Vector3.new(v17, 0, v18)
	else
		v16 = {}
		local v19 = p4.Size.X * 1.25
		local v20 = p4.Size.Z * 1.25
		v16.Size = Vector3.new(v19, 0, v20)
	end
	v12[p7] = p6 * -10
	v13[p8] = -1.5707963267948966
	v_u_3.TweenProperty(p4, 0.85 / p5, "Exponential", "Out", {
		["CFrame"] = p4.CFrame * CFrame.new(v12.X, v12.Y, v12.Z) * CFrame.Angles(v13.X, v13.Y, v13.Z)
	}):Play()
	v_u_3.TweenProperty(v15, 0.65 / p5, "Quart", "Out", {
		["Transparency"] = 1
	}):Play()
	if p11 then
		v_u_3.TweenProperty(v14, 0.65 / p5, "Quad", "Out", v16):Play()
	end
	return 0.85 / p5
end
function v2.Wind2(p21, p22, p23, p24, p25, p26, p27)
	-- upvalues: (copy) v_u_3
	local v28 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p24] = p23 * -9
	}
	local v29
	if p25 then
		v29 = p21.Mesh
	else
		v29 = p21
	end
	local v30
	if p26 then
		v30 = p21.Decal
	else
		v30 = p21
	end
	v_u_3.TweenProperty(p21, 0.85 / p22, "Exponential", "Out", {
		["CFrame"] = p21.CFrame * CFrame.new(v28.X, v28.Y, v28.Z)
	}):Play()
	local v31
	if p25 then
		v31 = {}
		local v32 = p21.Mesh.Scale.X * 3
		local v33 = p21.Mesh.Scale.Z * 3
		v31.Scale = Vector3.new(v32, 0, v33)
	else
		v31 = {}
		local v34 = p21.Size.X * 3
		local v35 = p21.Size.Z * 3
		v31.Size = Vector3.new(v34, 0, v35)
	end
	v_u_3.TweenProperty(v30, 0.65 / p22, "Quart", "Out", {
		["Transparency"] = 1
	}):Play()
	if p27 then
		v_u_3.TweenProperty(v29, 0.65 / p22, "Exponential", "Out", v31):Play()
	end
	return 0.85 / p22
end
function v2.Wind3(p36, p37, p38, p39, p40, p41)
	-- upvalues: (copy) v_u_3
	local v42
	if p39 then
		v42 = p36.Mesh
	else
		v42 = p36
	end
	local v43
	if p40 then
		v43 = p36.Decal
	else
		v43 = p36
	end
	local v44
	if p39 then
		v44 = {
			["Scale"] = p36.Mesh.Scale * p38
		}
	else
		v44 = {
			["Size"] = p36.Size * p38
		}
	end
	v_u_3.TweenProperty(v43, 0.65 / p37, "Quart", "Out", {
		["Transparency"] = 1
	}):Play()
	if p41 then
		v_u_3.TweenProperty(v42, 0.65 / p37, "Quad", "Out", v44):Play()
	end
	return 0.65 / p37
end
function v2.Wind4(p45, p46, p47, p48, p49, p50, p51)
	-- upvalues: (copy) v_u_3
	local v52 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p48] = p47 * -4
	}
	local v53
	if p49 then
		v53 = p45.Mesh
	else
		v53 = p45
	end
	local v54
	if p50 then
		v54 = p45.Decal
	else
		v54 = p45
	end
	v_u_3.TweenProperty(p45, 0.85 / p46, "Exponential", "Out", {
		["CFrame"] = p45.CFrame * CFrame.new(v52.X, v52.Y, v52.Z)
	}):Play()
	local v55
	if p49 then
		v55 = {}
		local v56 = p45.Mesh.Scale.X * 2
		local v57 = p45.Mesh.Scale.Y * 1.15
		local v58 = p45.Mesh.Scale.Z * 2
		v55.Scale = Vector3.new(v56, v57, v58)
	else
		v55 = {}
		local v59 = p45.Size.X * 2
		local v60 = p45.Size.Y * 1.15
		local v61 = p45.Size.Z * 2
		v55.Size = Vector3.new(v59, v60, v61)
	end
	v_u_3.TweenProperty(v54, 0.65 / p46, "Quart", "Out", {
		["Transparency"] = 1
	}):Play()
	if p51 then
		v_u_3.TweenProperty(v53, 0.65 / p46, "Exponential", "Out", v55):Play()
	end
	return 0.85 / p46
end
function v2.Wind5(p62, p63, p64, p65, p66, p67, p68, p69, p70)
	-- upvalues: (copy) v_u_3
	local v71 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v72
	if p70 then
		v72 = p64 * 6.5
	else
		v72 = p64 * -6.5
	end
	v71[p65] = v72
	local v73
	if p67 then
		v73 = p62.Mesh
	else
		v73 = p62
	end
	local v74
	if p68 then
		v74 = p62.Decal
	else
		v74 = p62
	end
	local v75 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p66] = 6
	}
	v_u_3.TweenProperty(p62, 0.85 / p63, "Exponential", "Out", {
		["CFrame"] = p62.CFrame * CFrame.new(v71.X, v71.Y, v71.Z)
	}):Play()
	local v76
	if p67 then
		v76 = {}
		local v77 = p62.Mesh.Scale.X * v75.X
		local v78 = p62.Mesh.Scale.Y * v75.Y
		local v79 = p62.Mesh.Scale.Z * v75.Z
		v76.Scale = Vector3.new(v77, v78, v79)
	else
		v76 = {}
		local v80 = p62.Size.X * v75.X
		local v81 = p62.Size.Y * v75.Y
		local v82 = p62.Size.Z * v75.Z
		v76.Size = Vector3.new(v80, v81, v82)
	end
	v_u_3.TweenProperty(v74, 0.65 / p63, "Sine", "Out", {
		["Transparency"] = 1
	}):Play()
	if p69 then
		v_u_3.TweenProperty(v73, 0.65 / p63, "Exponential", "Out", v76):Play()
	end
	return 0.85 / p63
end
function v2.Wind6(p83, p84, p85, p86, p87, p88, p89)
	-- upvalues: (copy) v_u_3
	local v90 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p86] = p85 * -2
	}
	local v91
	if p87 then
		v91 = p83.Mesh
	else
		v91 = p83
	end
	local v92
	if p88 then
		v92 = p83.Decal
	else
		v92 = p83
	end
	v_u_3.TweenProperty(p83, 0.85 / p84, "Exponential", "Out", {
		["CFrame"] = p83.CFrame * CFrame.new(v90.X, v90.Y, v90.Z)
	}):Play()
	local v93
	if p87 then
		v93 = {}
		local v94 = p83.Mesh.Scale.X
		local v95 = p83.Mesh.Scale.Y * 3.225
		local v96 = p83.Mesh.Scale.Z
		v93.Scale = Vector3.new(v94, v95, v96)
	else
		v93 = {}
		local v97 = p83.Size.X
		local v98 = p83.Size.Y * 3.225
		local v99 = p83.Size.Z
		v93.Size = Vector3.new(v97, v98, v99)
	end
	v_u_3.TweenProperty(v92, 0.65 / p84, "Sine", "Out", {
		["Transparency"] = 1
	}):Play()
	if p89 then
		v_u_3.TweenProperty(v91, 0.65 / p84, "Exponential", "Out", v93):Play()
	end
	return 0.85 / p84
end
function v2.Wind7(p100, p101, p102, p103, p104, p105, p106, p107, p108, p109)
	-- upvalues: (copy) v_u_3
	local v110 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v111 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v112
	if p109 then
		v112 = p102 * 6.5
	else
		v112 = p102 * -6.5
	end
	v110[p103] = v112
	v111[p105] = 2.0943951023931953
	local v113
	if p106 then
		v113 = p100.Mesh
	else
		v113 = p100
	end
	local v114
	if p107 then
		v114 = p100.Decal
	else
		v114 = p100
	end
	local v115 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p104] = 4.5
	}
	for v116, _ in pairs(v115) do
		if v116 ~= p104 then
			v115[v116] = 1.25
		end
	end
	v_u_3.TweenProperty(p100, 0.85 / p101, "Exponential", "Out", {
		["CFrame"] = p100.CFrame * CFrame.new(v110.X, v110.Y, v110.Z) * CFrame.Angles(v111.X, v111.Y, v111.Z)
	}):Play()
	local v117
	if p106 then
		v117 = {}
		local v118 = p100.Mesh.Scale.X * v115.X
		local v119 = p100.Mesh.Scale.Y * v115.Y
		local v120 = p100.Mesh.Scale.Z * v115.Z
		v117.Scale = Vector3.new(v118, v119, v120)
	else
		v117 = {}
		local v121 = p100.Size.X * v115.X
		local v122 = p100.Size.Y * v115.Y
		local v123 = p100.Size.Z * v115.Z
		v117.Size = Vector3.new(v121, v122, v123)
	end
	v_u_3.TweenProperty(v114, 0.65 / p101, "Sine", "Out", {
		["Transparency"] = 1
	}):Play()
	if p108 then
		v_u_3.TweenProperty(v113, 0.65 / p101, "Exponential", "Out", v117):Play()
	end
	return 0.85 / p101
end
function v2.Wind8(p124, p125, p126, p127, p128, p129, p130, p131, p132)
	-- upvalues: (copy) v_u_3
	local v133 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0
	}
	local v134
	if p132 then
		v134 = p126 * -4
	else
		v134 = p126 * 4
	end
	v133[p127] = v134
	local v135
	if p129 then
		v135 = p124.Mesh
	else
		v135 = p124
	end
	local v136
	if p130 then
		v136 = p124.Decal
	else
		v136 = p124
	end
	local v137 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p128] = 1.45
	}
	for v138, _ in pairs(v137) do
		if v138 ~= p128 then
			v137[v138] = 3.5
		end
	end
	v_u_3.TweenProperty(p124, 0.85 / p125, "Quint", "Out", {
		["CFrame"] = p124.CFrame * CFrame.new(v133.X, v133.Y, v133.Z)
	}):Play()
	local v139
	if p129 then
		v139 = {}
		local v140 = p124.Mesh.Scale.X * v137.X
		local v141 = p124.Mesh.Scale.Y * v137.Y
		local v142 = p124.Mesh.Scale.Z * v137.Z
		v139.Scale = Vector3.new(v140, v141, v142)
	else
		v139 = {}
		local v143 = p124.Size.X * v137.X
		local v144 = p124.Size.Y * v137.Y
		local v145 = p124.Size.Z * v137.Z
		v139.Size = Vector3.new(v143, v144, v145)
	end
	v_u_3.TweenProperty(v136, 0.65 / p125, "Sine", "Out", {
		["Transparency"] = 1
	}):Play()
	if p131 then
		v_u_3.TweenProperty(v135, 0.65 / p125, "Quad", "Out", v139):Play()
	end
	return 0.85 / p125
end
function v2.Wind9(p146, p147, p148, p149, p150, p151, p152, p153)
	-- upvalues: (copy) v_u_3
	local v154
	if p150 then
		v154 = p146.Mesh
	else
		v154 = p146
	end
	local v155
	if p151 then
		v155 = p146.Decal
	else
		v155 = p146
	end
	local v156 = {
		["X"] = 0,
		["Y"] = 0,
		["Z"] = 0,
		[p149] = p153 and 3.12413936106985 or -3.12413936106985
	}
	local v157
	if p150 then
		v157 = {
			["Scale"] = p146.Mesh.Scale * p148
		}
	else
		v157 = {
			["Size"] = p146.Size * p148
		}
	end
	v_u_3.TweenProperty(p146, 1.25 / p147, "Exponential", "Out", {
		["CFrame"] = p146.CFrame * CFrame.Angles(v156.X, v156.Y, v156.Z)
	}):Play()
	v_u_3.TweenProperty(v155, 0.65 / p147, "Quart", "Out", {
		["Transparency"] = 1
	}):Play()
	if p152 then
		v_u_3.TweenProperty(v154, 0.65 / p147, "Quad", "Out", v157):Play()
	end
	return 0.65 / p147
end
return v2
