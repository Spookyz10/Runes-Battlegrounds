-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("./mod/lerp")
local v_u_2 = require("./mod/tween")
local v_u_3 = require("./mod/utility")
local v_u_4 = Random.new()
return {
	["emit"] = function(p_u_5, p6, p7)
		-- upvalues: (copy) v_u_3, (copy) v_u_4, (copy) v_u_2, (copy) v_u_1
		local v_u_8 = p6.Name
		local v9 = v_u_3.getAttribute(p6, "EmitDelay", 0)
		local v10 = v_u_3.getAttribute(p6, "ResetOnFinish", true)
		local v11 = v_u_3.getRangeAttribute(p6, "Duration", NumberRange.new(1, 1), NumberRange.new(0, (1 / 0)))
		if v9 > 0 then
			task.wait(v9)
		end
		local v_u_12 = p6:GetAttribute("_END_VALUE")
		local v13 = p6:GetAttribute("_START_VALUE")
		local v14, v15 = pcall(function()
			-- upvalues: (copy) p_u_5, (copy) v_u_8
			return p_u_5[v_u_8]
		end)
		local v_u_16 = v13 or v15
		local v17 = typeof(v_u_16)
		if v14 and v17 == typeof(v_u_12) then
			local v18 = v_u_4:NextNumber(v11.Min, v11.Max)
			local v_u_19 = v_u_3.getAttribute(p6, "Speed_Start", 1)
			local v_u_20 = v_u_3.getAttribute(p6, "Speed_End", 1)
			local v_u_21 = v_u_19
			local v_u_22
			if v_u_19 == v_u_20 then
				v_u_22 = nil
			else
				v_u_22 = v_u_2.fromParams(v_u_3.getAttribute(p6, "Speed_Curve", v_u_3.default_bezier), v_u_3.getAttribute(p6, "Speed_Duration", 0.1), function(p23, p24)
					-- upvalues: (ref) v_u_21, (ref) v_u_3, (copy) v_u_19, (copy) v_u_20
					v_u_21 = v_u_3.lerp(v_u_19, v_u_20, p23)
					return p24
				end)
				table.insert(p7, v_u_22)
			end
			local v_u_25 = v_u_1[v17] or v_u_1.Other
			local v26 = v_u_2.fromParams
			local v27 = v_u_3.getAttribute(p6, "Easing_Curve", v_u_3.linear_bezier)
			local v28 = v_u_3.RENDER_PRIORITY + p7.depth
			table.insert(p7, v26(v27, v18, function(p29, p30)
				-- upvalues: (copy) p_u_5, (copy) v_u_8, (copy) v_u_25, (ref) v_u_16, (copy) v_u_12, (ref) v_u_21
				p_u_5[v_u_8] = v_u_25(v_u_16, v_u_12, p29)
				return p30 * v_u_21
			end, v_u_22, nil, nil, v28))
			if v10 then
				table.insert(p7, function()
					-- upvalues: (copy) p_u_5, (copy) v_u_8, (ref) v_u_16
					p_u_5[v_u_8] = v_u_16
				end)
			end
			v_u_2.timer(v18, function(p31, p32)
				-- upvalues: (ref) v_u_21, (ref) v_u_22
				if v_u_21 > 0 or p32 > 0 and (v_u_22 and v_u_22.Connected) then
					return p31 * v_u_21
				else
					return nil
				end
			end, v_u_22, p7)
		end
	end
}
