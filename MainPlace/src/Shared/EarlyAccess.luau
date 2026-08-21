local EarlyAccess = {}

EarlyAccess.GamepassId = 1947440899

EarlyAccess.Movesets = {
	["Shattered"] = true,
}

function EarlyAccess:IsEarlyAccess(MovesetName)
	return self.Movesets[MovesetName] == true
end

return EarlyAccess