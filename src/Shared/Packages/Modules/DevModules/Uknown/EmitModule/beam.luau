-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require("./mod/tween")
local v_u_2 = require("./mod/utility")
local v_u_3 = Random.new()
local function v_u_6(p4, p5)
	-- upvalues: (copy) v_u_2
	return v_u_2.getAttribute(p4, "Width0", p4.Width0, true) * p5, v_u_2.getAttribute(p4, "Width1", p4.Width1, true) * p5, v_u_2.getAttribute(p4, "StartWidth0", p4.Width0, true) * p5, v_u_2.getAttribute(p4, "StartWidth1", p4.Width1, true) * p5
end
return {
	["emit"] = function(p_u_7, p_u_8, p9, p10)
		-- upvalues: (copy) v_u_6, (copy) v_u_2, (copy) v_u_3, (copy) v_u_1
		local v11, v12, v13, v14 = v_u_6(p_u_7, p10)
		local v_u_15 = v_u_2.getAttribute(p_u_7, "Width0_Start", v13)
		local v_u_16 = v_u_2.getAttribute(p_u_7, "Width0_End", v11)
		local v_u_17 = v_u_2.getAttribute(p_u_7, "Width1_Start", v14)
		local v_u_18 = v_u_2.getAttribute(p_u_7, "Width1_End", v12)
		local v19 = v_u_2.getAttribute(p_u_7, "EmitDelay", 0)
		local v20 = v_u_2.getAttribute(p_u_7, "Duration", 1, true)
		local v21 = v_u_2.getAttribute(p_u_7, "EndTransparencyScale", 1, true)
		local v22 = v_u_2.getRangeAttribute(p_u_7, "EffectDuration", NumberRange.new(v20, v20), NumberRange.new(0, (1 / 0)))
		local v23 = v_u_3:NextNumber(v22.Min, v22.Max)
		local v_u_24 = v_u_2.getAttribute(p_u_7, "Transparency_Scale_Start", 1)
		local v_u_25 = v_u_2.getAttribute(p_u_7, "Transparency_Scale_End", v21)
		local v_u_26 = v_u_2.getAttribute(p_u_7, "Speed_Start", 1)
		local v_u_27 = v_u_2.getAttribute(p_u_7, "Speed_End", 1)
		local v_u_28 = p_u_8.TextureSpeed
		task.wait(v19)
		p_u_8.Enabled = true
		local v_u_29 = 1
		local v_u_30
		if v_u_26 == v_u_27 then
			v_u_30 = nil
		else
			v_u_30 = v_u_1.fromParams(v_u_2.getAttribute(p_u_7, "Speed_Curve", v_u_2.default_bezier), v_u_2.getAttribute(p_u_8, "Speed_Duration", 0.1), function(p31, p32)
				-- upvalues: (ref) v_u_29, (ref) v_u_2, (copy) v_u_26, (copy) v_u_27, (copy) p_u_8, (copy) v_u_28
				v_u_29 = v_u_2.lerp(v_u_26, v_u_27, p31)
				p_u_8.TextureSpeed = v_u_28 * v_u_29
				return p32
			end)
			table.insert(p9, v_u_30)
		end
		if v_u_24 == v_u_25 then
			if v_u_24 ~= 1 then
				p_u_8.Transparency = v_u_2.scaleNumberSequence(p_u_7.Transparency, function(p33, p34)
					-- upvalues: (copy) v_u_24
					return p33 + (v_u_24 > 1 and 1 - p33 or -p33) * (v_u_24 > 1 and v_u_24 - 1 or 1 - v_u_24), p34
				end)
			end
		else
			local v35 = v_u_1.fromParams
			local v36 = v_u_2.getAttribute(p_u_7, "Transparency_Scale_Curve", v_u_2.default_bezier)
			local function v42(p37, p38)
				-- upvalues: (ref) v_u_2, (copy) v_u_24, (copy) v_u_25, (copy) p_u_8, (copy) p_u_7, (ref) v_u_29
				local v_u_39 = v_u_2.lerp(v_u_24, v_u_25, p37)
				p_u_8.Transparency = v_u_2.scaleNumberSequence(p_u_7.Transparency, function(p40, p41)
					-- upvalues: (copy) v_u_39
					return p40 + (v_u_39 > 1 and 1 - p40 or -p40) * (v_u_39 > 1 and v_u_39 - 1 or 1 - v_u_39), p41
				end)
				return p38 * v_u_29
			end
			table.insert(p9, v35(v36, v23, v42, v_u_30))
		end
		if v_u_15 == v_u_16 then
			p_u_8.Width0 = v_u_15
		else
			local v43 = v_u_1.fromParams
			local v44 = v_u_2.getAttribute(p_u_7, "Width0_Curve", v_u_2.default_bezier)
			local function v47(p45, p46)
				-- upvalues: (copy) p_u_8, (ref) v_u_2, (copy) v_u_15, (copy) v_u_16, (ref) v_u_29
				p_u_8.Width0 = v_u_2.lerp(v_u_15, v_u_16, p45)
				return p46 * v_u_29
			end
			table.insert(p9, v43(v44, v23, v47, v_u_30))
		end
		if v_u_17 == v_u_18 then
			p_u_8.Width1 = v_u_17
		else
			local v48 = v_u_1.fromParams
			local v49 = v_u_2.getAttribute(p_u_7, "Width1_Curve", v_u_2.default_bezier)
			local function v52(p50, p51)
				-- upvalues: (copy) p_u_8, (ref) v_u_2, (copy) v_u_17, (copy) v_u_18, (ref) v_u_29
				p_u_8.Width1 = v_u_2.lerp(v_u_17, v_u_18, p50)
				return p51 * v_u_29
			end
			table.insert(p9, v48(v49, v23, v52, v_u_30))
		end
		v_u_1.timer(v23, function(p53, p54)
			-- upvalues: (ref) v_u_29, (ref) v_u_30
			if v_u_29 > 0 or p54 > 0 and (v_u_30 and v_u_30.Connected) then
				return p53 * v_u_29
			else
				return nil
			end
		end, v_u_30, p9)
	end
}
