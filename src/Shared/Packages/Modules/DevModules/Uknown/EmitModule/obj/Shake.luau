-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = Random.new()
local v_u_3 = 0
local v_u_4 = {}
v_u_4.__index = v_u_4
function v_u_4.new()
	-- upvalues: (copy) v_u_4, (copy) v_u_1, (copy) v_u_2
	local v5 = v_u_4
	local v6 = setmetatable({}, v5)
	v6.Amplitude = 1
	v6.Frequency = 1
	v6.FadeInTime = 1
	v6.FadeOutTime = 1
	v6.SustainTime = 0
	v6.Sustain = false
	v6.PositionInfluence = Vector3.new(1, 1, 1)
	v6.RotationInfluence = Vector3.new(1, 1, 1)
	local v7
	if v_u_1:IsRunning() then
		v7 = time
	else
		v7 = os.clock
	end
	v6.TimeFunction = v7
	v6._timeOffset = v_u_2:NextNumber(-1000000, 1000000)
	v6._startTime = 0
	v6._running = false
	v6._signalConnections = {}
	v6._renderBindings = {}
	return v6
end
function v_u_4.InverseSquare(p8, p9)
	local v10 = p9 < 1 and 1 or p9
	return p8 * (1 / (v10 * v10))
end
function v_u_4.NextRenderName()
	-- upvalues: (ref) v_u_3
	v_u_3 = v_u_3 + 1
	return ("__shake_%.4i__"):format(v_u_3)
end
function v_u_4.Start(p11)
	p11._startTime = p11.TimeFunction()
	p11._running = true
end
function v_u_4.Stop(p12)
	-- upvalues: (copy) v_u_1
	p12._running = false
	for _, v13 in p12._renderBindings do
		v_u_1:UnbindFromRenderStep(v13)
	end
	table.clear(p12._renderBindings)
	for _, v14 in p12._signalConnections do
		v14:Disconnect()
	end
	table.clear(p12._signalConnections)
end
function v_u_4.IsShaking(p15)
	return p15._running
end
function v_u_4.StopSustain(p16)
	local v17 = p16.TimeFunction()
	p16.Sustain = false
	p16.SustainTime = v17 - p16._startTime - p16.FadeInTime
end
function v_u_4.Update(p18)
	local v19 = false
	local v20 = p18.TimeFunction()
	local v21 = v20 - p18._startTime
	local v22 = (v20 + p18._timeOffset) / p18.Frequency % 10000
	local v23 = 1
	local v24 = v21 >= p18.FadeInTime and 1 or v21 / p18.FadeInTime
	if not p18.Sustain and p18.FadeInTime + p18.SustainTime < v21 then
		if p18.FadeOutTime == 0 then
			v19 = true
		else
			v23 = 1 - (v21 - p18.FadeInTime - p18.SustainTime) / p18.FadeOutTime
			if not p18.Sustain and p18.FadeInTime + p18.SustainTime + p18.FadeOutTime <= v21 then
				v19 = true
			end
		end
	end
	local v25 = math.noise(v22, 0) / 2
	local v26 = math.noise(0, v22) / 2
	local v27 = math.noise(v22, v22) / 2
	local v28 = Vector3.new(v25, v26, v27) * p18.Amplitude * math.min(v24, v23)
	if v19 then
		p18:Stop()
	end
	return p18.PositionInfluence * v28, p18.RotationInfluence * v28, v19
end
function v_u_4.OnSignal(p_u_29, p30, p_u_31)
	local v32 = p30:Connect(function()
		-- upvalues: (copy) p_u_31, (copy) p_u_29
		p_u_31(p_u_29:Update())
	end)
	local v33 = p_u_29._signalConnections
	table.insert(v33, v32)
	return v32
end
function v_u_4.BindToRenderStep(p_u_34, p35, p36, p_u_37)
	-- upvalues: (copy) v_u_1
	v_u_1:BindToRenderStep(p35, p36, function()
		-- upvalues: (copy) p_u_37, (copy) p_u_34
		p_u_37(p_u_34:Update())
	end)
	local v38 = p_u_34._renderBindings
	table.insert(v38, p35)
end
function v_u_4.Clone(p39)
	-- upvalues: (copy) v_u_4
	local v40 = v_u_4.new()
	for _, v41 in {
		"Amplitude",
		"Frequency",
		"FadeInTime",
		"FadeOutTime",
		"SustainTime",
		"Sustain",
		"PositionInfluence",
		"RotationInfluence",
		"TimeFunction"
	} do
		v40[v41] = p39[v41]
	end
	return v40
end
function v_u_4.Destroy(p42)
	p42:Stop()
end
return {
	["new"] = v_u_4.new,
	["InverseSquare"] = v_u_4.InverseSquare,
	["NextRenderName"] = v_u_4.NextRenderName
}
