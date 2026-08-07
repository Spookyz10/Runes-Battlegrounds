local Constants = require(script.Parent.Shared.Constants)
local Resources = Constants.Resources
local R6Parts = Constants.R6Parts

return function(Params)
	local Character = Params.Char
	if not Character or not Character.Parent then
		return
	end

	for _, Child in Character:GetDescendants() do
		if Child.Name == "AwakeningAura" then
			Child:Destroy()
		end
	end

	if not Params.AuraName then
		return
	end

	local Aura = Resources.Auras:FindFirstChild(Params.AuraName)
	if not Aura then
		return
	end

	for _, Effect in Aura:GetChildren() do
		if R6Parts[Effect.Name] then
			local Part = Character:FindFirstChild(Effect.Name)
			if Part then
				local EffectClone = Effect:Clone()
				EffectClone.Parent = Part
				if EffectClone:IsA("Attachment") then
					EffectClone.WorldCFrame = Part.CFrame * EffectClone.CFrame
					for _, child in EffectClone:GetDescendants() do
						if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
							child.Enabled = true
						end
					end
				else
					EffectClone.Enabled = true
				end
				EffectClone.Name = "AwakeningAura"
			end
		elseif Effect.Name == "All" then
			for _, Part in Character:GetChildren() do
				if R6Parts[Part.Name] then
					local EffectClone = Effect:Clone()
					EffectClone.Parent = Part
					if EffectClone:IsA("Attachment") then
						EffectClone.WorldCFrame = Part.CFrame * EffectClone.CFrame
						for _, child in EffectClone:GetDescendants() do
							if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
								child.Enabled = true
							end
						end
					else
						EffectClone.Enabled = true
					end
					EffectClone.Name = "AwakeningAura"
				end
			end
		end
	end
end
