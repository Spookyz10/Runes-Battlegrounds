-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
return {
	["fromLinear"] = function(p1)
		local v2 = Color3.new
		local v3 = p1.R
		local v4
		if v3 >= 0.04045 then
			v4 = ((v3 + 0.055) / 1.055) ^ 2.4
		else
			v4 = v3 / 12.92
		end
		local v5 = p1.G
		local v6
		if v5 >= 0.04045 then
			v6 = ((v5 + 0.055) / 1.055) ^ 2.4
		else
			v6 = v5 / 12.92
		end
		local v7 = p1.B
		local v8
		if v7 >= 0.04045 then
			v8 = ((v7 + 0.055) / 1.055) ^ 2.4
		else
			v8 = v7 / 12.92
		end
		return v2(v4, v6, v8)
	end,
	["toLinear"] = function(p9)
		local v10 = Color3.new
		local v11 = p9.R
		local v12
		if v11 >= 0.0031308 then
			v12 = v11 ^ 0.4166666666666667 * 1.055 - 0.055
		else
			v12 = v11 * 12.92
		end
		local v13 = p9.G
		local v14
		if v13 >= 0.0031308 then
			v14 = v13 ^ 0.4166666666666667 * 1.055 - 0.055
		else
			v14 = v13 * 12.92
		end
		local v15 = p9.B
		local v16
		if v15 >= 0.0031308 then
			v16 = v15 ^ 0.4166666666666667 * 1.055 - 0.055
		else
			v16 = v15 * 12.92
		end
		return v10(v12, v14, v16)
	end
}
