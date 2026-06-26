local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DebrisFolder = workspace.Debris

-- Stopwatch: cronômetro simples que suporta pause/resume
local Stopwatch = {}
Stopwatch.__index = Stopwatch
Stopwatch.__call = function(self)
	return self:GetStopwatchTime()
end

function Stopwatch.new(dontStart)
	local self = setmetatable({}, Stopwatch)
	self.start = not dontStart and tick() or nil
	self.freezeStart = nil
	self.frozenTimeAccumulated = 0
	return self
end

function Stopwatch.GetTimePassed(startTick)
	return tick() - startTick
end

function Stopwatch:Reset()
	self.start = tick()
	self.freezeStart = nil
	self.frozenTimeAccumulated = 0
end

function Stopwatch:UpdateFrozenTime()
	if not self.freezeStart then
		return false
	end
	self.frozenTimeAccumulated += Stopwatch.GetTimePassed(self.freezeStart)
	self.freezeStart = tick()
	return true
end

function Stopwatch:Freeze()
	if self:UpdateFrozenTime() then
		return
	end
	self.freezeStart = tick()
end

function Stopwatch:Unfreeze()
	self:UpdateFrozenTime()
	self.freezeStart = nil
end

function Stopwatch:HasPassedTime(duration, dontReset)
	if not self.start or duration <= self() then
		if not dontReset then
			self:Reset()
		end
		return true
	end
	return false
end

function Stopwatch:GetStopwatchTime()
	local now = tick()
	self.start = self.start or now
	self:UpdateFrozenTime()
	return Stopwatch.GetTimePassed(self.start) - self.frozenTimeAccumulated
end

function Stopwatch:GetAlpha(duration, unclamped, offset)
	offset = offset or 0
	local alpha = (self() + offset) / duration
	if unclamped then
		return alpha
	end
	return math.clamp(alpha, 0, 1)
end

-- Roda um loop por `duration` segundos, chamando `callback(alpha, elapsed, deltaTime)` a cada heartbeat
function Stopwatch.RunTimedLoop(duration, callback, delay)
	delay = delay or 0
	local timer = Stopwatch.new()
	local deltaTimer = Stopwatch.new()
	while
		not timer:HasPassedTime(duration + delay, true)
		and not callback(timer:GetAlpha(duration, nil, delay), timer(), deltaTimer())
	do
		deltaTimer:Reset()
		RunService.Heartbeat:Wait()
	end
end

-- MathUtils: funções matemáticas auxiliares
local MathUtils = {}

function MathUtils.RandomBetween(min, max)
	return Random.new():NextNumber(min or 0.8, max or 1.2)
end

function MathUtils.RandomSign()
	return math.random(0, 1) == 1 and 1 or -1
end

function MathUtils.RandomAngle()
	return MathUtils.RandomBetween(-math.pi * 2, math.pi * 2)
end

function MathUtils.Round(value, decimalPlaces)
	decimalPlaces = decimalPlaces or 0
	local factor = 10 ^ decimalPlaces
	local rounded = math.round(value * factor) * (1 / factor)
	return tonumber(string.format("%." .. decimalPlaces .. "f", rounded))
end

function MathUtils.NumberToVector3(n)
	return Vector3.new(n, n, n)
end

-- Escala um valor (NumberSequence, NumberRange, ou número) de um tamanho base para um novo tamanho
function MathUtils.ScaleValue(baseSize, value, newSize)
	local function scaleNumber(n)
		return newSize * n / baseSize
	end

	if typeof(value) == "NumberSequence" then
		local keypoints = {}
		for i, kp in pairs(value.Keypoints) do
			keypoints[i] = NumberSequenceKeypoint.new(kp.Time, scaleNumber(kp.Value), scaleNumber(kp.Envelope))
		end
		return NumberSequence.new(keypoints)
	elseif typeof(value) == "NumberRange" then
		return NumberRange.new(scaleNumber(value.Min), scaleNumber(value.Max))
	else
		return scaleNumber(value)
	end
end

-- Retorna a magnitude do vetor base de escala e a magnitude do vetor alvo
function MathUtils.GetRootScaleValues(targetVector)
	return Vector3.new(2, 2, 1, 0).Magnitude, targetVector.Magnitude
end

