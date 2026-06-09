-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v1 = {}
local v_u_2 = game:GetService("TweenService")
function v1.TweenProperty(p3, p4, p5, p6, p7, p8)
	-- upvalues: (copy) v_u_2
	if p3 then
		if p8 == nil then
			p8 = false
		end
		return v_u_2:Create(p3, TweenInfo.new(p4, Enum.EasingStyle[p5], Enum.EasingDirection[p6], 0, p8), p7)
	end
end
function v1.TweenGroup(p9, p10)
	if typeof(p9) ~= "table" then
		error("SEQUENCE MUST BE A TABLE!!!")
	end
	for v11 = 1, #p9 do
		p9[v11]:Play()
		if p10 > 0 then
			task.wait(p10)
		end
	end
end
function v1.TweenSequence(p_u_12)
	if typeof(p_u_12) ~= "table" then
		error("SEQUENCE MUST BE A TABLE!!!")
	end
	task.spawn(function()
		-- upvalues: (copy) p_u_12
		for v13 = 1, #p_u_12 do
			local v14 = p_u_12[v13]
			v14:Play()
			v14.Completed:Wait()
		end
	end)
	return p_u_12[#p_u_12]
end
return v1
