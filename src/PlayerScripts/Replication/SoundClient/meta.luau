local meta = {}

function meta:GetSoundsForMaterial(material, type)
	local s,_ = string.gsub(tostring(material), "Enum.Material.", "")
	return game.ReplicatedStorage.Resources.Sounds.MoveSounds:FindFirstChild(s)
end

return meta