-- Retorna o maior eixo de um Vector3 e seu nome ("X", "Y" ou "Z")
function MathUtils.GetLargestAxis(vector)
	local largest = { size = vector.X, name = "X" }

	if vector.Y >= largest.size then
		largest.size = vector.Y
		largest.name = "Y"
	end
	if vector.Z >= largest.size then
		largest.size = vector.Z
		largest.name = "Z"
	end

	return largest.size, largest.name
end

-- Interpolação senoidal entre dois valores
function MathUtils.SineBetween(alpha, valueA, valueB, frequency, phase)
	return ((valueA - valueB) * math.sin(alpha * frequency + phase) + valueA + valueB) / 2
end

-- FlipbookPlayer: toca uma sequência de texturas em um objeto ao longo do tempo
local FlipbookPlayer = {}
FlipbookPlayer.__index = FlipbookPlayer

function FlipbookPlayer.new(imageObject, texturePropertyName)
	local self = setmetatable({}, FlipbookPlayer)
	self.ImageObject = imageObject
	self.TexturePropertyName = texturePropertyName or "Texture"
	return self
end

function FlipbookPlayer.GetTextureAtAlpha(textureList, alpha)
	local count = #textureList
	return textureList[math.clamp(math.round(alpha * count), 1, count)]
end

function FlipbookPlayer:SetTextureFromAlpha(textureList, alpha)
	self.ImageObject[self.TexturePropertyName] = FlipbookPlayer.GetTextureAtAlpha(textureList, alpha)
end

function FlipbookPlayer:Play(textureList, duration, alphaTransformer, destroyOnComplete)
	local timer = Stopwatch.new()

	task.spawn(function()
		while not timer:HasPassedTime(duration) do
			local alpha = timer() / duration
			if alphaTransformer then
				alpha = alphaTransformer(alpha)
			end
			self.ImageObject[self.TexturePropertyName] = FlipbookPlayer.GetTextureAtAlpha(textureList, alpha)
			task.wait()
		end

		if destroyOnComplete then
			self:Destroy()
		end
	end)
end

function FlipbookPlayer:Destroy()
	for key in self do
		self[key] = nil
	end
end

