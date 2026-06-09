-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("Debris")
local v_u_2 = game:GetService("TweenService")
return function(p3, p4, p5, p6, p7, p8)
	-- upvalues: (copy) v_u_2, (copy) v_u_1
	local v9 = p5 or 1
	local v10 = Instance.new("PointLight")
	v10.Enabled = true
	v10.Color = p4 or Color3.fromRGB(105, 195, 255)
	v10.Range = p6 or 10
	v10.Brightness = p8 or 2
	v10.Parent = p3
	v_u_2:Create(v10, TweenInfo.new(v9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		["Brightness"] = 0,
		["Range"] = p7 or (p6 or 10) * 1.5
	}):Play()
	v_u_1:AddItem(v10, v9)
	return v10
end
