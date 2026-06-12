-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v1 = {}
local function v_u_16(p2, p3)
	local v4 = #p3 - 1
	local v5 = Vector3.new()
	for v6 = 0, v4 do
		local v7 = 1 - p2
		local v8 = v4 - v6
		local v9 = math.pow(v7, v8) * math.pow(p2, v6)
		local v10
		if v6 == 0 or v6 == v4 then
			v10 = 1
		elseif v4 < v6 then
			v10 = 0
		else
			local v11 = 1
			for v12 = v4, v4 - v6 + 1, -1 do
				v11 = v11 * v12
			end
			local v13 = 1
			for v14 = 1, v6 do
				v13 = v13 * v14
			end
			v10 = v11 / v13
		end
		local v15 = v9 * v10
		v5 = v5 + p3[v6 + 1] * v15
	end
	return v5
end
local function v_u_27(p17, p18, p19)
	-- upvalues: (copy) v_u_16
	local v20 = tick()
	local v21 = 0
	while v21 < p19 and p17:GetAttribute("HitboxHit") == nil do
		local v22 = (v21 + 0.01) / p19
		local v23 = math.min(1, v22)
		local v24 = v21 / p19
		local v25 = v_u_16(math.min(1, v24), p18)
		local v26 = v_u_16(v23, p18)
		p17.Position = v25
		p17.CFrame = CFrame.lookAt(p17.Position, v26)
		task.wait(0.01)
		v21 = tick() - v20
	end
end
function v1.GenerateBezierPoints(p28, p29)
	-- upvalues: (copy) v_u_16
	local v30 = {}
	for v31 = 0, p29 do
		local v32 = v_u_16(v31 / p29, p28)
		table.insert(v30, v32)
	end
	return v30
end
function v1.CreateBezier(p_u_33, p_u_34, p_u_35, p_u_36)
	-- upvalues: (copy) v_u_27
	task.spawn(function()
		-- upvalues: (ref) v_u_27, (copy) p_u_33, (copy) p_u_35, (copy) p_u_34, (copy) p_u_36
		v_u_27(p_u_33, p_u_35, p_u_34)
		if p_u_36 then
			p_u_36()
		end
	end)
end
function v1.CreateRandomBezier(p_u_37, p_u_38, p_u_39, p40, p41, p_u_42, p_u_43)
	-- upvalues: (copy) v_u_27
	local v_u_44 = nil
	local v45 = CFrame.lookAt(p_u_39, p40)
	local v46 = v45.RightVector * math.random(-p41, p41)
	local v47 = math.random(0, p41)
	local v48 = v45.UpVector * v47
	local v_u_49, v_u_50
	if p_u_38 == "Quadratic" then
		v_u_49 = p40
		v_u_50 = p_u_39:Lerp(v_u_49, math.random(10, 90) * 0.01) + v46 + v48
	else
		v_u_50 = nil
		v_u_49 = nil
	end
	if p_u_38 == "Cubic" then
		v_u_44 = p40
		local v51 = math.random(10, 35) * 0.01
		local v52 = math.random(40, 65) * 0.01
		local v53 = v45.RightVector * math.random(-p41, p41)
		local v54 = v45.UpVector * math.random(-v47, p41)
		v_u_50 = p_u_39:Lerp(v_u_44, v51) + v46 + v48
		v_u_49 = p_u_39:Lerp(v_u_44, v52) + v53 + v54
	end
	task.spawn(function()
		-- upvalues: (copy) p_u_38, (copy) p_u_39, (ref) v_u_50, (ref) v_u_49, (ref) v_u_44, (ref) v_u_27, (copy) p_u_37, (copy) p_u_42, (copy) p_u_43
		local v55 = nil
		local v56
		if p_u_38 == "Quadratic" then
			v56 = { p_u_39, v_u_50, v_u_49 }
		else
			v56 = p_u_38 == "Cubic" and {
				p_u_39,
				v_u_50,
				v_u_49,
				v_u_44
			} or v55
		end
		v_u_27(p_u_37, v56, p_u_42)
		if p_u_43 then
			p_u_43()
		end
	end)
end
return v1
