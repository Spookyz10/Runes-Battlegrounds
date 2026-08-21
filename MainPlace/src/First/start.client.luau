local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = ReplicatedStorage:WaitForChild("Resources")
require(script.Parent:WaitForChild("AssetsLoader")):LoadAssets({
	Resources,
	workspace,
})
