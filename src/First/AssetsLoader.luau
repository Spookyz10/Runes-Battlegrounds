local ContentProvider = game:GetService("ContentProvider")

local AssetsLoader = {}

function AssetsLoader:LoadAssets(Containers, onProgress)
	local AssetClasses = {
		"ImageLabel",
		"ParticleEmitter",
		"Beam",
		"Trail",
		"Decal",
		"SpecialMesh",
		"MeshPart",
		"Sound",
	}

	local SeenAssets = {}
	local PreloadContainer = {}
	local totalAssets = 0

	for _, Container in ipairs(Containers) do
		if #Container:GetChildren() > 0 then
			local ToPreload = {}

			for _, Desc in ipairs(Container:GetDescendants()) do
				if table.find(AssetClasses, Desc.ClassName) then
					local AssetID = ""

					if Desc:IsA("ImageLabel") and Desc.Image ~= "" then
						AssetID = Desc.Image
					elseif
						(Desc:IsA("Decal") or Desc:IsA("ParticleEmitter") or Desc:IsA("Beam") or Desc:IsA("Trail"))
						and Desc.Texture ~= ""
					then
						AssetID = Desc.Texture
					elseif (Desc:IsA("MeshPart") or Desc:IsA("SpecialMesh")) and Desc.MeshId ~= "" then
						AssetID = Desc.MeshId
					elseif Desc:IsA("Sound") and Desc.SoundId ~= "" then
						AssetID = Desc.SoundId
					end

					if AssetID ~= "" and not SeenAssets[AssetID] then
						local ok, status = pcall(ContentProvider.GetAssetFetchStatus, ContentProvider, AssetID)

						if
							ok and (status == Enum.AssetFetchStatus.None or status == Enum.AssetFetchStatus.TimedOut)
						then
							table.insert(ToPreload, Desc)
							totalAssets += 1
						end

						SeenAssets[AssetID] = true
					end
				end
			end

			if #ToPreload > 0 then
				PreloadContainer[Container.Name] = ToPreload
			end
		end
	end

	local loaded = 0

	for _, items in pairs(PreloadContainer) do
		ContentProvider:PreloadAsync(items, function(_, status)
			if status ~= Enum.AssetFetchStatus.Loading then
				loaded += 1
				if onProgress then
					onProgress(loaded, totalAssets)
				end
			end
		end)
	end
end

return AssetsLoader
