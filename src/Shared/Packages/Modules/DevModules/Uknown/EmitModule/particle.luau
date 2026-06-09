-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("./mod/tween")
local v_u_2 = require("./mod/utility")
return {
	["emit"] = function(p_u_3, p_u_4, p5)
		-- upvalues: (copy) v_u_2, (copy) v_u_1
		if p_u_3.Enabled then
			p_u_3.Enabled = false
		end
		local v6 = v_u_2.getAttribute(p_u_3, "EmitDelay", 0)
		local v7 = v_u_2.getAttribute(p_u_3, "EmitCount", 1)
		local v8 = v_u_2.getAttribute(p_u_3, "EmitDuration", 0)
		local v9 = v8 > 0
		task.wait(v6)
		if v9 then
			p_u_4.Enabled = true
		end
		local v10 = v_u_2.getAttribute(p_u_3, "TimeScale_Duration", 0.1)
		local v_u_11 = v_u_2.getAttribute(p_u_3, "TimeScale_Start", p_u_4.TimeScale)
		local v_u_12 = v_u_2.getAttribute(p_u_3, "TimeScale_End", p_u_4.TimeScale)
		local v_u_13 = nil
		if v_u_11 == v_u_12 then
			p_u_4.TimeScale = v_u_11
		else
			v_u_13 = v_u_1.fromParams(v_u_2.getAttribute(p_u_3, "TimeScale_Curve", v_u_2.default_bezier), v10, function(p14, p15)
				-- upvalues: (ref) v_u_2, (copy) v_u_11, (copy) v_u_12, (copy) p_u_4
				p_u_4.TimeScale = v_u_2.lerp(v_u_11, v_u_12, (math.clamp(p14, 0, 1)))
				return p15
			end)
			table.insert(p5, v_u_13)
		end
		p_u_4:Emit(v7)
		if v9 then
			task.wait(v8)
			p_u_4.Enabled = false
		end
		v_u_1.timer(p_u_3.Lifetime.Max, function(p16, p17)
			-- upvalues: (copy) p_u_3, (ref) v_u_13
			if p_u_3.TimeScale > 0 or p17 > 0 and (v_u_13 and v_u_13.Connected) then
				return p16 * p_u_3.TimeScale
			else
				return nil
			end
		end, v_u_13, p5)
	end
}
