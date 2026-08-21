local module = {}

local function HasProperty(_Instance, Property)
	return pcall(function()
		_Instance[Property] = _Instance[Property]
	end)
end

function module:SetCollisionGroup(Character, Group)
	if not Character or not Character.Parent then
		return
	end

	for _, Part: Part in Character:GetDescendants() do
		if HasProperty(Part, "CollisionGroup") then
			Part.CollisionGroup = Group
		end
	end
end

return module
