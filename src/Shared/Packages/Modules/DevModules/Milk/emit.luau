-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
return function(p1)
	for _, v_u_2 in p1:GetDescendants() do
		if v_u_2:IsA("ParticleEmitter") then
			local v3 = v_u_2:GetAttribute("EmitDelay")
			if v3 then
				task.delay(v3, function()
					-- upvalues: (copy) v_u_2
					v_u_2:Emit(v_u_2:GetAttribute("EmitCount"))
				end)
			else
				v_u_2:Emit(v_u_2:GetAttribute("EmitCount"))
			end
		end
	end
end
