return function(Params)
	local ownerId = Params.ownerId

	if not shared._indicators or not ownerId or not shared._indicators[ownerId] then
		return
	end

	local ind = shared._indicators[ownerId]

	if ind.conn then
		ind.conn:Disconnect()
	end

	if ind.part and ind.part.Parent then
		for _, desc in ind.part:GetDescendants() do
			if desc:IsA("Beam") or desc:IsA("ParticleEmitter") then
				desc.Enabled = false
			end
		end
		task.delay(5, function()
			if ind.part and ind.part.Parent then
				ind.part:Destroy()
			end
		end)
	end

	shared._indicators[ownerId] = nil
end
