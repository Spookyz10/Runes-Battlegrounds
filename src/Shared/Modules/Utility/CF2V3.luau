return function(CF: CFrame) : Vector3
	local rx, ry, rz = CF:ToOrientation()
	
	return Vector3.new(math.deg(rx), math.deg(ry), math.deg(rz))
end