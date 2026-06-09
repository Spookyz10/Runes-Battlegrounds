-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("RunService")
local v_u_2 = require("./mod/tween")
local v_u_3 = require("./mod/utility")
local v_u_4 = require("./obj/Shake")
local v_u_5 = {}
local v_u_6 = CFrame.identity
local function v_u_16()
	-- upvalues: (ref) v_u_5, (copy) v_u_1, (ref) v_u_6
	if #v_u_5 ~= 0 then
		local v7 = workspace.CurrentCamera
		if not v_u_1:IsRunning() then
			v7.CFrame = v7.CFrame * v_u_6:Inverse()
			local v8 = v7.CFrame
			local v9, v10 = v8:ToOrientation()
			v7.CFrame = CFrame.new(v8.Position) * CFrame.fromOrientation(v9, v10, 0)
		end
		local v11 = CFrame.identity
		local v12 = Vector3.new(0, 0, 0)
		local v13 = {}
		for _, v14 in v_u_5 do
			if not v14.done then
				v12 = v12 + v14.pos
				v11 = v11 * CFrame.Angles(v14.rot.x, v14.rot.y, v14.rot.z)
				table.insert(v13, v14)
			end
		end
		v_u_5 = v13
		local v15 = CFrame.new(v12) * v11
		if not v_u_1:IsRunning() then
			v_u_6 = v15
		end
		v7.CFrame = v7.CFrame * v15
	end
end
local v17 = {}
local v_u_18 = nil
local v_u_19 = nil
function v17.init()
	-- upvalues: (ref) v_u_18, (copy) v_u_1, (ref) v_u_19, (copy) v_u_16
	if not v_u_18 then
		if v_u_1:IsRunning() then
			v_u_18 = v_u_1.Heartbeat:Connect(function()
				-- upvalues: (ref) v_u_19
				if v_u_19 then
					workspace.CurrentCamera.CFrame = v_u_19
				end
			end)
		end
		v_u_1:BindToRenderStep("forge_updateCameraShake", Enum.RenderPriority.Last.Value + 1, v_u_16)
	end
end
function v17.deinit()
	-- upvalues: (ref) v_u_18, (copy) v_u_1
	if v_u_18 then
		v_u_18:Disconnect()
		v_u_18 = nil
	end
	v_u_1:UnbindFromRenderStep("forge_updateCameraShake")
end
function v17.emit(p_u_20, p21)
	-- upvalues: (copy) v_u_3, (copy) v_u_4, (copy) v_u_2, (copy) v_u_1, (ref) v_u_5, (ref) v_u_19
	local v22 = v_u_3.getAttribute(p_u_20, "EmitDelay", 0)
	local v23 = v_u_3.getAttribute(p_u_20, "EmitDuration", 0)
	local v_u_24 = v_u_3.getAttribute(p_u_20, "Falloff", 30)
	local v25 = v_u_3.getAttribute(p_u_20, "Amplitude", 2.5)
	local v26 = v_u_3.getAttribute(p_u_20, "Frequency", 0.2)
	local v27 = v_u_3.getAttribute(p_u_20, "FadeInTime", 0.3)
	local v28 = v_u_3.getAttribute(p_u_20, "FadeOutTime", 2)
	local v29 = v_u_3.getAttribute(p_u_20, "SustainTime", 1)
	local v30 = v_u_3.getAttribute(p_u_20, "PositionInfluence", Vector3.new(1, 1, 1))
	local v31 = v_u_3.getAttribute(p_u_20, "RotationInfluence", Vector3.new(0.2, 0.2, 0.2))
	local v_u_32 = v_u_3.getAttribute(p_u_20, "Speed_Start", 1)
	local v_u_33 = v_u_3.getAttribute(p_u_20, "Speed_End", 1)
	local v34 = v23 > 0
	local v35 = v_u_4.new()
	v35.Sustain = v34
	v35.Amplitude = v25
	v35.Frequency = v26
	v35.FadeInTime = v27
	v35.FadeOutTime = v28
	v35.SustainTime = v29
	v35.PositionInfluence = v30
	v35.RotationInfluence = v31
	local v_u_36 = 1
	local v_u_37 = 0
	function v35.TimeFunction()
		-- upvalues: (ref) v_u_37
		return v_u_37
	end
	if v_u_32 ~= v_u_33 then
		speedTween = v_u_2.fromParams(v_u_3.getAttribute(p_u_20, "Speed_Curve", v_u_3.default_bezier), v_u_3.getAttribute(p_u_20, "Speed_Duration", 0.1), function(p38, p39)
			-- upvalues: (ref) v_u_36, (ref) v_u_3, (copy) v_u_32, (copy) v_u_33
			v_u_36 = v_u_3.lerp(v_u_32, v_u_33, p38)
			return p39
		end)
		local v40 = speedTween
		table.insert(p21, v40)
	end
	local v41 = v_u_1.RenderStepped
	local function v43(p42)
		-- upvalues: (ref) v_u_37, (ref) v_u_36
		v_u_37 = v_u_37 + p42 * v_u_36
	end
	table.insert(p21, v41:Connect(v43))
	local v_u_44 = {
		["done"] = false,
		["pos"] = Vector3.new(0, 0, 0),
		["rot"] = Vector3.new(0, 0, 0)
	}
	task.wait(v22)
	local v45 = v_u_5
	table.insert(v45, v_u_44)
	local v_u_46 = coroutine.running()
	v35:BindToRenderStep(v_u_4.NextRenderName(), v_u_3.RENDER_PRIORITY + p21.depth, function(p47, p48, p49)
		-- upvalues: (ref) v_u_19, (copy) p_u_20, (copy) v_u_24, (copy) v_u_44, (copy) v_u_46
		local v50 = workspace.CurrentCamera
		v_u_19 = v50.CFrame
		local v51 = p_u_20:FindFirstAncestorOfClass("Attachment") or p_u_20:FindFirstAncestorWhichIsA("BasePart")
		if v51 then
			local v52 = (v50.CFrame.Position - (v51:IsA("Attachment") and v51.WorldPosition or v51.Position)).Magnitude / v_u_24
			local v53 = 1 - math.clamp(v52, 0, 1)
			p47 = p47 * v53
			p48 = p48 * v53
		end
		v_u_44.pos = p47
		v_u_44.rot = p48
		v_u_44.done = p49
		if p49 then
			v_u_19 = nil
			task.spawn(v_u_46)
		end
	end)
	v35:Start()
	if v34 then
		task.wait(v23)
		v35:StopSustain()
	end
	if not v_u_44.done then
		coroutine.yield()
	end
end
return v17