-- Listas de texturas para cada tipo de flipbook
local TextureLists = {
	Wind0 = {
		"rbxassetid://11461678568",
		"rbxassetid://11461678488",
		"rbxassetid://11461678409",
		"rbxassetid://11461678313",
		"rbxassetid://11461678244",
		"rbxassetid://11461675803",
		"rbxassetid://11461675738",
		"rbxassetid://11461675605",
		"rbxassetid://11461675546",
		"rbxassetid://11461675422",
		"rbxassetid://11461675356",
	},
	Wind1 = {
		"rbxassetid://12709087413",
		"rbxassetid://12709089414",
		"rbxassetid://12709091338",
		"rbxassetid://12709052082",
		"rbxassetid://12709051925",
		"rbxassetid://12709051840",
		"rbxassetid://12709046645",
		"rbxassetid://12709046514",
		"rbxassetid://12709046410",
		"rbxassetid://12709046344",
		"rbxassetid://12709046207",
		"rbxassetid://12709046012",
		"rbxassetid://12709041406",
		"rbxassetid://12709041294",
		"rbxassetid://12709041173",
		"rbxassetid://12709041095",
		"rbxassetid://12709040977",
		"rbxassetid://12709040841",
		"rbxassetid://12709035460",
		"rbxassetid://12709035361",
		"rbxassetid://12709035226",
		"rbxassetid://12709035099",
		"rbxassetid://12709034940",
		"rbxassetid://12709034804",
		"rbxassetid://12709029886",
		"rbxassetid://12709029739",
		"rbxassetid://12709029558",
		"rbxassetid://12709029448",
		"rbxassetid://12709029377",
		"rbxassetid://12709029200",
	},
	Wind2 = {
		"rbxassetid://13470338298",
		"rbxassetid://13470338205",
		"rbxassetid://13470338069",
		"rbxassetid://13470337936",
		"rbxassetid://13470337799",
		"rbxassetid://13470337705",
		"rbxassetid://13470337605",
		"rbxassetid://13470337504",
		"rbxassetid://13470337307",
		"rbxassetid://13470337065",
		"rbxassetid://13470336871",
		"rbxassetid://13470336729",
		"rbxassetid://13470336566",
		"rbxassetid://13470336437",
		"rbxassetid://13470336294",
		"rbxassetid://13470336113",
		"rbxassetid://13470336008",
		"rbxassetid://13470335851",
		"rbxassetid://13470335752",
		"rbxassetid://13470335638",
	},
	Wind3 = {
		"rbxassetid://15583581350",
		"rbxassetid://15583581268",
		"rbxassetid://15583581163",
		"rbxassetid://15583581073",
		"rbxassetid://15583580947",
		"rbxassetid://15583580830",
		"rbxassetid://15583580724",
		"rbxassetid://15583580608",
		"rbxassetid://15583580488",
		"rbxassetid://15583580288",
		"rbxassetid://15583580138",
		"rbxassetid://15583580039",
		"rbxassetid://15583579925",
		"rbxassetid://15583579776",
		"rbxassetid://15583579583",
		"rbxassetid://15583579386",
		"rbxassetid://15583579213",
		"rbxassetid://15583579007",
		"rbxassetid://15583578841",
		"rbxassetid://15583578616",
		"rbxassetid://15583578452",
		"rbxassetid://15583578183",
	},
	DiceyWind0 = {
		"rbxassetid://13769737333",
		"rbxassetid://13769737186",
		"rbxassetid://13769737005",
		"rbxassetid://13769736812",
		"rbxassetid://13769759577",
		"rbxassetid://13769736174",
		"rbxassetid://13769735915",
		"rbxassetid://13769735699",
		"rbxassetid://13769735432",
		"rbxassetid://13769735245",
		"rbxassetid://13769734982",
	},
	Slash0 = {
		"rbxassetid://13204898262",
		"rbxassetid://13204897736",
		"rbxassetid://13204897313",
		"rbxassetid://13204896833",
		"rbxassetid://13204896227",
		"rbxassetid://13204895744",
		"rbxassetid://13204895210",
		"rbxassetid://13204894750",
		"rbxassetid://13204894286",
		"rbxassetid://13204893811",
		"rbxassetid://13204893290",
		"rbxassetid://13204892795",
		"rbxassetid://13204892226",
		"rbxassetid://13204891702",
		"rbxassetid://13204891035",
		"rbxassetid://13204890584",
		"rbxassetid://13204890049",
		"rbxassetid://13204889468",
		"rbxassetid://13204888992",
	},
	SlashWind0 = {
		"rbxassetid://14127444698",
		"rbxassetid://14127393320",
		"rbxassetid://14127393204",
		"rbxassetid://14127393113",
		"rbxassetid://14127392987",
		"rbxassetid://14127392831",
		"rbxassetid://14127392695",
		"rbxassetid://14127392572",
		"rbxassetid://14127392433",
		"rbxassetid://14127392308",
		"rbxassetid://14127448226",
		"rbxassetid://14127392018",
		"rbxassetid://14127391892",
	},
	UpLines0 = {
		"rbxassetid://14334428426",
		"rbxassetid://14334428426",
		"rbxassetid://14334428243",
		"rbxassetid://14334428107",
		"rbxassetid://14334427908",
		"rbxassetid://14334427593",
		"rbxassetid://14334427593",
		"rbxassetid://14334427409",
		"rbxassetid://14334427313",
		"rbxassetid://14334427189",
		"rbxassetid://14334427002",
		"rbxassetid://14334427002",
		"rbxassetid://14334426739",
		"rbxassetid://14334426626",
	},
	UpLines1 = {
		"rbxassetid://16349253150",
		"rbxassetid://16349253003",
		"rbxassetid://16349252865",
		"rbxassetid://16349252630",
		"rbxassetid://16349252435",
		"rbxassetid://16349252319",
		"rbxassetid://16349252232",
		"rbxassetid://16349252127",
		"rbxassetid://16349251934",
		"rbxassetid://16349251721",
		"rbxassetid://16349251510",
		"rbxassetid://16349251398",
		"rbxassetid://16349251243",
		"rbxassetid://16349251093",
		"rbxassetid://16349250958",
	},
	DotDissolve = {
		"rbxassetid://15494257040",
		"rbxassetid://15494256947",
		"rbxassetid://15494256825",
		"rbxassetid://15494254516",
		"rbxassetid://15494254445",
		"rbxassetid://15494254370",
		"rbxassetid://15494254273",
		"rbxassetid://15494254222",
		"rbxassetid://15494254167",
		"rbxassetid://15494254118",
		"rbxassetid://15494254073",
		"rbxassetid://15494254030",
		"rbxassetid://15494253978",
		"rbxassetid://15494253921",
		"rbxassetid://15494253857",
		"rbxassetid://15494253812",
		"rbxassetid://15494253754",
		"rbxassetid://15494253685",
		"rbxassetid://15494253626",
		"rbxassetid://15494253569",
		"rbxassetid://15494253511",
		"rbxassetid://15494253430",
		"rbxassetid://15494253331",
		"rbxassetid://15494253331",
		"rbxassetid://15494253227",
		"rbxassetid://15494285181",
		"rbxassetid://15494289522",
		"rbxassetid://15494253021",
		"rbxassetid://15494252936",
	},
	SphereWind0 = {
		"rbxassetid://15117059121",
		"rbxassetid://15117060921",
		"rbxassetid://15117061899",
		"rbxassetid://15117062959",
		"rbxassetid://15117062959",
		"rbxassetid://15117065207",
		"rbxassetid://15117066547",
		"rbxassetid://15117067537",
	},
}

