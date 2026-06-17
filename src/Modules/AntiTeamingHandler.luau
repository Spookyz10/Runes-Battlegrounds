local AntiTeamingHandler = {}

local iFramesService = require(script.Parent.iFramesService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DAMAGE_THRESHOLD = 10
local IFRAME_DURATION = 2
local BUFF_DURATION = 10
local DAMAGE_MULT = 1.2

local tracking = {}

local function getTracking(Character)
	if not tracking[Character] then
		tracking[Character] = {
			accumulated = 0,
			buffActive = false,
			buffTimer = nil,
		}

		Character.Destroying:Connect(function()
			tracking[Character] = nil
		end)
	end
	return tracking[Character]
end

local function activateBuff(Character)
	local data = getTracking(Character)

	if data.buffActive then
		return
	end

	data.buffActive = true
	data.accumulated = 0

	iFramesService:AddStrongiFrames(Character)

	Character:SetAttribute("AntiTeamingBuff", true)
	Character:SetAttribute("AntiTeamingDamageMult", DAMAGE_MULT)

	ReplicateSet:FireAllClients("AntiTeamingActivated", { char = Character })

	task.delay(IFRAME_DURATION, function()
		if Character and Character.Parent then
			iFramesService:RemoveiFrames(Character, "Strong")
		end
	end)

	if data.buffTimer then
		task.cancel(data.buffTimer)
	end

	data.buffTimer = task.delay(BUFF_DURATION, function()
		if Character and Character.Parent then
			Character:SetAttribute("AntiTeamingBuff", nil)
			Character:SetAttribute("AntiTeamingDamageMult", nil)
			ReplicateSet:FireAllClients("AntiTeamingExpired", { char = Character })
		end

		if tracking[Character] then
			tracking[Character].buffActive = false
			tracking[Character].accumulated = 0
			tracking[Character].buffTimer = nil
		end
	end)
end

function AntiTeamingHandler:OnDamageReceived(Damaged, Damager, Damage)
	if not Damaged or not Damaged.Parent then
		return
	end
	if not Damager or not Damager.Parent then
		return
	end

	local DamagedLog = Damaged:FindFirstChild("DamagedLog")
	if not DamagedLog then
		return
	end

	local previousAttacker = DamagedLog.Value
	if not previousAttacker or previousAttacker == Damager then
		return
	end

	local data = getTracking(Damaged)

	if data.buffActive then
		return
	end

	data.accumulated += Damage

	if data.accumulated >= DAMAGE_THRESHOLD then
		activateBuff(Damaged)
	end
end

function AntiTeamingHandler:GetDamageMultiplier(Character)
	if not Character or not Character.Parent then
		return 1
	end
	return Character:GetAttribute("AntiTeamingDamageMult") or 1
end

function AntiTeamingHandler:IsBuffActive(Character)
	if not Character or not Character.Parent then
		return false
	end
	return Character:GetAttribute("AntiTeamingBuff") == true
end

function AntiTeamingHandler:Cleanup(Character)
	local data = tracking[Character]
	if data then
		if data.buffTimer then
			task.cancel(data.buffTimer)
		end
		tracking[Character] = nil
	end

	if Character and Character.Parent then
		Character:SetAttribute("AntiTeamingBuff", nil)
		Character:SetAttribute("AntiTeamingDamageMult", nil)
	end
end

return AntiTeamingHandler
