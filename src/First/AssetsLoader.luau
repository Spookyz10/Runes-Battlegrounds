--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

--Module
local AssetsLoader = {}

--Runtime
local function tableCount(Table)
	local Count = 0

	for _ in pairs(Table) do
		Count = Count + 1
	end

	return Count
end

function AssetsLoader:LoadAssets(Containers)
	tick()
	RunService:IsStudio()

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

	for _, Container in ipairs(Containers) do
		if #Container:GetChildren() > 0 then
			local ToPreload = {}

			for _, Desc in ipairs(Container:GetDescendants()) do
				if table.find(AssetClasses, Desc.ClassName) then
					local AssetID = ""

					if Desc:IsA("ImageLabel") and Desc.Image and Desc.Image ~= "" then
						AssetID = Desc.Image
					elseif
						(Desc:IsA("Decal") or Desc:IsA("ParticleEmitter") or Desc:IsA("Beam") or Desc:IsA("Trail"))
						and Desc.Texture
						and Desc.Texture ~= ""
					then
						AssetID = Desc.Texture
					elseif (Desc:IsA("MeshPart") or Desc:IsA("SpecialMesh")) and Desc.MeshId and Desc.MeshId ~= "" then
						AssetID = Desc.MeshId
					elseif Desc:IsA("Sound") and Desc.SoundId and Desc.SoundId ~= "" then
						AssetID = Desc.SoundId
					end

					if AssetID == "" then
						RunService:IsStudio()
					else
						if not SeenAssets[AssetID] then
							local IsOk, Status = pcall(function()
								return ContentProvider:GetAssetFetchStatus(AssetID)
							end)

							if IsOk then
								if Status == Enum.AssetFetchStatus.None or Status == Enum.AssetFetchStatus.TimedOut then
									table.insert(ToPreload, Desc)

									RunService:IsStudio()
								end
							else
								RunService:IsStudio()
							end

							SeenAssets[AssetID] = true
						else
							RunService:IsStudio()
						end
					end
				end
			end

			if tableCount(ToPreload) > 0 then
				PreloadContainer[Container.Name] = ToPreload
			else
				warn(
					tostring(Container) .. " already loaded!",
					RunService:IsClient() and "On Client side." or "On Server side."
				)
			end
		end
	end

	local function progressCallback()
		RunService:IsStudio()
	end

	for name, items in pairs(PreloadContainer) do
		tick()

		ContentProvider:PreloadAsync(items, progressCallback)
		PreloadContainer[name] = nil
		RunService:IsStudio()
	end

	RunService:IsStudio()
end

return AssetsLoader
