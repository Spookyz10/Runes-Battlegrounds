local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Donations = {}

function Donations.Init()
	local Misc = PlayerGui:WaitForChild("Misc")
	local Main = Misc:WaitForChild("Main")

	for _, Descendant in Main:GetDescendants() do
		if Descendant:IsA("TextButton") then
			local ID = Descendant:FindFirstChild("ID")
			if ID then
				Descendant.Activated:Connect(function()
					MarketplaceService:PromptProductPurchase(Player, ID.Value)
				end)
			end
		end
	end
end

return Donations
