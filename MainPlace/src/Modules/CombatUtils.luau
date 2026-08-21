return {
	AddValue = function(Parent, ClassName, Value, Name)
		local existing = Parent:FindFirstChild(Name)
		if existing then
			existing:Destroy()
		end
		local v = Instance.new(ClassName)
		v.Name = Name
		v.Value = Value
		v.Parent = Parent
		return v
	end,
}
