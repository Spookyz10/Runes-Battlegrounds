-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = Random.new()
local v_u_2 = {}
for v3, v4 in pairs(table) do
	v_u_2[v3] = v4
end
function v_u_2.contains(p5, p6)
	-- upvalues: (copy) v_u_2
	return v_u_2.indexOf(p5, p6) ~= nil
end
function v_u_2.indexOf(p7, p8)
	-- upvalues: (copy) v_u_2
	return table.find(p7, p8) or v_u_2.keyOf(p7, p8)
end
function v_u_2.keyOf(p9, p10)
	for v11, v12 in pairs(p9) do
		if v12 == p10 then
			return v11
		end
	end
	return nil
end
function v_u_2.skip(p13, p14)
	return table.move(p13, p14 + 1, #p13, 1, table.create(#p13 - p14))
end
function v_u_2.take(p15, p16)
	return table.move(p15, 1, p16, 1, table.create(p16))
end
function v_u_2.range(p17, p18, p19)
	return table.move(p17, p18, p19, 1, table.create(p19 - p18 + 1))
end
function v_u_2.skipAndTake(p20, p21, p22)
	return table.move(p20, p21 + 1, p21 + p22, 1, table.create(p22))
end
function v_u_2.random(p23)
	-- upvalues: (copy) v_u_1
	return p23[v_u_1:NextInteger(1, #p23)]
end
function v_u_2.join(p24, p25)
	local v26 = table.create(#p24 + #p25)
	table.move(p24, 1, #p24, 1, v26)
	return table.move(p25, 1, #p25, #p24 + 1, v26)
end
function v_u_2.removeObject(p27, p28)
	-- upvalues: (copy) v_u_2
	local v29 = v_u_2.indexOf(p27, p28)
	if v29 then
		table.remove(p27, v29)
	end
end
function v_u_2.expand(p30, p31)
	if p31 < 0 then
		error("Cannot expand a table by a negative amount of objects.")
	end
	local v32 = table.create(#p30 + p31)
	for v33 = 1, #p30 do
		v32[v33] = p30[v33]
	end
	return v32
end
return v_u_2
