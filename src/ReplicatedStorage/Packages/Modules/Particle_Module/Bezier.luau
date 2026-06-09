local v_u_1 = {}
v_u_1.__index = v_u_1

function B(p2, p3, p4)
	local function v_u_6(p5)
		return p5 == 0 and 1 or p5 * v_u_6(p5 - 1)
	end

	local v7 = p2 == 0 and 1 or p2 * v_u_6(p2 - 1)
	local v8 = p3 == 0 and 1 or p3 * v_u_6(p3 - 1)
	local v9 = p2 - p3
	return v7 / (v8 * (v9 == 0 and 1 or v9 * v_u_6(v9 - 1))) * p4 ^ p3 * (1 - p4) ^ (p2 - p3)
end

function v_u_1.new(...)
	local v10 = v_u_1
	local v11 = setmetatable({}, v10)

	v11.Points = {}
	v11.LengthIterations = 1000
	v11.LengthIndeces = {}
	v11.Length = 0
	v11._connections = {}

	for _, v12 in pairs({ ... }) do
		if typeof(v12) == "Vector3" or typeof(v12) == "Instance" and v12:IsA("BasePart") then
			v11:AddBezierPoint(v12)
		else
			print((typeof(v12)))
			error("The Bezier.new() constructor only takes in Vector3s and BaseParts as inputs!")
		end
	end

	return v11
end

function v_u_1.UpdateLength(p43)
	local v44 = p43:GetAllPoints()
	local v45 = p43.LengthIterations
	if #v44 < 2 then
		return 0, {
			{ 0, 0, 0 },
			{ 0, 0, 0 }
		}
	end

	local v46 = 0
	local v47 = {}

	for v48 = 1, v45 do
		local v49 = p43:CalculateDerivativeAt((v48 - 1) / (v45 - 1))
		v46 = v46 + v49.Magnitude * (1 / v45)
		local v50 = { (v48 - 1) / (v45 - 1), v46, v49 }
		table.insert(v47, v50)
	end

	p43.Length = v46
	p43.LengthIndeces = v47
end

function v_u_1.GetAllPoints(p31)
	local v32 = {}
	for v33 = 1, #p31.Points do
		table.insert(v32, p31:GetPoint(v33))
	end

	return v32
end

function v_u_1.GetPoint(p34, p35)
	local v36 = p34.Points
	if v36[p35] then
		local v37 = v36[p35].Point
		return typeof(v37) == "Vector3" and v36[p35].Point or v36[p35].Point.Position
	end

	error("Did not find a BezierPoint at index " .. tostring(p35) .. "!")
end

function v_u_1.CalculateDerivativeAt(p70, p71)
	if type(p71) ~= "number" then
		error("Bezier:CalculateDerivativeAt() only accepts a number, got " .. tostring(p71) .. "!")
	end

	if #p70.Points > 1 then
		local v72 = p70:GetAllPoints()
		local v73 = #v72
		local _ = v73 - 1
		local v74 = Vector3.new()

		for v75 = 1, v73 - 1 do
			local v76 = v72[v75 + 1]
			local v77 = v72[v75]
			local v78 = (v73 - 1) * (v76 - v77)
			v74 = v74 + B(v73 - 2, v75 - 1, p71) * v78
		end
		return v74
	end

	error("Bezier:CalculateDerivativeAt() only works if there are at least 2 BezierPoints!")
end

function v_u_1.AddBezierPoint(p_u_13, p14, p15)
	if p14 and (typeof(p14) == "Instance" and p14:IsA("BasePart")) or typeof(p14) == "Vector3" then
		local v_u_16 = {
			["Type"] = typeof(p14) == "Vector3" and "StaicPoint" or "BasePartPoint",
			["Point"] = p14
		}
		if v_u_16.Type == "BasePartPoint" then
			local v_u_18 = p14.Changed:Connect(function(p17)
				if p17 == "Position" then
					p_u_13:UpdateLength()
				end
			end)

			local v21 = p14.AncestryChanged:Connect(function(_, p19)
				if p19 == nil then
					local v20 = table.find(p_u_13.Points, v_u_16)
					if v20 then
						table.remove(p_u_13.Points, v20)
					end
					v_u_18:Disconnect()
					v_u_18:Disconnect()
				end
			end)

			if not p_u_13._connections[p14] then
				p_u_13._connections[p14] = {}
			end

			local v22 = p_u_13._connections[p14]
			local v23 = v_u_18
			table.insert(v22, v23)

			local v24 = p_u_13._connections[p14]
			table.insert(v24, v21)
		end

		if p15 and type(p15) == "number" then
			local v25 = p_u_13.Points
			table.insert(v25, p15, v_u_16)
		elseif p15 then
			if type(p15) ~= "number" then
				error("Bezier:AddBezierPoint() only accepts an integer as the second argument!")
			end
		else
			local v26 = p_u_13.Points
			table.insert(v26, v_u_16)
		end

		p_u_13:UpdateLength()
	else
		error("Bezier:AddBezierPoint() only accepts a Vector3 or BasePart as the first argument!")
	end
