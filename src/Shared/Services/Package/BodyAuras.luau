local Debris = game:GetService("Debris")


return {
	["LoadAura"] = function(AuraHolder, Character)
		if AuraHolder and Character then
			local AuraClone = AuraHolder:Clone()
			AuraClone.Parent = Character
			
			for _, Child in AuraClone:GetChildren() do
				if Child:IsA("BasePart") then
					local Limb = Character:FindFirstChild(Child.Name)
					
					if Limb then
						local AuraWeld = Instance.new("Weld", Child)
						
						AuraWeld.Part0 = Limb
						AuraWeld.Part1 = Child
					end
				end
			end
			
			return AuraClone
		end
	end,
	
	["ClearAura"] = function(Character, AuraName)
		if Character and AuraName then
			for _, Child in Character:GetChildren() do
				if Child:GetAttribute("IsBodyAura") and Child:GetAttribute("ID") == AuraName then
					
					for _, Particle in Child:GetDescendants() do
						if Particle:IsA("ParticleEmitter") or Particle:IsA("Beam") then
							Particle.Enabled = false
						end
					end
					
					Debris:AddItem(Child, 2)
				end
			end
		end
	end
}
