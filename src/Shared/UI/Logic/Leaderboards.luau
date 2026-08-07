local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local BoardFolders = {
	Kills = "Kills",
	Donated = "Donations",
}

local BoardLabels = {
	Kills = "Kills",
	Donated = "Donated",
}

local BoardColors = {
	Kills = Color3.fromRGB(255, 0, 0),
	Donated = Color3.fromRGB(15, 218, 0),
}

local RankStyles = { "Top1", "Top2", "Top3" }
local REFRESH_INTERVAL = 60

local ActiveEntries = {
	Kills = {},
	Donated = {},
}

local Leaderboard = {}

local function FormatValue(value)
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(value)
end

local function ApplyRank(Entry, rank)
	Entry.Basic.Enabled = rank > 3
	for index, styleName in RankStyles do
		Entry[styleName].Enabled = rank == index
	end
end

local function ApplyStat(Entry, board, value)
	local Stat = Entry.Stat
	Stat.RichText = true
	Stat.TextColor3 = BoardColors[board]
	Stat.Text = BoardLabels[board] .. ':<br/><font color="rgb(255,255,255)">' .. FormatValue(value) .. "</font>"
end

local function CreateEntry(board, rank, data, Container)
	local Template = ReplicatedStorage.Resources.UI.Templates.Leaderboard
	local Entry = Template:Clone()

	ApplyRank(Entry, rank)

	Entry.PlayerName.Text = data.Name
	ApplyStat(Entry, board, data.Value)

	local success, thumbnail = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		data.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)

	if success then
		Entry.Player.Image = thumbnail
	end

	Entry.LayoutOrder = rank
	Entry.Parent = Container

	table.insert(ActiveEntries[board], Entry)
end

local function LoadBoard(board)
	local FolderName = BoardFolders[board]
	if not FolderName then
		return
	end

	local Leaderboards = PlayerGui:WaitForChild("Leaderboards")
	local BoardFrame = Leaderboards:FindFirstChild(FolderName)
	if not BoardFrame then
		return
	end

	local Container = BoardFrame:FindFirstChild("Container")
	if not Container then
		return
	end

	local entries = RemoteManager.InvokeServer("Leaderboards", board)
	if not entries then
		return
	end

	for _, Entry in ActiveEntries[board] do
		Entry:Destroy()
	end
	table.clear(ActiveEntries[board])

	for rank, data in entries do
		CreateEntry(board, rank, data, Container)
	end
end

function Leaderboard.Refresh()
	for board in BoardFolders do
		LoadBoard(board)
	end
end

function Leaderboard.Init()
	Leaderboard.Refresh()

	task.spawn(function()
		while task.wait(REFRESH_INTERVAL) do
			Leaderboard.Refresh()
		end
	end)
end

return Leaderboard