end

function v_u_1.RemoveBezierPoint(p38, p39)
	if p38.Points[p39] then
		local v40 = table.remove(p38.Points, p39)
		local v41 = v40.Point

		if typeof(v41) == "Instance" and v40.Point:IsA("BasePart") then
			for _, v42 in pairs(p38._connections[v40.Point]) do
				if v42.Connected then
					v42:Disconnect()
				end
			end
			p38._connections[v40.Point] = nil
		end

		p38:UpdateLength()
	end
end

function v_u_1.CalculatePositionAt(p51, p52)
	if type(p52) ~= "number" then
		error("Bezier:CalculatePositionAt() only accepts a number, got " .. tostring(p52) .. "!")
	end

	if #p51.Points > 0 then
		local v53 = p51:GetAllPoints()
		local v54 = #v53
		local v55 = Vector3.new()

		for v56 = 1, v54 do
			local v57 = v53[v56]
			v55 = v55 + B(v54 - 1, v56 - 1, p52) * v57
		end

		return v55
	end

	error("Bezier:CalculatePositionAt() only works if there is at least 1 BezierPoint!")
end

function v_u_1.CalculatePositionRelativeToLength(p58, p59)
	if type(p59) ~= "number" then
		error("Bezier:CalculatePositionRelativeToLength() only accepts a number, got " .. tostring(p59) .. "!")
	end

	if #p58.Points <= 0 then
		error("Bezier:CalculatePositionRelativeToLength() only works if there is at least 1 BezierPoint!")
		return
	end

	local v60 = p58.Length
	local v61 = p58.LengthIndeces
	local _ = p58.LengthIterations

	if #p58:GetAllPoints() <= 1 then
		return p58:CalculatePositionAt(0)
	end

	local v62 = v60 * p59
	local v63 = nil
	local v64 = nil

	for v65, v66 in ipairs(v61) do
		if v62 - v66[2] <= 0 or v65 == #v61 then
			v64 = v66
			v63 = v65
			break
		end
	end

	local v67, v68
	if v61[v63 - 1] then
		v67 = p58:CalculatePositionAt(v61[v63 - 1][1])
		v68 = p58:CalculatePositionAt(v64[1])
	else
		v67 = p58:CalculatePositionAt(v64[1])
		v68 = p58:CalculatePositionAt(v61[v63 + 1][1])
	end

	local v69 = (v64[2] - v62) / (v68 - v67).Magnitude
	return v67 + (v68 - v67) * (1 - v69)
end

function v_u_1.CalculateDerivativeRelativeToLength(p79, p80)
	if type(p80) ~= "number" then
		error("Bezier:CalculateDerivativeRelativeToLength() only accepts a number, got " .. tostring(p80) .. "!")
	end

	if #p79.Points <= 1 then
		error("Bezier:CalculateDerivativeRelativeToLength() only works if there are at least 2 BezierPoints!")
		return
	end

	local v81 = p79.Length
	local v82 = p79.LengthIndeces
	local _ = p79.LengthIterations
	p79:GetAllPoints()
	local v83 = v81 * p80
	local v84 = nil
	local v85 = nil

	for v86, v87 in ipairs(v82) do
		if v83 - v87[2] <= 0 or v86 == #v82 then
			v85 = v87
			v84 = v86
			break
		end
	end

	local v88, v89

	if v82[v84 - 1] then
		v88 = p79:CalculateDerivativeAt(v82[v84 - 1][1])
		v89 = p79:CalculateDerivativeAt(v85[1])
	else
		v88 = p79:CalculateDerivativeAt(v85[1])
		v89 = p79:CalculateDerivativeAt(v82[v84 + 1][1])
	end

	local v90 = (v85[2] - v83) / (v89 - v88).Magnitude
	return v88 + (v89 - v88) * (1 - v90)
