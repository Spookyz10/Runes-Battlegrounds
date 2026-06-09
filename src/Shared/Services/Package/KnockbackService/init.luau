local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")


local KnockbackModule = {
	["Knockback"] = function(Character, Params)
		if Character and Params then
			if Character.Anchored or not Character:FindFirstChild("RootAttachment") then
				
				return
					
			elseif Params.direction and Params.force then
				if not Params.duration then
					Params.duration = 0.1
				end
				
				local Direction = Params.direction
				local Force = Params.force
				local Duration = Params.duration
				local IsPlayer = nil
				
				
				pcall(function()
					IsPlayer = not RNS:IsServer() or Players:GetPlayerFromCharacter(Character.Parent)
					
					if not IsPlayer then
						Character:SetNetworkOwner(nil)
					end
				end)
				
				
				for _, Child in Character:GetDescendants() do
					if Child:IsA("LinearVelocity") then
						Child:Destroy()
					end
				end
				
				
				local LinearVelocity = script.LinearVelocity:Clone()
				Debris:AddItem(LinearVelocity, Duration)
				LinearVelocity.Parent = Character
				LinearVelocity.Attachment0 = Character.RootAttachment
				LinearVelocity.VectorVelocity = Direction * Force * Character:GetMass() * 0.5
				LinearVelocity.ForceLimitsEnabled = false
			end
		else
			return
		end
	end,
}

return KnockbackModule
