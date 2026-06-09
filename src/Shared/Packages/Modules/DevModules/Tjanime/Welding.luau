-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("Debris")
local v2 = {}
local v_u_3 = { "Weld", "WeldConstraint", "Motor6D" }
local function v_u_11(p4, p5, p6, p7, p8, p9)
	-- upvalues: (copy) v_u_3, (copy) v_u_1
	if table.find(v_u_3, p4) == nil then
		error("WELD TYPE", p4, "IS NOT FOUND")
	end
	local v10 = Instance.new(p4)
	v10.Parent = p5
	v10.Part0 = p5
	v10.Part1 = p6
	v10.Name = p8
	if p4 ~= "WeldConstraint" and p7 ~= nil then
		v10.C0 = p7
	end
	if p9 ~= nil then
		v_u_1:AddItem(v10, p9)
	end
	return v10
end
function v2.NormalWeld(p12, p13, p14, p15, p16)
	-- upvalues: (copy) v_u_11
	return v_u_11("Weld", p12, p13, p14, p15, p16)
end
function v2.WeldConstraint(p17, p18, p19, p20)
	-- upvalues: (copy) v_u_11
	return v_u_11("WeldConstraint", p17, p18, nil, p19, p20)
end
function v2.Motor6D(p21, p22, p23, p24, p25)
	-- upvalues: (copy) v_u_11
	return v_u_11("Motor6D", p21, p22, p23, p24, p25)
end
return v2
