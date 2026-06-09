local module = {}

function module.GetLive()
	local live = {workspace.Effects}
	
	for i, obj in pairs(workspace:GetChildren()) do
		if obj:FindFirstChild("Humanoid") then
			table.insert(live, obj)
		end
	end
	
	return live
end

return module
