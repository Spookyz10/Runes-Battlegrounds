local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local Info = require(ReplicatedStorage.Shared.Info.Cosmetics)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Window = require(ReplicatedStorage.Shared.UI.Window)
local Preview = require(ReplicatedStorage.Shared.UI.ItemPreview)

local Cosmetics = {}

function Cosmetics.Init()
	task.spawn(function()
		local gui = UIConstants.PlayerGui:WaitForChild("Cosmetics", 15)

		if not gui then
			return
		end

		Window.Bind(gui)
		local selected = "RuneCosmetics"

		local cards = {}
		local ownedFields = { Auras = "OwnedAuras", RuneCosmetics = "OwnedRuneCosmetics" }
		local equippedFields = { Auras = "EquippedAura", RuneCosmetics = "EquippedRuneCosmetic" }
		local purple = Color3.fromRGB(128, 104, 231)

		local function resize()
			gui.Main.Content.Grid.CellSize =
				UDim2.fromScale(if gui.Main.AbsoluteSize.X < 600 then 0.96 else 0.31, 0.94)
		end

		gui.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		resize()

		local function refresh()
			local count = 0

			for _, entry in cards do
				local owned = table.find(Data[ownedFields[entry.Category]](), entry.Id) ~= nil
				local equipped = UIConstants.Player:GetAttribute(equippedFields[entry.Category]) == entry.Id
				entry.Card.Visible = entry.Category == selected

				if entry.Card.Visible then
					count += 1
				end

				entry.Card.Price.Text = if equipped then "EQUIPPED" elseif owned then "OWNED" else "NOT OWNED"
				entry.Card.Equip.Text = if not owned
					then "Visit shop"
					elseif equipped then "Unequip"
					else "Equip"
				entry.Card.Equip.BackgroundColor3 = if equipped then Color3.fromRGB(46, 93, 73) else purple
			end

			gui.Main.Empty.Visible = count == 0
			gui.Main.Empty.Text = if selected == "RuneSkins"
				then "Rune skins\nComing soon"
				else "Your next look is on the way."
			for _, tab in gui.Main.Tabs:GetChildren() do
				if tab:IsA("TextButton") then
					tab.BackgroundColor3 = if tab.Name == selected then purple else Color3.fromRGB(40, 40, 57)
				end
			end
		end

		for _, tab in gui.Main.Tabs:GetChildren() do
			if tab:IsA("TextButton") then
				tab.Activated:Connect(function()
					selected = tab.Name
					gui.Main.Content.CanvasPosition = Vector2.zero
					refresh()
				end)
			end
		end

		for _, category in { "Auras", "RuneCosmetics" } do
			local names = {}

			for name in Info[category] do
				table.insert(names, name)
			end

			table.sort(names)

			for index, name in names do
				local info = Info[category][name]
				local card = gui.Templates.Item:Clone()
				card.Name = name
				card.ItemName.Text = info.DisplayName or name
				card.Description.Text = info.Description
					or (
						if category == "Auras"
							then "An aura that follows your style."
							else "A finishing touch for your rune."
					)
				card.LayoutOrder = index
				card.Parent = gui.Main.Content

				if category == "Auras" then
					card.Preview.Visible = false
					card.Image.Visible = true
					card.Image.Image = info.Image or ""
					card.Placeholder.Visible = not info.Image or info.Image == ""
				else
					Preview(
						gui,
						card,
						{ ModelPath = info.ModelPath or { "Resources", "RuneCosmetics", name } }
					)
				end

				table.insert(cards, { Card = card, Category = category, Id = name })
				local pending = false
				card.Equip.Activated:Connect(function()
					if pending then
						return
					end

					if not table.find(Data[ownedFields[category]](), name) then
						local shop = UIConstants.PlayerGui:FindFirstChild("Shop")

						if shop then
							gui.Enabled = false
							shop.Enabled = true
						end

						return
					end

					pending = true
					local equipped = UIConstants.Player:GetAttribute(equippedFields[category]) == name
					RemoteManager.FireServer("Cosmetics", if equipped then "Unequip" else "Equip", { Type = category, Name = name })
					task.delay(0.4, function()
						pending = false
					end)
				end)
			end

			Data[ownedFields[category]].Changed(refresh)
			UIConstants.Player:GetAttributeChangedSignal(equippedFields[category]):Connect(refresh)
		end

		refresh()
	end)
end

return Cosmetics
