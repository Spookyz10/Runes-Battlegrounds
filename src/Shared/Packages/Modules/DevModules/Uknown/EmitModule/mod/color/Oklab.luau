-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = require(script.Parent.sRGB)
local v_u_26 = {
	["fromLinear"] = function(p2)
		local v3 = p2.R * 0.4122214708 + p2.G * 0.5363325363 + p2.B * 0.0514459929
		local v4 = p2.R * 0.2119034982 + p2.G * 0.6806995451 + p2.B * 0.1073969566
		local v5 = p2.R * 0.0883024619 + p2.G * 0.2817188376 + p2.B * 0.6299787005
		local v6 = v3 ^ 0.3333333333333333
		local v7 = v4 ^ 0.3333333333333333
		local v8 = v5 ^ 0.3333333333333333
		local v9 = v6 * 0.2104542553 + v7 * 0.793617785 - v8 * 0.0040720468
		local v10 = v6 * 1.9779984951 - v7 * 2.428592205 + v8 * 0.4505937099
		local v11 = v6 * 0.0259040371 + v7 * 0.7827717662 - v8 * 0.808675766
		return Vector3.new(v9, v10, v11)
	end,
	["fromSRGB"] = function(p12)
		-- upvalues: (copy) v_u_26, (copy) v_u_1
		return v_u_26.fromLinear(v_u_1.toLinear(p12))
	end,
	["toLinear"] = function(p13, p14)
		local v15 = p13.X + p13.Y * 0.3963377774 + p13.Z * 0.2158037573
		local v16 = p13.X - p13.Y * 0.1055613458 - p13.Z * 0.0638541728
		local v17 = p13.X - p13.Y * 0.0894841775 - p13.Z * 1.291485548
		local v18 = v15 ^ 3
		local v19 = v16 ^ 3
		local v20 = v17 ^ 3
		local v21 = v18 * 4.0767416621 - v19 * 3.3077115913 + v20 * 0.2309699292
		local v22 = v18 * -1.2684380046 + v19 * 2.6097574011 - v20 * 0.3413193965
		local v23 = v18 * -0.0041960863 - v19 * 0.7034186147 + v20 * 1.707614701
		if not p14 then
			v21 = math.clamp(v21, 0, 1)
			v22 = math.clamp(v22, 0, 1)
			v23 = math.clamp(v23, 0, 1)
		end
		return Color3.new(v21, v22, v23)
	end,
	["toSRGB"] = function(p24, p25)
		-- upvalues: (copy) v_u_1, (copy) v_u_26
		return v_u_1.fromLinear(v_u_26.toLinear(p24, p25))
	end
}
return v_u_26
