local v1 = {}
game:GetService("Debris")
local v2 = game:GetService("ReplicatedStorage").Packages.Modules.DevModules.Tjanime
local v_u_3 = require(v2.EffectsFunctions.Tweening)
local v_u_4 = require(v2.LoopService)

local function v_u_13(p5)
	local v6 = workspace.CurrentCamera
	local v7 = v6.CFrame.LookVector.X
	local v8 = v6.CFrame.LookVector.Z
	local v9 = Vector3.new(v7, 0, v8).Unit
	local v10 = v6.CFrame.RightVector.X
	local v11 = v6.CFrame.RightVector.Z
	local v12 = Vector3.new(v10, 0, v11).Unit
	if p5 == "W" then
		return v9
	elseif p5 == "S" then
		return -v9
	elseif p5 == "A" then
		return -v12
	else
		return p5 ~= "D" and Vector3.new(0, 0, 0) or v12
	end
end
function v1.MakeVelocity(p14, p15, p16, p17, p18)
	local v19 = p17 or Instance.new("Attachment")
	v19.Name = "LinearVelocityAttachment"
	v19.Parent = p14
	local v20 = Instance.new("LinearVelocity")
	v20.Attachment0 = v19
	v20.RelativeTo = Enum.ActuatorRelativeTo.World
	v20.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v20.VectorVelocity = p15
	v20.ForceLimitsEnabled = true
	if typeof(p16) == "Vector3" then
		v20.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		v20.MaxAxesForce = p16
	else
		v20.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v20.MaxForce = p16
	end
	v20.Parent = p14
	local v_u_23 = {
		["Velocity"] = v20,
		["Attachment"] = v19,
		["Destroy"] = function(p21)
			if p21.Velocity then
				p21.Velocity:Destroy()
			end
			if p21.Attachment then
				p21.Attachment:Destroy()
			end
			for v22 in pairs(p21) do
				p21[v22] = nil
			end
		end
	}
	if p18 ~= nil and typeof(p18) == "number" then
		task.delay(p18, function()
			-- upvalues: (ref) v_u_23
			if v_u_23.Velocity then
				v_u_23.Velocity:Destroy()
			end
			if v_u_23.Attachment then
				v_u_23.Attachment:Destroy()
			end
			if v_u_23 then
				v_u_23 = nil
			end
		end)
	end
	return v_u_23
end
function v1.TweenVelocity(p24, p25, p26, p27, p28, p29, p30, p31, p32)
	-- upvalues: (copy) v_u_3
	local v33 = p32 or Instance.new("Attachment")
	v33.Name = "LinearVelocityAttachment"
	if p32 == nil then
		v33.Parent = p24
	end
	local v34 = p31 or Instance.new("LinearVelocity")
	v34.Attachment0 = v33
	v34.RelativeTo = Enum.ActuatorRelativeTo.World
	v34.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v34.VectorVelocity = p25
	v34.ForceLimitsEnabled = true
	if typeof(p27) == "Vector3" then
		v34.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		v34.MaxAxesForce = p27
	else
		v34.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v34.MaxForce = p27
	end
	if p31 == nil then
		v34.Parent = p24
	end
	return {
		["Velocity"] = v34,
		["Attachment"] = v33,
		["Tween"] = v_u_3.TweenProperty(v34, p30, p28, p29, {
			["VectorVelocity"] = p26
		}),
		["Destroy"] = function(p35)
			if p35.Tween then
				p35.Tween:Destroy()
			end
			if p35.Velocity then
				p35.Velocity:Destroy()
			end
			if p35.Attachment then
				p35.Attachment:Destroy()
			end
			for v36 in pairs(p35) do
				p35[v36] = nil
			end
		end
	}