end

function v_u_1.CreateVector3Tween(p_u_91, p_u_92, p_u_93, p94, p_u_95)
	if #p_u_91.Points == 0 then
		error("Bezier:CreateVector3Tween() only works if there is at least 1 BezierPoint in the Bezier!")
	end

	if typeof(p_u_92) ~= "Instance" and typeof(p_u_92) ~= "table" then
		error("Bezier:CreateVector3Tween() requires an Instance or a table as the first argument!")
	end

	if typeof(p94) ~= "TweenInfo" then
		error("Bezier:CreateVector3Tween() requires a TweenInfo object as the third argument!")
	end

	local v100, v101 = pcall(function()
		local v96 = true
		for _, v97 in pairs(p_u_93) do
			local v98 = p_u_92[v97]
			if typeof(v98) ~= "Vector3" then
				local v99 = p_u_92[v97]
				if typeof(v99) ~= "nil" then
					return false
				end
			end
		end
		return v96
	end)

	if v100 and v101 then
		local v102 = game:GetService("TweenService")
		local v_u_103 = Instance.new("NumberValue")
		local v_u_104 = v102:Create(v_u_103, p94, {
			["Value"] = 1
		})

		local v_u_105 = nil
		v_u_104.Changed:Connect(function(p106)
			if p106 == "PlaybackState" then
				if v_u_104.PlaybackState == Enum.PlaybackState.Playing then
					v_u_105 = v_u_103.Changed:Connect(function(p107)
						for _, v108 in pairs(p_u_93) do
							p_u_92[v108] = p_u_95 and p_u_91:CalculatePositionRelativeToLength(p107) or p_u_91:CalculatePositionAt(p107)
						end
					end)
					return
				end

				if v_u_105 then
					v_u_105:Disconnect()
					v_u_105 = nil
				end
			end
		end)
		return v_u_104
	end

	error("Bezier:CreateVector3Tween() requires a matching property table with Vector3 or nil property names for the object as the second argument!")
end

function v_u_1.CreateCFrameTween(p_u_109, p_u_110, p_u_111, p112, p_u_113, p_u_114)
	if #p_u_109.Points <= 1 then
		error("Bezier:CreateVector3Tween() only works if there are at least 2 BezierPoints in the Bezier!")
	end

	if typeof(p_u_110) ~= "Instance" and typeof(p_u_110) ~= "table" then
		error("Bezier:CreateCFrameTween() requires an Instance or a table as the first argument!")
	end

	if typeof(p112) ~= "TweenInfo" then
		error("Bezier:CreateCFrameTween() requires a TweenInfo object as the third argument!")
	end

	if p_u_114 == nil then
		p_u_114 = CFrame.Angles(0, 0, 0)
	end

	local v119, v120 = pcall(function()
		local v115 = true
		for _, v116 in pairs(p_u_111) do
			local v117 = p_u_110[v116]
			if typeof(v117) ~= "CFrame" then
				local v118 = p_u_110[v116]
				if typeof(v118) ~= "nil" then
					return false
				end
			end
		end
		return v115
	end)

	if v119 and v120 then
		local v121 = game:GetService("TweenService")
		local v_u_122 = Instance.new("NumberValue")
		local v_u_123 = v121:Create(v_u_122, p112, {
			["Value"] = 1
		})
		local v_u_124 = nil

		v_u_123.Changed:Connect(function(p125)
			if p125 == "PlaybackState" then
				if v_u_123.PlaybackState == Enum.PlaybackState.Playing then
					v_u_124 = v_u_122.Changed:Connect(function(p126)
						for _, v127 in pairs(p_u_111) do
							local v128 = p_u_113 and p_u_109:CalculatePositionRelativeToLength(p126) or p_u_109:CalculatePositionAt(p126)
							local v129 = p_u_113 and p_u_109:CalculateDerivativeRelativeToLength(p126) or p_u_109:CalculateDerivativeAt(p126)
							p_u_110[v127] = CFrame.new(v128, v128 + v129) * p_u_114
						end
					end)
					return
				end

				if v_u_124 then
					v_u_124:Disconnect()
					v_u_124 = nil
				end
			end
		end)
		return v_u_123
	end
	error("Bezier:CreateCFrameTween() requires a matching property table with CFrame or nil property names for the object as the second argument!")
end

return v_u_1