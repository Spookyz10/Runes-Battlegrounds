local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local TethersAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Solar.Tethers
local TethersVFXState = require(script.Parent.Shared.TethersVFXState)

local activeVFX = TethersVFXState.activeVFX

local function getKey(casterChar)
	return tostring(casterChar)
end

local function spawnFlareArms(casterChar)
	local template = TethersAssets:FindFirstChild("FlareArm")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local arm = casterChar:FindFirstChild(armName)
		if arm then
			for _, child in template:GetChildren() do
				local clone = child:Clone()
				clone.Parent = arm
				table.insert(spawned, clone)
			end
		end
	end

	return spawned
end

--[[
	Spawna as correntes (FlareChains) e anima o tween do braço do caster até o victim.
	travelTime: tempo em segundos para a corrente "viajar" visualmente.

	Lógica do tween:
	  - Cria uma Part âncora na posição do braço do caster
	  - Tweena essa âncora até a posição do braço do victim durante travelTime
	  - O Beam da corrente usa Attachment0 = braço do caster, Attachment1 = âncora em movimento
	  - Ao chegar no destino, reconecta o Beam ao braço do victim (posição final travada)
]]
local function spawnFlareChains(casterChar, victimChar, travelTime)
	local template = TethersAssets:FindFirstChild("FlareChains")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local casterArm = casterChar:FindFirstChild(armName)
		local victimArm = victimChar and victimChar:FindFirstChild(armName)

		if not casterArm then
			continue
		end

		local chain = template:Clone()
		chain.Parent = casterArm

		-- Âncora viajante: começa no braço do caster e vai até o braço do victim
		local travelAnchor = Instance.new("Part")
		travelAnchor.Name = "ChainTravelAnchor"
		travelAnchor.Anchored = true
		travelAnchor.CanCollide = false
		travelAnchor.CanTouch = false
		travelAnchor.CanQuery = false
		travelAnchor.Transparency = 1
		travelAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
		travelAnchor.CFrame = casterArm.CFrame -- começa no braço do caster
		travelAnchor.Parent = workspace.Debris

		local travelAttachment = Instance.new("Attachment")
		travelAttachment.Parent = travelAnchor

		-- Reconecta o Attachment1 do beam para a âncora viajante durante o tween
		for _, beam in chain:GetDescendants() do
			if beam:IsA("Beam") then
				beam.Attachment1 = travelAttachment
			end
		end

		-- VictimPart: vai para o braço do victim após o tween terminar
		local victimPart = chain:FindFirstChild("Victim")

		-- Tween da âncora do braço do caster até o braço do victim
		if victimArm and travelTime and travelTime > 0 then
			local targetCF = victimArm.CFrame

			-- Usa Heartbeat para atualizar o destino dinamicamente (victim pode estar caindo)
			-- durante o travel, e no fim ancora no victim
			local elapsed = 0
			local startCF = travelAnchor.CFrame
			local conn
			conn = RunService.Heartbeat:Connect(function(dt)
				elapsed += dt

				if not travelAnchor or not travelAnchor.Parent then
					conn:Disconnect()
					return
				end
				if not casterArm or not casterArm.Parent then
					conn:Disconnect()
					travelAnchor:Destroy()
					return
				end

				local t = math.clamp(elapsed / travelTime, 0, 1)
				-- Ease out: corrente acelera no início e desacelera ao chegar
				local easedT = 1 - (1 - t) ^ 2

				-- Destino atualizado a cada frame (victim pode se mover enquanto cai lentamente)
				local currentTarget = (victimArm and victimArm.Parent) and victimArm.CFrame or targetCF
				travelAnchor.CFrame = startCF:Lerp(currentTarget, easedT)

				if t >= 1 then
					conn:Disconnect()

					-- Chegou: move o VictimPart para o braço do victim e reconecta o beam
					if victimPart and victimArm and victimArm.Parent then
						victimPart.Parent = victimArm

						for _, beam in chain:GetDescendants() do
							if beam:IsA("Beam") then
								-- Reconecta para o attachment do victimArm (posição final)
								local finalAttach = victimArm:FindFirstChildOfClass("Attachment")
								if finalAttach then
									beam.Attachment1 = finalAttach
								end
							end
						end
					end

					-- Limpa a âncora viajante, não é mais necessária
					travelAnchor:Destroy()
				end
			end)

			table.insert(spawned, {
				chain = chain,
				victimPart = victimPart,
				travelAnchor = travelAnchor,
				travelConn = conn,
			})
		else
			-- Sem travelTime: comportamento original (coloca imediatamente no victim)
			if victimPart and victimArm then
				victimPart.Parent = victimArm
			end
			travelAnchor:Destroy()

			table.insert(spawned, {
				chain = chain,
				victimPart = victimPart,
				travelAnchor = nil,
				travelConn = nil,
			})
		end
	end

	return spawned
end

return function(params)
	local casterChar = params.casterChar
	local victimChar = params.victimChar
	local travelTime = params.travelTime or 0 -- novo parâmetro vindo do server

	if not casterChar then
		return
	end

	local key = getKey(casterChar)

	-- Limpa VFX anterior se existir
	local existing = activeVFX[key]
	if existing then
		for _, c in existing.chains or {} do
			if c.travelConn then
				c.travelConn:Disconnect()
			end
			if c.travelAnchor and c.travelAnchor.Parent then
				c.travelAnchor:Destroy()
			end
			if c.chain and c.chain.Parent then
				c.chain:Destroy()
			end
			if c.victimPart and c.victimPart.Parent then
				c.victimPart:Destroy()
			end
		end
		for _, part in existing.armParts or {} do
			if part and part.Parent then
				part:Destroy()
			end
		end
		activeVFX[key] = nil
	end

	activeVFX[key] = {
		armParts = spawnFlareArms(casterChar),
		chains = spawnFlareChains(casterChar, victimChar, travelTime),
	}
end
