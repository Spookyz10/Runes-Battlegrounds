local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("Ranked")
local Main = GUI:WaitForChild("Main")
local EnterButton = Main:WaitForChild("Enter")

local MODE = "1v1"

local RankedClient = {}

local queued = false

local function setQueued(isQueued: boolean)
	queued = isQueued
	EnterButton.Text = isQueued and "SAIR DA FILA" or "ENTRAR NA FILA"
end

local function onJoin()
	EnterButton.Active = false

	local Result = RemoteManager.InvokeServer("RankedQueue", "Join", { Mode = MODE })

	EnterButton.Active = true

	if typeof(Result) ~= "table" or not Result.Success then
		print("[Ranked] Falha ao entrar na fila:", typeof(Result) == "table" and Result.Message or "erro desconhecido")
		return
	end

	print("[Ranked] Entrou na fila (" .. MODE .. ")")
	setQueued(true)
end

local function onLeave()
	EnterButton.Active = false

	local Result = RemoteManager.InvokeServer("RankedQueue", "Leave")

	EnterButton.Active = true

	if typeof(Result) == "table" and Result.Success then
		print("[Ranked] Saiu da fila")
	end

	setQueued(false)
end

local function onEnterPressed()
	if queued then
		onLeave()
	else
		onJoin()
	end
end

function RankedClient.Show()
	GUI.Enabled = true
end

function RankedClient.Hide()
	GUI.Enabled = false
end

function RankedClient.Init()
	setQueued(false)

	EnterButton.Activated:Connect(onEnterPressed)

	local RankedQueueUpdateRemote = RemoteManager.GetRemote("RankedQueueUpdate", "Client")
	if RankedQueueUpdateRemote then
		RankedQueueUpdateRemote.OnClientEvent:Connect(function(kind, params)
			if kind == "MatchFound" then
				print("[Ranked] Partida encontrada, teleportando...")
				setQueued(false)
			elseif kind == "QueueLeftForcefully" then
				print("[Ranked] Removido da fila:", params and params.Message or "")
				setQueued(false)
			end
		end)
	end
end

return RankedClient
