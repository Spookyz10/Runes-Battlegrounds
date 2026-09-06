local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Catalog = require(ReplicatedStorage.Shared.Info.Store)

local Gamepass = {}

function Gamepass.Init()
	task.spawn(function()
		local gui = UIConstants.PlayerGui:WaitForChild("Shop", 15)

		if not gui then
			return
		end

		local cards = {}
		local prompting

		local function refresh()
			for id, entry in cards do
				local owned = table.find(Data.OwnedPasses(), id) ~= nil
				entry.Card.Buy.Text = if owned
					then "Owned"
					elseif prompting == id then "Opening..."
					elseif entry.Available then "Buy with Robux"
					else "Unavailable"
				entry.Card.Buy.Active = not owned and entry.Available and prompting == nil
				entry.Card.Buy.AutoButtonColor = entry.Card.Buy.Active
			end
		end

		local function resize()
			gui.Main.RobuxContent.Grid.CellSize =
				UDim2.fromScale(if gui.Main.AbsoluteSize.X < 600 then 0.96 else 0.31, 0.94)
		end

		gui.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		resize()

		for index, item in Catalog do
			local card = gui.Templates.Item:Clone()
			card.Name = tostring(item.Id)
			card.ItemName.Text = item.Name
			card.Description.Text = item.Description
			card.Price.Text = "Loading price..."
			card.Preview.Visible = false
			card.Image.Visible = true
			card.LayoutOrder = index
			card.Visible = true
			card.Parent = gui.Main.RobuxContent
			local entry = { Card = card, Available = false }
			cards[item.Id] = entry
			card.Buy.Activated:Connect(function()
				if prompting or not entry.Available or table.find(Data.OwnedPasses(), item.Id) then
					return
				end

				prompting = item.Id
				refresh()
				local ok = pcall(function()
					MarketplaceService:PromptGamePassPurchase(UIConstants.Player, item.Id)
				end)

				if not ok then
					prompting = nil
					card.Price.Text = "Please try again"
					refresh()
				end
			end)

			task.spawn(function()
				local ok, info = pcall(function()
					return MarketplaceService:GetProductInfoAsync(item.Id, Enum.InfoType.GamePass)
				end)

				if ok and info then
					entry.Available = info.IsForSale == true and typeof(info.PriceInRobux) == "number"
					card.Price.Text = if entry.Available
						then tostring(info.PriceInRobux) .. " ROBUX"
						else "Not for sale"
					card.Image.Image = "rbxassetid://" .. tostring(info.IconImageAssetId or 0)
				else
					card.Price.Text = "Price unavailable"
				end

				refresh()
			end)
		end

		MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id)
			if player == UIConstants.Player and prompting == id then
				prompting = nil
				refresh()
			end
		end)

		Data.OwnedPasses.Changed(refresh)
		refresh()
	end)
end

return Gamepass
