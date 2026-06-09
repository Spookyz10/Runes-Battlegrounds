-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
return function(p1)
	if p1:IsA("ParticleEmitter") or (p1:IsA("Trail") or p1:IsA("Beam")) then
		p1.Enabled = false
	end
	for _, v2 in p1:GetDescendants() do
		if v2:IsA("ParticleEmitter") or (v2:IsA("Trail") or v2:IsA("Beam")) then
			v2.Enabled = false
		end
	end
end
