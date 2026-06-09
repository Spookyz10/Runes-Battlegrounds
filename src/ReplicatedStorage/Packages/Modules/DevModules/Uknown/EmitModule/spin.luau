-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("./mod/tween")
local v_u_2 = require("./mod/utility")
return {
	["emit"] = function(p_u_3, p4)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		local v5 = v_u_2.getAttribute(p_u_3, "SpinRotation", Vector3.new(0, 0, 0), true) * v_u_2.DEG_TO_RAD
		local v_u_6 = v_u_2.getAttribute(p_u_3, "Scale_Start", 1, true)
		local v_u_7 = v_u_2.getAttribute(p_u_3, "Scale_End", 1, true)
		if v5 ~= Vector3.new(0, 0, 0) or (v_u_6 ~= 1 or v_u_7 ~= 1) then
			local v8 = v_u_2.getAttribute(p_u_3, "EmitDelay", 0)
			local v_u_9 = v_u_2.getAttribute(p_u_3, "SyncPosition", false)
			local v_u_10 = v_u_2.getAttribute(p_u_3, "SpinDuration", 0.5)
			local v11 = v_u_2.getAttribute(p_u_3, "SpinSpeed_Duration", 0.1)
			local v_u_12 = v_u_2.getAttribute(p_u_3, "SpinSpeed_Start", 0)
			local v_u_13 = v_u_2.getAttribute(p_u_3, "SpinSpeed_End", 1)
			local v_u_14 = v_u_12
			task.wait(v8)
			local v_u_15
			if v_u_12 == v_u_13 then
				v_u_15 = nil
			else
				v_u_15 = v_u_1.fromParams(v_u_2.getAttribute(p_u_3, "SpinSpeed_Curve", v_u_2.default_bezier), v11, function(p16, p17)
					-- upvalues: (ref) v_u_14, (ref) v_u_2, (copy) v_u_12, (copy) v_u_13
					v_u_14 = v_u_2.lerp(v_u_12, v_u_13, p16)
					return p17
				end)
				table.insert(p4, v_u_15)
			end
			local v_u_18 = p_u_3:GetPivot()
			local v_u_19 = p_u_3:GetScale()
			if v_u_6 == v_u_7 then
				p_u_3:ScaleTo(v_u_6)
			else
				local v20 = v_u_1.fromParams
				local v21 = v_u_2.getAttribute(p_u_3, "Scale_Curve", v_u_2.default_bezier)
				local function v24(p22, p23)
					-- upvalues: (copy) p_u_3, (ref) v_u_2, (copy) v_u_6, (copy) v_u_7
					p_u_3:ScaleTo(v_u_2.lerp(v_u_6, v_u_7, p22))
					return p23
				end
				table.insert(p4, v20(v21, v_u_10, v24))
			end
			local v_u_25 = p_u_3:FindFirstAncestorOfClass("Attachment") or p_u_3:FindFirstAncestorWhichIsA("BasePart")
			table.insert(p4, function()
				-- upvalues: (copy) p_u_3, (copy) v_u_25, (copy) v_u_18, (copy) v_u_19
				p_u_3:PivotTo(v_u_25 and (v_u_25:IsA("Attachment") and v_u_25.WorldCFrame or v_u_25.CFrame) or v_u_18)
				p_u_3:ScaleTo(v_u_19)
			end)
			local v_u_26 = v5 * v_u_10
			v_u_1.timer(v_u_10, function(p27, p28)
				-- upvalues: (copy) v_u_10, (ref) v_u_26, (copy) v_u_25, (copy) v_u_9, (copy) v_u_18, (copy) p_u_3, (ref) v_u_14, (ref) v_u_15
				local v29 = p28 / v_u_10
				local v30 = v_u_26 * math.clamp(v29, 0, 1)
				local v31
				if v_u_25 and v_u_9 then
					v31 = v_u_25:IsA("Attachment") and v_u_25.WorldCFrame or v_u_25.CFrame
				else
					v31 = v_u_18
				end
				p_u_3:PivotTo(v31 * CFrame.fromOrientation(v30.x, v30.y, v30.z))
				if v_u_14 > 0 or p28 > 0 and v_u_15.Connected then
					return p27 * v_u_14
				else
					return nil
				end
			end, v_u_15, p4, v_u_2.RENDER_PRIORITY + p4.depth)
		end
	end
}