end
function v1.TweenVelocityConstant(p_u_37, p_u_38, p39, p40, p41, p42, p43, p44, p45, p46, p47, p48)
	-- upvalues: (copy) v_u_3, (copy) v_u_4
	local v49 = p47 or Instance.new("Attachment")
	v49.Name = "LinearVelocityAttachment"
	if p47 == nil then
		v49.Parent = p_u_37
	end
	local v_u_50 = Instance.new("NumberValue")
	v_u_50.Value = p39
	local v_u_51 = p46 or Instance.new("LinearVelocity")
	v_u_51.Attachment0 = v49
	v_u_51.RelativeTo = Enum.ActuatorRelativeTo.World
	v_u_51.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v_u_51.VectorVelocity = (p48 or p_u_37).CFrame[p_u_38] * v_u_50.Value
	v_u_51.ForceLimitsEnabled = true
	if typeof(p41) == "Vector3" then
		v_u_51.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		v_u_51.MaxAxesForce = p41
	else
		v_u_51.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v_u_51.MaxForce = p41
	end
	if p46 == nil then
		v_u_51.Parent = p_u_37
	end
	local v52 = v_u_3.TweenProperty(v_u_50, p44, p42, p43, {
		["Value"] = p40
	})
	local v_u_53 = v_u_4.LoopWithFunctions(0.025, {
		{
			["Iterations"] = 1,
			["Function"] = function()
				-- upvalues: (copy) v_u_51, (copy) p_u_37, (copy) p_u_38, (copy) v_u_50
				v_u_51.VectorVelocity = p_u_37.CFrame[p_u_38] * v_u_50.Value
			end
		}
	})
	task.delay(p45, function()
		-- upvalues: (copy) v_u_53
		v_u_53:EndLoop()
	end)
	return {
		["Velocity"] = v_u_51,
		["Attachment"] = v49,
		["Tween"] = v52,
		["Loop"] = v_u_53,
		["Destroy"] = function(p54)
			if p54.Tween then
				p54.Tween:Destroy()
			end
			if p54.Velocity then
				p54.Velocity:Destroy()
			end
			if p54.Attachment then
				p54.Attachment:Destroy()
			end
			if p54.Loop then
				p54.Loop:EndLoop()
			end
			for v55 in pairs(p54) do
				p54[v55] = nil
			end
		end
	}
end
function v1.Dash(p56, p_u_57, p58, p59, p60, p61, p62, p63, p64, p65, p66, _)
	-- upvalues: (copy) v_u_13, (copy) v_u_3, (copy) v_u_4
	local v67 = p66 or Instance.new("Attachment")
	v67.Name = "LinearVelocityAttachment"
	if v67.Parent == nil then
		v67.Parent = p56
	end
	local v_u_68 = Instance.new("NumberValue")
	v_u_68.Value = p58
	local v_u_69 = p65 or Instance.new("LinearVelocity")
	v_u_69.Attachment0 = v67
	v_u_69.RelativeTo = Enum.ActuatorRelativeTo.World
	v_u_69.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v_u_69.ForceLimitsEnabled = true
	if typeof(p60) == "Vector3" then
		v_u_69.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		v_u_69.MaxAxesForce = p60
	else
		v_u_69.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v_u_69.MaxForce = p60
	end
	local v70 = Vector3.new(0, 0, 0)
	if typeof(p_u_57) == "string" then
		v70 = v_u_13(p_u_57)
	elseif typeof(p_u_57) == "Vector3" then
		v70 = p_u_57
	end
	v_u_69.VectorVelocity = v70 * v_u_68.Value
	if v_u_69.Parent == nil then
		v_u_69.Parent = p56
	end
	local v71 = v_u_3.TweenProperty(v_u_68, p63, p61, p62, {
		["Value"] = p59
	})
	local v73 = {
		{
			["Iterations"] = 1,
			["Function"] = function()
				-- upvalues: (copy) p_u_57, (copy) v_u_69, (ref) v_u_13, (copy) v_u_68
				local v72 = p_u_57
				if typeof(v72) == "string" then
					v_u_69.VectorVelocity = v_u_13(p_u_57) * v_u_68.Value
				else
					v_u_69.VectorVelocity = p_u_57 * v_u_68.Value
				end
			end
		}
	}
	local v_u_74 = v_u_4.LoopWithFunctions(0.025, v73)
	if p64 ~= nil then
		task.delay(p64, function()
			-- upvalues: (ref) v_u_74
			v_u_74:EndLoop()
		end)
	end
	return {
		["Velocity"] = v_u_69,
		["Attachment"] = v67,
		["Tween"] = v71,
		["Loop"] = v_u_74,
		["Destroy"] = function(p75)
			if p75.Tween then
				p75.Tween:Destroy()
			end
			if p75.Velocity then
				p75.Velocity:Destroy()
			end
			if p75.Attachment then
				p75.Attachment:Destroy()
			end
			if p75.Loop then
				p75.Loop:EndLoop()
			end
			for v76 in pairs(p75) do
				p75[v76] = nil
			end
		end
	}
