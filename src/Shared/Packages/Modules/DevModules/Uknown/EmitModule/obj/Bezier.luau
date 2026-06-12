-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
function v_u_1.new(p2, p3)
	-- upvalues: (copy) v_u_1
	local v4 = v_u_1
	local v5 = setmetatable({}, v4)
	v5.points = p2
	v5.accuracy = p3 or 20
	v5.point_count = 0
	v5.cumulative_lengths = {}
	v5:_recalculate()
	return v5
end
function v_u_1.setPoints(p6, p7)
	p6.points = p7
	p6:_recalculate()
end
function v_u_1.getSegmentPoints(p8, p9)
	if p9 < 1 or p8.point_count - 1 < p9 then
		if p9 <= 0 then
			return Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
		end
		error("attempt to get a non-existent segment at index " .. p9)
	end
	local v10 = (p9 - 1) * 4
	local v11 = p9 - 2
	local v12 = v10 - math.max(v11, 0)
	local v13 = math.max(v12, 1)
	return p8.points[v13], p8.points[v13 + 1], p8.points[v13 + 2], p8.points[v13 + 3]
end
function v_u_1.forSample(p14, p15, p16)
	local v17 = p14.length // p15
	if v17 ~= 0 then
		for v18 = 0, v17 do
			p16(p14:getPositionArcSpace(v18 / v17), v18)
		end
	end
end
function v_u_1.getPosition(p19, p20)
	local v21, v22 = p19:getSegmentIndex(p20)
	local v23, v24, v25, v26 = p19:getSegmentPoints(v21)
	return (1 - v22) ^ 3 * v23 + 3 * (1 - v22) ^ 2 * v22 * v24 + 3 * (1 - v22) * v22 ^ 2 * v25 + v22 ^ 3 * v26
end
function v_u_1.getSegmentIndex(p27, p28)
	local v29 = math.clamp(p28, 0, 1)
	local v30 = p27.point_count - 1
	local v31 = v29 * v30
	local v32 = math.floor(v31) + 1
	local v33 = math.min(v32, v30)
	local v34 = v31 - math.floor(v31)
	return v33, v29 == 1 and 1 or v34
end
function v_u_1.getEasedSegmentIndex(p35, p36)
	local v37 = p35.point_count - 1
	local v38 = 1
	for v39 = 1, v37 do
		local v40, _, _, v41 = p35:getSegmentPoints(v39)
		local v42 = v40.x
		local v43 = v41.x
		if v42 <= p36 and p36 < v43 then
			return v39, (p36 - v42) / (v43 - v42)
		end
	end
	return v37, v38
end
function v_u_1.getEase(p44, p45)
	local v46, v47 = p44:getEasedSegmentIndex(p45)
	local v48, v49, v50, v51 = p44:getSegmentPoints(v46)
	for _ = 1, 5 do
		local v52 = v48.x
		local v53 = v49.x
		local v54 = v50.x
		local v55 = v51.x
		local v56 = (1 - v47) ^ 3 * v52 + 3 * (1 - v47) ^ 2 * v47 * v53 + 3 * (1 - v47) * v47 ^ 2 * v54 + v47 ^ 3 * v55
		local v57 = v48.x
		local v58 = v49.x
		local v59 = v50.x
		local v60 = v51.x
		local v61 = 3 * (1 - v47) ^ 2 * (v58 - v57) + 6 * (1 - v47) * v47 * (v59 - v58) + 3 * v47 ^ 2 * (v60 - v59)
		if v61 == 0 then
			break
		end
		local v62 = (v56 - p45) / v61
		local v63 = v47 - v62
		v47 = v63 < 0 and 0 or (v63 > 1 and 1 or v63)
		if math.abs(v62) < 0.001 then
			break
		end
	end
	return (1 - v47) ^ 3 * v48 + 3 * (1 - v47) ^ 2 * v47 * v49 + 3 * (1 - v47) * v47 ^ 2 * v50 + v47 ^ 3 * v51
end
function v_u_1.getPositionArcSpace(p64, p65)
	if p64.length <= 0 then
		return p64.points[1] or Vector3.new(0, 0, 0)
	else
		local v66 = math.clamp(p65, 0, 1) * p64.cumulative_lengths[p64.accuracy + 1]
		local v67 = p64.accuracy + 1
		local v68 = 1
		local v69 = nil
		while v68 < v67 do
			v69 = v68 + (v67 - v68) // 2
			if p64.cumulative_lengths[v69] < v66 then
				v68 = v69 + 1
			else
				v67 = v69
			end
		end
		if v66 < p64.cumulative_lengths[v69] and v69 > 1 then
			v69 = v69 - 1
		end
		local v70 = p64.cumulative_lengths[v69]
		if v70 == v66 then
			return p64:getPosition((v69 - 1) / p64.accuracy)
		else
			return p64:getPosition((v69 - 1 + (v66 - v70) / (p64.cumulative_lengths[v69 + 1] - v70)) / p64.accuracy)
		end
	end
end
function v_u_1._recalculate(p71)
	table.clear(p71.cumulative_lengths)
	local v72 = p71.cumulative_lengths
	table.insert(v72, 0)
	local v73 = #p71.points / 3
	p71.point_count = math.ceil(v73)
	local v74 = nil
	local v75 = 0
	for v76 = 1, p71.accuracy do
		local v77 = p71:getPosition(v76 / p71.accuracy)
		local v78 = v77 - (v74 or p71:getPosition(0))
		v75 = v75 + vector.magnitude(v78)
		local v79 = p71.cumulative_lengths
		table.insert(v79, v75)
		v74 = v77
	end
	p71.length = v75
	for v80, v81 in p71.cumulative_lengths do
		p71.cumulative_lengths[v80] = v81 / v75
	end
end
return v_u_1