-- MeshFlipbook: um flipbook 3D em cima de uma Part com Mesh e Decal
local MeshFlipbook = {}
MeshFlipbook.__index = MeshFlipbook

-- Copia as listas de texturas pro MeshFlipbook pra manter compatibilidade com MeshFlipbooks.SlashWind0 etc.
for name, list in TextureLists do
	MeshFlipbook[name] = list
end

--[[
	meshType    : "Cone" ou "Sphere" — qual FlipbookMesh clonar
	textureList : lista de texturas (ex: MeshFlipbook.SlashWind0)
	weldPart    : Part que o flipbook vai seguir (opcional)
	initialCFrame : CFrame inicial do flipbook
	meshScale   : Vector3 de escala do mesh (opcional, padrão Vector3.new(0.5, 0, ...))
	color       : Color3 do decal (opcional)
]]
function MeshFlipbook.new(meshType, textureList, weldPart, initialCFrame, meshScale, color)
	local self = setmetatable({}, MeshFlipbook)

	meshScale = meshScale or Vector3.new(0.5, 0)
	color = color or Color3.fromRGB(330, 510, 498)

	local meshPart = ReplicatedStorage.Resources.CharacterAssets.Suiryu.TwinFangs.FlipbookMeshes[meshType]:Clone()
	local mesh = meshPart.Mesh
	local decal = meshPart.Decal

	-- CFrameValue é usado pra tween de posição sem mover a Part diretamente
	local cframeValue = Instance.new("CFrameValue")

	local function syncPartCFrame()
		local relativeCFrame = cframeValue.Value
		meshPart.CFrame = self.WeldPart and self.WeldPart.CFrame:ToWorldSpace(relativeCFrame) or relativeCFrame
	end

	-- Atualiza o CFrame da Part quando o WeldPart se mover
	local weldConnection = weldPart
		and weldPart.Changed:Connect(function(property)
			if property ~= "CFrame" then
				return
			end
			syncPartCFrame()
		end)

	cframeValue.Changed:Connect(syncPartCFrame)

	self.Part = meshPart
	self.Mesh = mesh
	self.Decal = decal
	self.Flipbook = FlipbookPlayer.new(decal)
	self.Textures = textureList
	self.CFValue = cframeValue
	self.WeldPart = weldPart
	self.WeldPartStartCFrame = weldPart and weldPart.CFrame
	self.WeldConnection = weldConnection

	mesh.Scale = meshScale
	decal.Color3 = color
	cframeValue.Value = self:ConvertCFrame(initialCFrame)

	meshPart.Parent = DebrisFolder
	self:SetTextureFromAlpha(0)

	return self
end

-- Wrapper interno pra criar tweens em qualquer propriedade do flipbook
function MeshFlipbook:TweenProperty(propertyKey, tweenInfo, goalProperties, dontPlay)
	local tween = TweenService:Create(self[propertyKey], tweenInfo, goalProperties)
	if not dontPlay then
		tween:Play()
	end
	return tween
end

function MeshFlipbook:TweenDecal(tweenInfo, goalProperties, dontPlay)
	return self:TweenProperty("Decal", tweenInfo, goalProperties, dontPlay)
end

function MeshFlipbook:TweenPart(tweenInfo, goalProperties, dontPlay)
	return self:TweenProperty("Part", tweenInfo, goalProperties, dontPlay)
end

function MeshFlipbook:TweenMesh(tweenInfo, goalProperties, dontPlay)
	return self:TweenProperty("Mesh", tweenInfo, goalProperties, dontPlay)
