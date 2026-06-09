-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = {}
v_u_1.__index = v_u_1
function v_u_1.LoopWithFunctions(p_u_2, p_u_3, p_u_4)
	-- upvalues: (copy) v_u_1
	local v_u_5 = nil
	local v_u_6 = 0
	for v7 = 1, #p_u_3 do
		if v_u_5 == nil then
			v_u_5 = p_u_3[v7].Iterations
		end
		if v_u_5 < p_u_3[v7].Iterations then
			v_u_5 = p_u_3[v7].Iterations
		end
	end
	local v8 = v_u_1
	local v_u_9 = setmetatable({}, v8)
	v_u_9.LoopDone = false
	task.spawn(function()
		-- upvalues: (ref) v_u_6, (copy) p_u_3, (copy) p_u_4, (copy) v_u_9, (ref) v_u_5, (copy) p_u_2
		while true do
			v_u_6 = v_u_6 + 1
			for v_u_10 = 1, #p_u_3 do
				task.spawn(function()
					-- upvalues: (ref) p_u_3, (copy) v_u_10, (ref) v_u_6, (ref) p_u_4, (ref) v_u_9
					local v11 = v_u_6 / p_u_3[v_u_10].Iterations
					local _, v12 = math.modf(v11)
					if v12 == 0 then
						p_u_3[v_u_10].Function(p_u_4, v_u_9)
					end
				end)
			end
			if v_u_6 == v_u_5 then
				v_u_6 = 0
			end
			task.wait(p_u_2)
			if v_u_9.LoopDone then
				return
			end
		end
	end)
	return v_u_9
end
function v_u_1.EndLoop(p13)
	p13.LoopDone = true
end
function v_u_1.UpdateFunctions(p14, p15)
	-- upvalues: (copy) v_u_1
	p14:EndLoop()
	local v16 = p14.Data
	local v17 = p14.LoopWait
	v_u_1.LoopWithFunctions(v17, p15, v16)
end
return v_u_1
