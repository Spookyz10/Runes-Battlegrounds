-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

--Decompiled by Medal, I take no credit I only Made The dumper and I I.. I iron man
local v_u_1 = game:GetService("Debris")
local v_u_2 = game:GetService("TweenService")
local v_u_3 = game:GetService("Lighting")

return {
	["colorCorrectionFlash"] = function(p4, p5, p6, p7, p8)
		local v9 = p8 or 0.2
		local v10 = Instance.new("ColorCorrectionEffect")
		v10.Brightness = p4
		v10.Saturation = p5
		v10.Contrast = p6
		v10.TintColor = p7 or Color3.fromRGB(255, 255, 255)
		v10.Parent = v_u_3
		
		v_u_2:Create(v10, TweenInfo.new(v9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			["Brightness"] = 0,
			["Saturation"] = 0,
			["Contrast"] = 0,
			["TintColor"] = Color3.fromRGB(255, 255, 255)
		}):Play()
		v_u_1:AddItem(v10, v9)
		
	end,
	
	["PointLight"] = function(p11, p12, p13, p14, p15, p16)
		local v17 = p13 or 1
		local v18 = Instance.new("PointLight")
		v18.Enabled = true
		v18.Color = p12 or Color3.fromRGB(105, 195, 255)
		v18.Range = p14 or 10
		v18.Brightness = p16 or 2
		v18.Parent = p11
		
		v_u_2:Create(v18, TweenInfo.new(v17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			["Brightness"] = 0,
			["Range"] = p15 or (p14 or 10) * 1.5
		}):Play()
		v_u_1:AddItem(v18, v17)
		
		return v18
	end
}
