return function(params)
	local container = params.container
	if not container then
		return
	end

	for _, enably in container:GetDescendants() do
		if enably:IsA("ParticleEmitter") or enably:IsA("Beam") then
			enably.Enabled = true
		end
	end
end
