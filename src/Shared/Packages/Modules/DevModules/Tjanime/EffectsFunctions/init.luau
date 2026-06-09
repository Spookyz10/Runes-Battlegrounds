-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
function v_u_1.new()
	-- upvalues: (copy) v_u_1
	local v2 = {}
	for _, v3 in pairs(script:GetDescendants()) do
		if v3:IsA("ModuleScript") and v3 ~= script then
			local v4 = require(v3)
			v2[v3.Name] = v4
		end
	end
	local v5 = v_u_1
	return setmetatable(v2, v5)
end
return v_u_1
