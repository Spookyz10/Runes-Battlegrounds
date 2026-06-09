-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v1 = {}
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = require(v2.Packages.Modules.DevModules.Tjanime.EffectsFunctions.Tweening)
function v1.JumpShard(p4, p5, p6, p7)
	-- upvalues: (copy) v_u_3
	v_u_3.TweenProperty(p4, p7, "Cubic", "Out", {
		["Size"] = Vector3.new(0, p5, 0),
		["Position"] = p4.Position + Vector3.new(0, p6, 0)
	}):Play()
end
function v1.FadingSlash(p_u_8, p9, p10, p11, p12, p13)
	-- upvalues: (copy) v_u_3
	local v14 = p10 / 180
	local v15 = math.abs(v14)
	local v16 = p10 < 0 and -180 or 180
	if v15 > 1 then
		local v17 = {}
		for v18 = 1, v15 do
			v17[v18] = v_u_3.TweenProperty(p_u_8, p9 / v15, "Cubic", "Out", {
				["CFrame"] = p_u_8.CFrame * CFrame.Angles(0, math.rad(v16), 0)
			})
		end
		v_u_3.TweenSequence(v17)
	else
		v_u_3.TweenProperty(p_u_8, p9, "Cubic", "Out", {
			["CFrame"] = p_u_8.CFrame * CFrame.Angles(0, math.rad(p10), 0)
		}):Play()
	end
	if p13 == "Size" then
		v_u_3.TweenProperty(p_u_8, p9, "Cubic", "Out", {
			["Size"] = p_u_8.Size * p11
		}):Play()
	else
		v_u_3.TweenProperty(p_u_8.Mesh, p9, "Cubic", "Out", {
			["Scale"] = p_u_8.Mesh.Scale * p11
		}):Play()
	end
	v_u_3.TweenProperty(p_u_8, p9, "Cubic", "Out", {
		["Transparency"] = p12
	}):Play()
	task.delay(p9, function()
		-- upvalues: (copy) p_u_8
		p_u_8:Destroy()
	end)
end
function v1.ShockwaveV1(p_u_19, p20, p_u_21, p22, p23, p_u_24, p_u_25)
	-- upvalues: (copy) v_u_3
	v_u_3.TweenProperty(p_u_19, p20, "Cubic", "Out", {
		["Position"] = p22
	}):Play()
	if p_u_25 == "Size" then
		local v26 = v_u_3.TweenProperty
		local v27 = {}
		local v28 = p_u_19.Size
		local v29 = p23.X
		local v30 = p23.Y
		local v31 = p23.Z
		v27.Size = v28 - Vector3.new(v29, v30, v31)
		v26(p_u_19, p20, "Cubic", "Out", v27):Play()
	else
		local v32 = v_u_3.TweenProperty
		local v33 = p_u_19.Mesh
		local v34 = {}
		local v35 = p_u_19.Mesh.Scale
		local v36 = p23.X
		local v37 = p23.Y
		local v38 = p23.Z
		v34.Scale = v35 - Vector3.new(v36, v37, v38)
		v32(v33, p20, "Cubic", "Out", v34):Play()
	end
	task.delay(p20 - 0.02, function()
		-- upvalues: (copy) p_u_25, (ref) v_u_3, (copy) p_u_19, (copy) p_u_21, (copy) p_u_24
		if p_u_25 == "Size" then
			local v39 = v_u_3.TweenProperty
			local v40 = p_u_19
			local v41 = p_u_21
			local v42 = {}
			local v43 = p_u_19.Size
			local v44 = p_u_24.X
			local v45 = p_u_24.Y
			local v46 = p_u_24.Z
			v42.Size = v43 + Vector3.new(v44, v45, v46)
			v39(v40, v41, "Cubic", "Out", v42):Play()
		else
			local v47 = v_u_3.TweenProperty
			local v48 = p_u_19.Mesh
			local v49 = p_u_21
			local v50 = {}
			local v51 = p_u_19.Mesh.Scale
			local v52 = p_u_24.X
			local v53 = p_u_24.Y
			local v54 = p_u_24.Z
			v50.Scale = v51 + Vector3.new(v52, v53, v54)
			v47(v48, v49, "Cubic", "Out", v50):Play()
		end
		v_u_3.TweenProperty(p_u_19, p_u_21, "Cubic", "Out", {
			["Transparency"] = 1
		}):Play()
		task.delay(p_u_21, function()
			-- upvalues: (ref) p_u_19
			p_u_19:Destroy()
		end)
	end)
end
function v1.JumpSwirl(p55, p56, p57, p58, p59)
	-- upvalues: (copy) v_u_3
	if p59 == "Size" then
		local v60 = v_u_3.TweenProperty
		local v61 = {}
		local v62 = p55.Size
		local v63 = p57.X
		local v64 = p57.Y
		local v65 = p57.Z
		v61.Size = v62 + Vector3.new(v63, v64, v65)
		v60(p55, p56, "Cubic", "Out", v61):Play()
	else
		local v66 = v_u_3.TweenProperty
		local v67 = p55.Mesh
		local v68 = {}
		local v69 = p55.Scale
		local v70 = p57.X
		local v71 = p57.Y
		local v72 = p57.Z
		v68.Scale = v69 + Vector3.new(v70, v71, v72)
		v66(v67, p56, "Cubic", "Out", v68):Play()
	end
	v_u_3.TweenProperty(p55, p56, "Cubic", "Out", {
		["CFrame"] = p55.CFrame * p58,
		["Transparency"] = 1
	}):Play()
end
return v1