end
function v1.DashV2(p77, p_u_78, p79, p80, p81, p82, p83, p84, p85, p86, p87, _)
	-- upvalues: (copy) v_u_13, (copy) v_u_3, (copy) v_u_4
	local v88 = p87 or Instance.new("Attachment")
	v88.Name = "LinearVelocityAttachment"
	if v88.Parent == nil then
		v88.Parent = p77
	end
	local v_u_89 = Instance.new("NumberValue")
	v_u_89.Value = p79
	local v_u_90 = p86 or Instance.new("LinearVelocity")
	v_u_90.Attachment0 = v88
	v_u_90.RelativeTo = Enum.ActuatorRelativeTo.World
	v_u_90.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	v_u_90.ForceLimitsEnabled = true
	if typeof(p81) == "Vector3" then
		v_u_90.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		v_u_90.MaxAxesForce = p81
	else
		v_u_90.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v_u_90.MaxForce = p81
	end
	local v91 = Vector3.new(0, 0, 0)
	if typeof(p_u_78) == "string" then
		v91 = v_u_13(p_u_78)
	elseif typeof(p_u_78) == "Vector3" then
		v91 = p_u_78
	end
	v_u_90.VectorVelocity = v91 * v_u_89.Value
	if v_u_90.Parent == nil then
		v_u_90.Parent = p77
	end
	local v92 = v_u_3.TweenProperty(v_u_89, p84, p82, p83, {
		["Value"] = p80
	})
	local v94 = {
		{
			["Iterations"] = 1,
			["Function"] = function()
				-- upvalues: (copy) p_u_78, (copy) v_u_90, (ref) v_u_13, (copy) v_u_89
				local v93 = p_u_78
				if typeof(v93) == "string" then
					v_u_90.VectorVelocity = v_u_13(p_u_78) * v_u_89.Value
				else
					v_u_90.VectorVelocity = p_u_78 * v_u_89.Value
				end
			end
		}
	}
	local v_u_95 = v_u_4.LoopWithFunctions(0.025, v94)
	if p85 ~= nil then
		task.delay(p85, function()
			-- upvalues: (ref) v_u_95
			v_u_95:EndLoop()
		end)
	end
	return {
		["Velocity"] = v_u_90,
		["Attachment"] = v88,
		["Tween"] = v92,
		["Loop"] = v_u_95,
		["Destroy"] = function(p96)
			if p96.Tween then
				p96.Tween:Destroy()
			end
			if p96.Velocity then
				p96.Velocity:Destroy()
			end
			if p96.Attachment then
				p96.Attachment:Destroy()
			end
			if p96.Loop then
				p96.Loop:EndLoop()
			end
			for v97 in pairs(p96) do
				p96[v97] = nil
			end
		end
	}
end
function v1.AlignPositionV1(p98, p99, p100, p101)
	local v102 = Instance.new("Attachment")
	v102.Parent = p98
	v102.Name = "AlignPositionAttachment"
	local v103 = Instance.new("AlignPosition")
	v103.Mode = Enum.PositionAlignmentMode.OneAttachment
	v103.Attachment0 = v102
	v103.Position = p99
	v103.Responsiveness = 200
	v103.MaxForce = p100
	v103.Parent = p98
	local v_u_104 = nil
	v_u_104 = {
		["Align"] = v103,
		["Attachment"] = v102,
		["Destroy"] = function(p105)
			-- upvalues: (ref) v_u_104
			if p105.Align then
				p105.Align:Destroy()
			end
			if p105.Attachment then
				p105.Attachment:Destroy()
			end
			for v106 in pairs(p105) do
				p105[v106] = nil
			end
			v_u_104 = nil
		end
	}
	if p101 ~= nil then
		task.delay(p101, function()
			-- upvalues: (ref) v_u_104
			if v_u_104 then
				v_u_104:Destroy()
			end
		end)
	end
	return v_u_104