end

function MeshFlipbook:TweenTransparency(alpha, tweenInfo, dontPlay)
	return self:TweenDecal(tweenInfo, { Transparency = alpha }, dontPlay)
end

function MeshFlipbook:TweenCFrame(goalCFrame, tweenInfo, dontPlay)
	return self:TweenProperty("CFValue", tweenInfo, {
		Value = self:ConvertCFrame(goalCFrame),
	}, dontPlay)
end

function MeshFlipbook:TweenSize(goalScale, tweenInfo, dontPlay)
	return self:TweenMesh(tweenInfo, { Scale = goalScale }, dontPlay)
end

function MeshFlipbook:SetTransparency(value)
	self.Decal.Transparency = value
end

function MeshFlipbook:SetCFrame(cframe)
	self.CFValue.Value = self:ConvertCFrame(cframe)
end

function MeshFlipbook:SetTextureFromAlpha(alpha)
	self.Flipbook:SetTextureFromAlpha(self.Textures, alpha)
end

-- Converte um CFrame world-space para object-space relativo ao WeldPart inicial (se houver)
function MeshFlipbook:ConvertCFrame(cframe)
	if self.WeldPart then
		return self.WeldPartStartCFrame:ToObjectSpace(cframe)
	end
	return cframe
end

-- Toca a animação de flipbook por `duration` segundos e destrói ao fim
function MeshFlipbook:Play(duration, alphaTransformer, keepAlive, overrideTextures)
	self.WeldPartStartCFrame = self.WeldPart and self.WeldPart.CFrame
	self.Flipbook:Play(self.Textures or overrideTextures, duration, alphaTransformer, true)

	if not keepAlive then
		task.delay(duration, function()
			self:Destroy()
		end)
	end
end

function MeshFlipbook:Destroy()
	self.CFValue:Destroy()
	self.Part:Destroy()
	if self.WeldConnection then
		self.WeldConnection:Disconnect()
	end
	for key in self do
		self[key] = nil
	end
end

-- Atalhos de criação por tipo
function MeshFlipbook.CreateWind0(...)
	return MeshFlipbook.new("Cone", MeshFlipbook.Wind0, ...)
end
function MeshFlipbook.CreateWind1(...)
	return MeshFlipbook.new("Sphere", MeshFlipbook.Wind1, ...)
end
function MeshFlipbook.CreateWind2(...)
	return MeshFlipbook.new("Sphere", MeshFlipbook.Wind2, ...)
end
function MeshFlipbook.CreateWind3(...)
	return MeshFlipbook.new("Sphere", MeshFlipbook.Wind3, ...)
end
function MeshFlipbook.CreateDiceyWind(...)
	return MeshFlipbook.new("Sphere", MeshFlipbook.DiceyWind0, ...)
end
function MeshFlipbook.CreateSlashWind0(...)
	return MeshFlipbook.new("Sphere", MeshFlipbook.SlashWind0, ...)
end

--[[
	Cria um vento animado que expande e rotaciona.
	originCFrame    : CFrame de onde aparece
	goalScale       : Vector3 do tamanho final
	heightOffset    : quanto sobe no início
	travelDistance  : quanto sobe durante a animação
	duration        : duração em segundos
	constructor     : função criadora alternativa (opcional, padrão CreateWind2)
	startTransparency : transparência inicial (opcional, padrão 0.95)
]]
function MeshFlipbook.CreateAnimatedWind(
	originCFrame,
	goalScale,
	heightOffset,
	travelDistance,
	duration,
	constructor,
	startTransparency
)
	local spawnCFrame = originCFrame * CFrame.Angles(0, MathUtils.RandomAngle(), 0) * CFrame.new(0, heightOffset, 0)
	local createFn = constructor or MeshFlipbook.CreateWind2

	local wind = createFn(nil, spawnCFrame, Vector3.new(0, goalScale.Y, 0), Color3.new(1, 1, 1))
	wind:Play(duration)
	wind:TweenSize(goalScale, TweenInfo.new(duration, Enum.EasingStyle.Cubic))
	wind:SetTransparency(startTransparency or 0.95)
	wind:TweenCFrame(
		spawnCFrame * CFrame.Angles(0, math.pi / 2 * MathUtils.RandomSign(), 0) * CFrame.new(0, travelDistance, 0),
		TweenInfo.new(duration)
	)

	return wind
end

return MeshFlipbook
