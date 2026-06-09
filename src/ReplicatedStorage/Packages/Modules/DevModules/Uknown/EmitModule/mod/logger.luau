-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local function v_u_1(...)
	return ("[Forge Emit API]: %*"):format((table.concat({ ... }, " ")))
end
return {
	["error"] = function(...)
		-- upvalues: (copy) v_u_1
		error(v_u_1(..., "\n"))
	end,
	["warn"] = function(...)
		-- upvalues: (copy) v_u_1
		warn(v_u_1(...))
		warn(v_u_1(debug.traceback("stack trace:")))
	end,
	["info"] = function(...)
		-- upvalues: (copy) v_u_1
		print(v_u_1(...))
	end
}
