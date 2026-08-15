local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("Store")
local Container = GUI:FindFirstChild("Main"):WaitForChild("Container")

local UI = {}

local buttonsById = {}

local function refreshButton(id)
	local button = buttonsById[id]
	if not button then
		return
	end
	if Data.OwnedPasses[id] then
		button.Parent.Owned.Visible = true
		button.Visible = false
	end
end

function UI.Init()
	for _, button in Container:GetDescendants() do
		if button:IsA("ImageButton") then
			local id = button:FindFirstChild("ID").Value
			buttonsById[id] = button

			if Data.OwnedPasses[id] then
				button.Parent.Owned.Visible = true
			else
				button.MouseButton1Click:Connect(function()
					MarketplaceService:PromptGamePassPurchase(UIConstants.Player, id)
				end)
			end
		end
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if player ~= UIConstants.Player or not wasPurchased then
			return
		end
		Data.OwnedPasses[gamePassId] = true
		refreshButton(gamePassId)
	end)
end

return UI