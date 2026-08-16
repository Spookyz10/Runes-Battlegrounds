--[[
	ImpactDebrisService

	Serviço reutilizável: "assiste" um personagem que acabou de ser
	lançado/nocauteado até ele encostar no chão, e nesse momento manda pro
	client um efeito de rochas de debris estourando do chão pra cima
	(estilo "objeto pesado caiu com força"), tudo customizável (tamanho,
	quantidade, raio).

	Se o personagem não colidir com o chão dentro do Timeout (padrão 10s),
	a watch é cancelada e nenhum efeito é disparado.

	Uso básico (de qualquer skill/ability):

		local ImpactDebrisService = require(SvModules.ImpactDebrisService)

		ImpactDebrisService:WatchLanding(EnemyCharacter, {
			RockCount = 10,
			Radius = 8,
			RockSize = Vector3.new(2, 2, 2),
			Timeout = 10,
		})

	Retorna uma função `Cancel()` caso a skill precise abortar a watch
	manualmente (ex: o personagem morreu, a skill foi cancelada, etc).
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local ImpactDebrisService = {}

local DEFAULT_TIMEOUT = 10
local DEFAULT_CHECK_RAY_DIST = 3.5
local DEFAULT_REQUIRED_GROUND_TIME = 0.08
local DEFAULT_ROCK_COUNT = 8
local DEFAULT_RADIUS = 6
local DEFAULT_ROCK_SIZE = Vector3.new(1.5, 1.5, 1.5)

local GroundRayParams = RaycastParams.new()
GroundRayParams.FilterType = Enum.RaycastFilterType.Include
GroundRayParams.FilterDescendantsInstances = { workspace.Map }
GroundRayParams.IgnoreWater = true

function ImpactDebrisService:WatchLanding(Character, Config)
	Config = Config or {}

	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return function() end
	end

	local Timeout = Config.Timeout or DEFAULT_TIMEOUT
	local RockCount = Config.RockCount or DEFAULT_ROCK_COUNT
	local Radius = Config.Radius or DEFAULT_RADIUS
	local RockSize = Config.RockSize or DEFAULT_ROCK_SIZE
	local RayDist = Config.RayDist or DEFAULT_CHECK_RAY_DIST
	local RequiredGroundTime = Config.RequiredGroundTime or DEFAULT_REQUIRED_GROUND_TIME
	local OnLand = Config.OnLand

	local active = true
	local groundContactStart = nil
	local conn
	local timeoutThread

	local function stop()
		if not active then
			return
		end
		active = false

		if conn then
			conn:Disconnect()
			conn = nil
		end
		if timeoutThread then
			task.cancel(timeoutThread)
			timeoutThread = nil
		end
	end

	local function fireImpact(position)
		RemoteManager.FireAllClients("ReplicateTask", "ImpactDebrisBurst", {
			Position = position,
			RockCount = RockCount,
			Radius = Radius,
			RockSize = RockSize,
		})

		if OnLand then
			task.spawn(OnLand, position)
		end
	end

	conn = RunService.Heartbeat:Connect(function()
		if not active then
			return
		end

		if not HumRP or not HumRP.Parent then
			stop()
			return
		end

		local Velocity = HumRP.AssemblyLinearVelocity
		if Velocity.Y > 2 then
			groundContactStart = nil
			return
		end

		local Result = workspace:Raycast(HumRP.Position, Vector3.new(0, -RayDist, 0), GroundRayParams)
		if Result then
			groundContactStart = groundContactStart or os.clock()

			if (os.clock() - groundContactStart) >= RequiredGroundTime then
				local Position = Result.Position
				stop()
				fireImpact(Position)
			end
		else
			groundContactStart = nil
		end
	end)

	timeoutThread = task.delay(Timeout, function()
		stop()
	end)

	return stop
end

return ImpactDebrisService