end
function v1.AlignPositionV2(p107, p108, p109, p110)
	local v111 = Instance.new("Attachment")
	v111.Parent = p107
	v111.Name = "AlignPositionAttachment"
	local v112 = Instance.new("Attachment")
	v112.Parent = p108
	v112.Name = "AlignPositionAttachment"
	local v113 = Instance.new("AlignPosition")
	v113.Mode = Enum.PositionAlignmentMode.TwoAttachment
	v113.Attachment0 = v111
	v113.Attachment1 = v112
	v113.Responsiveness = 200
	v113.MaxForce = p109
	v113.Parent = p107
	local v_u_114 = nil
	v_u_114 = {
		["Align"] = v113,
		["Attachment"] = v111,
		["Attachment1"] = v112,
		["Destroy"] = function(p115)
			-- upvalues: (ref) v_u_114
			if p115.Align then
				p115.Align:Destroy()
			end
			if p115.Attachment then
				p115.Attachment:Destroy()
			end
			if p115.Attachment1 then
				p115.Attachment1:Destroy()
			end
			for v116 in pairs(p115) do
				p115[v116] = nil
			end
			v_u_114 = nil
		end
	}
	if p110 ~= nil then
		task.delay(p110, function()
			-- upvalues: (ref) v_u_114
			if v_u_114 then
				v_u_114:Destroy()
			end
		end)
	end
	return v_u_114
end
function v1.AlignOrientationV1(p117, p118, p119, p120)
	local v121 = Instance.new("Attachment")
	v121.Parent = p117
	v121.Name = "AlignOrientationAttachment"
	local v122 = Instance.new("AlignOrientation")
	v122.Mode = Enum.OrientationAlignmentMode.OneAttachment
	v122.Attachment0 = v121
	v122.CFrame = p118
	v122.Responsiveness = 200
	v122.MaxTorque = p119
	v122.Parent = p117
	local v_u_123 = nil
	v_u_123 = {
		["Align"] = v122,
		["Attachment"] = v121,
		["Destroy"] = function(p124)
			-- upvalues: (ref) v_u_123
			if p124.Align then
				p124.Align:Destroy()
			end
			if p124.Attachment then
				p124.Attachment:Destroy()
			end
			for v125 in pairs(p124) do
				p124[v125] = nil
			end
			v_u_123 = nil
		end
	}
	if p120 ~= nil then
		task.delay(p120, function()
			-- upvalues: (ref) v_u_123
			if v_u_123 then
				v_u_123:Destroy()
			end
		end)
	end
	return v_u_123
end
function v1.AlignOrientationV2(p126, p127, p128, p129, p130)
	local v131 = Instance.new("Attachment")
	v131.Parent = p126
	v131.Name = "AlignOrientationAttachment"
	local v132 = Instance.new("Attachment")
	v132.Parent = p127
	v132.Name = "AlignOrientationAttachment"
	local v133 = Instance.new("AlignOrientation")
	v133.Mode = Enum.OrientationAlignmentMode.TwoAttachment
	v133.Attachment0 = v131
	v133.Attachment1 = v132
	v132.CFrame = v132.CFrame * p128
	v133.Responsiveness = 200
	v133.MaxTorque = p129
	v133.Parent = p126
	local v_u_134 = nil
	v_u_134 = {
		["Align"] = v133,
		["Attachment"] = v131,
		["Attachment1"] = v132,
		["Destroy"] = function(p135)
			-- upvalues: (ref) v_u_134
			if p135.Align then
				p135.Align:Destroy()
			end
			if p135.Attachment then
				p135.Attachment:Destroy()
			end
			if p135.Attachment1 then
				p135.Attachment1:Destroy()
			end
			for v136 in pairs(p135) do
				p135[v136] = nil
			end
			v_u_134 = nil
		end
	}
	if p130 ~= nil then
		task.delay(p130, function()
			-- upvalues: (ref) v_u_134
			if v_u_134 then
				v_u_134:Destroy()
			end
		end)
	end
	return v_u_134
end
return v1
