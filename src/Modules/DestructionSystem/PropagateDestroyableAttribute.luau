local function propagateDestroyableAttribute(root: Instance)
	local propagatedCount = 0

	local function markDescendants(container: Instance)
		for _, desc in container:GetDescendants() do
			if desc:IsA("BasePart") and desc:GetAttribute("Destroyable") ~= true then
				desc:SetAttribute("Destroyable", true)
				propagatedCount += 1
			end
		end
	end

	for _, desc in root:GetDescendants() do
		if (desc:IsA("Model") or desc:IsA("Folder")) and desc:GetAttribute("Destroyable") == true then
			markDescendants(desc)
		end
	end

	if (root:IsA("Model") or root:IsA("Folder")) and root:GetAttribute("Destroyable") == true then
		markDescendants(root)
	end

	print("[PropagateDestroyableAttribute] Atributo propagado pra", propagatedCount, "parts em", root:GetFullName())
end

return propagateDestroyableAttribute
