return function(Character)
	for _, BodyMover in Character:GetDescendants() do
		if BodyMover:IsA("BodyVelocity") or BodyMover:IsA("LinearVelocity") or BodyMover:IsA("BodyPosition") then
			BodyMover:Destroy()
		end
	end
end
