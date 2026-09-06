local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Data = require(ReplicatedStorage.Shared.Data).client
local Catalog = require(ReplicatedStorage.Shared.Info.Shop)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Shop = {}
local purple = Color3.fromRGB(128, 104, 231)

local function formatGold(value)
	local formatted = tostring(value):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

	return formatted .. " GOLD"
end

function Shop.Init()
	task.spawn(function()
		local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Shop", 15)

		if not gui then
			warn("Generate Shop in StarterGui using tools/GenerateShopUI.luau.")
			return
		end

		local main = gui.Main

		local function resizeGrid()
			local compact = main.AbsoluteSize.X < 600
			main.Content.Grid.CellSize = UDim2.fromScale(if compact then 0.96 else 0.31, 0.94)
		end

		main:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeGrid)
		resizeGrid()
		main.Tabs.Robux.Activated:Connect(function()
			main.Content.Visible = false
			main.RobuxContent.Visible = true
			main.Empty.Visible = false

			for _, button in main.Tabs:GetChildren() do
				if button:IsA("TextButton") then
					button.BackgroundColor3 = if button.Name == "Robux"
						then purple
						else Color3.fromRGB(40, 40, 57)
				end
			end
		end)

		local cards = {}
		local previews = {}
		local pending = {}
		local selected = "RuneCosmetics"

		local function refresh()
			main.Gold.Text = formatGold(Data.Gold())
			local count = 0
			main.Tabs.Robux.BackgroundColor3 = if main.RobuxContent.Visible
				then purple
				else Color3.fromRGB(40, 40, 57)
			for _, entry in cards do
				local owned = table.find(Data[entry.Category.OwnedField](), entry.Item.Id) ~= nil
				entry.Card.Visible = entry.Item.Category == selected

				if entry.Card.Visible then
					count += 1
				end

				local button = entry.Card.Buy
				button.Text = if owned
					then "Owned"
					elseif pending[entry.Item.Id] then "Purchasing..."
					else "Buy"
				button.Active = not owned and not pending[entry.Item.Id]
				button.AutoButtonColor = button.Active
				button.BackgroundColor3 = if owned then Color3.fromRGB(46, 93, 73) else purple
			end

			main.Empty.Visible = count == 0 and main.Content.Visible
			main.Empty.Text = if selected == "RuneSkins"
				then "Rune skins\nComing soon"
				else "New items coming soon."
			for _, category in Catalog.Categories do
				main.Tabs[category.Id].BackgroundColor3 = if category.Id == selected
						and main.Content.Visible
					then purple
					else Color3.fromRGB(40, 40, 57)
			end
		end

		for _, category in Catalog.Categories do
			main.Tabs[category.Id].Activated:Connect(function()
				selected = category.Id
				main.Content.Visible = true
				main.RobuxContent.Visible = false
				refresh()
			end)

			if category.OwnedField then
				Data[category.OwnedField].Changed(refresh)
			end
		end

		for index, item in Catalog.Items do
			local category

			for _, candidate in Catalog.Categories do
				if candidate.Id == item.Category then
					category = candidate
					break
				end
			end

			if not category or category.ComingSoon or not category.OwnedField then
				continue
			end

			local card = gui.Templates.Item:Clone()
			card.Name = item.Id
			card.LayoutOrder = index
			card.ItemName.Text = item.Name
			card.Description.Text = item.Description or ""
			card.Price.Text = formatGold(item.Price)
			card.Parent = main.Content
			table.insert(cards, { Card = card, Item = item, Category = category })

			if item.Category == "Auras" then
				card.Preview.Visible = false
				card.Image.Visible = true
				card.Image.Image = item.Image or ""
				card.Placeholder.Visible = not item.Image or item.Image == ""
			else
				local source = ReplicatedStorage

				for _, name in item.ModelPath or {} do
					source = source and source:FindFirstChild(name)
				end

				if item.ModelPath and source and (source:IsA("Model") or source:IsA("BasePart")) then
					local world = Instance.new("WorldModel")
					local model = Instance.new("Model")
					local clone = source:Clone()
					clone.Parent = model

					for _, part in model:GetDescendants() do
						if part:IsA("BasePart") then
							part.Anchored = true
							part.CanCollide = false
						elseif part:IsA("BaseScript") then
							part:Destroy()
						end
					end

					local bounds, size = model:GetBoundingBox()
					model:PivotTo(CFrame.new(-bounds.Position) * model:GetPivot())
					model.Parent = world
					world.Parent = card.Preview
					local camera = Instance.new("Camera")
					camera.FieldOfView = 35
					camera.Parent = card.Preview
					card.Preview.CurrentCamera = camera
					table.insert(
						previews,
						{ Card = card, Camera = camera, Radius = math.max(size.Magnitude / 2, 0.1) }
					)
				else
					card.Placeholder.Visible = true
				end
			end

			card.Buy.Activated:Connect(function()
				if pending[item.Id] or table.find(Data[category.OwnedField](), item.Id) then
					return
				end

				local token = {}
				pending[item.Id] = token
				refresh()
				RemoteManager.FireServer("Shop", item.Id)
				task.delay(8, function()
					if pending[item.Id] == token then
						pending[item.Id] = nil
						refresh()
					end
				end)
			end)
		end

		local remote =
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client"):WaitForChild("Notification")
		remote.OnClientEvent:Connect(function(payload)
			if typeof(payload) == "table" and payload.ItemId then
				pending[payload.ItemId] = nil
				refresh()
			end
		end)

		local function close()
			gui.Enabled = false
		end

		main.Close.Activated:Connect(close)
		UserInputService.InputBegan:Connect(function(input, processed)
			if
				not processed
				and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB)
			then
				close()
			end
		end)

		local angle = 0
		RunService.RenderStepped:Connect(function(dt)
			if not gui.Enabled or not main.Content.Visible then
				return
			end

			angle += dt * 0.6

			for _, preview in previews do
				if preview.Card.Visible then
					local size = preview.Card.Preview.AbsoluteSize
					local aspect = size.X / math.max(size.Y, 1)
					local fov = math.atan(math.tan(math.rad(17.5)) * math.min(aspect, 1))
					local distance = preview.Radius / math.sin(fov) * 1.15
					preview.Camera.CFrame = CFrame.lookAt(
						Vector3.new(math.sin(angle), 0.3, math.cos(angle)).Unit * distance,
						Vector3.zero
					)
				end
			end
		end)

		Data.Gold.Changed(refresh)
		refresh()
	end)
end

return Shop
