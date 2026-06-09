-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("./utility")
local v_u_116 = {
	["getSurfaceCFrame"] = function(p2, p3, p4)
		local v5 = p3:Dot(Vector3.new(0, 1, 0))
		local v6 = math.abs(v5) > 0.99 and Vector3.new(0, 0, 1) or Vector3.new(0, 1, 0)
		local v7 = CFrame.lookAt(Vector3.new(0, 0, 0), p3, v6)
		return p2 * CFrame.new(p4) * v7
	end,
	["getPointWithinBox"] = function(p8, p9, p10, p11)
		-- upvalues: (copy) v_u_116
		debug.profilebegin("getPointWithinBox")
		local v12 = Random.new(p8)
		local v13 = p10 / 2
		local v14 = v12:NextNumber(-1, 1)
		local v15 = v12:NextNumber(-1, 1)
		local v16 = Vector3.new(v14, v15, v12:NextNumber(-1, 1)) * v13
		local v17 = v_u_116.getSurfaceCFrame(p9, Vector3.FromNormalId(p11), v16)
		debug.profileend()
		return v17
	end,
	["getPointOnBox"] = function(p18, p19, p20, p21)
		-- upvalues: (copy) v_u_116
		debug.profilebegin("getPointOnBox")
		local v22 = Random.new(p18)
		local v23 = Vector3.FromNormalId(p21)
		local v24 = p20 / 2
		local v25 = Vector3.new(1, 1, 1) - v23:Abs()
		local v26 = v22:NextNumber(-1, 1)
		local v27 = v22:NextNumber(-1, 1)
		local v28 = Vector3.new(v26, v27, v22:NextNumber(-1, 1)) * v24 * v25
		local v29 = v_u_116.getSurfaceCFrame(p19, v23, v28 + v23 * v24)
		debug.profileend()
		return v29
	end,
	["getPointWithinCylinder"] = function(p30, p31, p32, p33, p34, p35)
		-- upvalues: (copy) v_u_1
		debug.profilebegin("getPointWithinCylinder")
		local v36 = Random.new(p30)
		local v37 = v36:NextNumber(p31, 1)
		local v38 = math.sqrt(v37)
		local v39 = v36:NextNumber(0, 6.283185307179586)
		if p35 == Enum.NormalId.Left or p35 == Enum.NormalId.Right then
			p33 = p33 * CFrame.fromOrientation(0, 1.5707963267948966 * (p35 == Enum.NormalId.Right and -1 or 1), 0)
			local v40 = p34.Z
			local v41 = p34.Y
			local v42 = p34.X
			p34 = Vector3.new(v40, v41, v42)
		elseif p35 == Enum.NormalId.Front or p35 == Enum.NormalId.Back then
			p33 = p33 * CFrame.fromOrientation(0, 3.141592653589793, 0)
		end
		local v43 = 1 - v36:NextNumber() ^ v_u_1.lerp(0.5, 1, (math.sqrt(p32)))
		local v44 = v_u_1.lerp(1, p32, v43)
		local v45 = v43 * 2 - 1
		local v46 = v38 * math.sin(v39) * v44
		local v47 = v38 * math.cos(v39) * v44
		local v48 = Vector3.new(v45, v46, v47) * p34 / 2
		local v49 = math.sin(v39) * v44
		local v50 = math.cos(v39) * v44
		local v51 = Vector3.new(0, v49, v50) * p34 / 2
		local v52 = v51.Unit
		local v53 = p33.UpVector
		local v54 = (v52 ~= v52 and Vector3.new(0, 0, 0) or v52).Y
		if math.abs(v54) > 0.999 then
			if p35 == Enum.NormalId.Left or p35 == Enum.NormalId.Right then
				v53 = p33.RightVector
			else
				v53 = p33.LookVector
			end
		end
		local v55 = p33 * CFrame.new(v48) * CFrame.lookAt(Vector3.new(0, 0, 0), v51, v53)
		debug.profileend()
		return v55
	end,
	["getPointWithinSphere"] = function(p56, p57, p58, p59, p60, p61)
		-- upvalues: (copy) v_u_116
		debug.profilebegin("getPointWithinSphere")
		local v62 = Random.new(p56)
		local v63 = v62:NextNumber()
		local v64 = v62:NextNumber()
		local v65 = v63 * 2 * 3.141592653589793
		local v66 = 2 * v64 - 1
		local v67 = math.acos(v66) * p58
		local v68 = v62:NextNumber(p57, 1) ^ 0.3333333333333333
		local v69 = math.sin(v65)
		local v70 = math.cos(v65)
		local v71 = math.sin(v67)
		local v72 = math.cos(v67)
		local v73 = Vector3.FromNormalId(p61)
		if p61 == Enum.NormalId.Left or p61 == Enum.NormalId.Right then
			local v74 = p60.Z
			local v75 = p60.Y
			local v76 = p60.X
			p60 = Vector3.new(v74, v75, v76)
		elseif p61 == Enum.NormalId.Top or p61 == Enum.NormalId.Bottom then
			local v77 = p60.X
			local v78 = p60.Z
			local v79 = p60.Y
			p60 = Vector3.new(v77, v78, v79)
		end
		local v80 = p60 / 2
		local v81 = v_u_116.getSurfaceCFrame(p59, v73, Vector3.new(0, 0, 0))
		local v82 = v68 * v71 * v70
		local v83 = v68 * v71 * v69
		local v84 = v68 * v72
		local v85 = Vector3.new(v82, v83, v84) * v80
		local v86 = v85.Unit
		local v87 = p59.UpVector
		local v88 = (v86 ~= v86 and Vector3.new(0, 0, 0) or v86).Y
		if math.abs(v88) > 0.999 then
			if p61 == Enum.NormalId.Left or p61 == Enum.NormalId.Right then
				v87 = p59.RightVector
			else
				v87 = p59.LookVector
			end
		end
		local v89 = v81 * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(v85) * CFrame.lookAt(Vector3.new(0, 0, 0), v85, v87)
		debug.profileend()
		return v89
	end,
	["getPointWithinDisc"] = function(p90, p91, p92, p93, p94, p95)
		-- upvalues: (copy) v_u_1, (copy) v_u_116
		debug.profilebegin("getPointWithinDisc")
		local v96 = Random.new(p90)
		local v97 = Vector3.FromNormalId(p95)
		local v98 = Vector3.new(1, 1, 1) - v97:Abs() * p91
		local v99 = p94 / 2
		local v100 = v96:NextNumber(p91, 1)
		local v101 = v_u_1.lerp(1, 0.5, p92 ^ 4)
		local v102 = v96:NextNumber(1 - p92, 1) ^ v101
		local v103 = v96:NextNumber(0, 6.283185307179586)
		local v104 = v100 * 2 - 1
		local v105 = v102 * math.sin(v103)
		local v106 = v102 * math.cos(v103)
		local v107 = Vector3.new(v104, v105, v106)
		if p95 == Enum.NormalId.Bottom or p95 == Enum.NormalId.Top then
			local v108 = v107.Z
			local v109 = v107.X
			local v110 = v107.Y
			v107 = Vector3.new(v108, v109, v110)
		elseif p95 == Enum.NormalId.Front or p95 == Enum.NormalId.Back then
			local v111 = v107.Y
			local v112 = v107.Z
			local v113 = v107.X
			v107 = Vector3.new(v111, v112, v113)
		end
		local v114 = v107 * (v99 * v98)
		local v115 = v_u_116.getSurfaceCFrame(p93, v97, v114 + v97 * p91 * v99)
		debug.profileend()
		return v115
	end
}
return v_u_116
