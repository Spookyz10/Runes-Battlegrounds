local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local module = {}
local Utility = require(ReplicatedStorage.Utility)
local Parent = require(script.Parent)
local PlayerGui = Utility.Idk.PlayerGui
local ClockTime = Utility.Services.Lighting.ClockTime

local purple = ReplicatedStorage.Resources.SeasBgGojo.Purple

local function Typewrite(label, text, speed)
	for i = 1, string.len(text) do
		label.Text ..= string.sub(text, i, i)
		task.wait(speed)
	end
end

local function ScaleParticle(emitter, stored, scale)
	local sizeKps = {}
	local transKps = {}
	for i, v in stored.Keypoints do
		sizeKps[i] = NumberSequenceKeypoint.new(v.Time, v.Value * scale, v.Envelope * scale)
	end
	for i, v in stored.TransparencyKeypoints do
		transKps[i] = NumberSequenceKeypoint.new(v.Time, v.Value * scale, v.Envelope * scale)
	end
	emitter.Size = NumberSequence.new(sizeKps)
	emitter.Speed = NumberRange.new(stored.Speed.Min * scale, stored.Speed.Max * scale)
	emitter.Acceleration = stored.Acceleration * scale
end

local function StoreParticle(emitter)
	local data = { Keypoints = {}, TransparencyKeypoints = {} }
	for i, v in emitter.Size.Keypoints do data.Keypoints[i] = v end
	for i, v in emitter.Transparency.Keypoints do data.TransparencyKeypoints[i] = v end
	data.Speed = emitter.Speed
	data.Acceleration = emitter.Acceleration
	return data
end

function module.PurpleNuke(arg1)
	local RootPart = arg1:FindFirstChildOfClass("Humanoid").RootPart
	local TroveNew = Utility.Modules.Trove.new()
	TroveNew:AttachToInstance(arg1)

	-- [[ Dialog ]]:
	local function CreateDialog(Gui, Text)
		local Frame = Gui.Frame
		local TextLabel = Frame.TextLabel
		TextLabel.Text = ""
		TextLabel.Position = UDim2.fromScale(0.224, 0.78)
		Frame.Position = UDim2.fromScale(0, 0.643)
		Frame.BackgroundTransparency = 1
		TweenService:Create(Frame, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
			Position = UDim2.fromScale(0, 0.537),
		}):Play()

		local Function = {
			Text = {
				MoveTextIn = function()
					if TextLabel.TextTransparency == 0 then return end
					TweenService:Create(TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						TextTransparency = 0,
						Position = UDim2.fromScale(0.224, 0.732),
					}):Play()
					TweenService:Create(TextLabel.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						Transparency = 0.4,
					}):Play()
					task.wait(0.2)
				end,
				MoveTextOut = function()
					if TextLabel.TextTransparency ~= 0 then return end
					TweenService:Create(TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						TextTransparency = 1,
						Position = UDim2.fromScale(0.224, 1),
					}):Play()
					TweenService:Create(TextLabel.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						Transparency = 1,
					}):Play()
					task.wait(0.2)
					TextLabel.Text = ""
				end,
			},
			Frame = {
				MoveFrameOut = function()
					TweenService:Create(Frame, TweenInfo.new(0.65, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 0.643),
					}):Play()
				end,
				MoveFrameIn = function()
					if Frame.BackgroundTransparency ~= 1 then return end
					TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0,
						Position = UDim2.fromScale(0, 0.537),
					}):Play()
				end,
			},
		}

		for _, v in Text do
			Function.Text.MoveTextIn()
			Function.Frame.MoveFrameIn()
			local text, duration, speed, moveOut, extraWait = unpack(v)
			task.spawn(Typewrite, TextLabel, text, speed)
			if moveOut then
				task.wait(duration - 0.4)
			else
				task.wait(duration)
			end
			if moveOut then Function.Text.MoveTextOut() end
			if extraWait then task.wait(extraWait) end
		end
		Gui:Destroy()
	end

	if Utility.Idk.Players.Character == arg1 then
		Parent.Cutscene(purple.CameraAnimation, purple.CameraModel, RootPart, nil, purple.FOV, false)

		local SFX = Utility.Modules.soundPlaying:play(purple.Sound, Utility.Services.Sound)
		SFX:Play()

		task.spawn(function()
			local Dialog = purple.Dialogue:Clone()
			Dialog.Parent = PlayerGui
			TroveNew:Add(Dialog)

			local Text = {
				[1] = { "Nine Points, ", 1.2, 0.03 },
				[2] = { "Polarized Light.", 1.6, 0.03, true },
				[3] = { "Crow and Shomyo.", 2.35, 0.03, true },
				[4] = { "Between front and back.", 2.7, 0.03, true, 1.5 },
				[5] = { "HOLLOW...", 1.1, 0.04, true },
				[6] = { "PURPLE!", 1.65, 0.05 },
			}
			CreateDialog(Dialog, Text)
		end)
	else
		Utility.Modules.soundPlaying:play(purple.Sound, RootPart):Play()
	end

	-- [[ SpawnBalls ]]:
	local function SpawnBalls(Color, Controller)
		local closeEnough = Utility.Services.Players.LocalPlayer:DistanceFromCharacter(RootPart.Position) < 125

		if Color == "Blue" then
			local Blue = purple.Blue:Clone()
			Blue.Parent = workspace
			Controller.blue.Part1 = Blue
			TroveNew:Add(Blue)

			if closeEnough then
				local Cast = purple.BlueCast:Clone()
				Cast.CFrame = Blue.CFrame
				Cast.Parent = workspace
				Parent.EmitOnly(Cast)
				TroveNew:Add(Cast)
			end
			return Blue

		elseif Color == "Red" then
			local Red = purple.Red:Clone()
			Red.Parent = workspace
			Controller.red.Part1 = Red
			TroveNew:Add(Red)

			if closeEnough then
				local Cast = purple.RedCast:Clone()
				Cast.CFrame = Red.CFrame
				Cast.Parent = workspace
				Parent.EmitOnly(Cast)
				TroveNew:Add(Cast)
			end
			return Red
		end
	end

	-- [[ SpeedLines ]]:
	local function SpeedLines(Controller)
		local SpeedLine = purple.Speedlines:Clone()
		SpeedLine.CFrame = Controller.CFrame * CFrame.new(0, -3, 0)
		SpeedLine.Parent = workspace
		TroveNew:Add(SpeedLine)

		local conn = RunService.PostSimulation:Connect(function()
			SpeedLine.Position = arg1.Torso.Position - Vector3.yAxis * 3
		end)

		task.delay(1.6, function()
			conn:Disconnect()
			for _, v in SpeedLine:GetDescendants() do
				if v:IsA("ParticleEmitter") then v.Enabled = false end
			end
		end)
	end

	-- [[ Charging ]]:
	local function Charging()
		local eyeglow = purple.EyeGlow:Clone()
		eyeglow.Parent = workspace
		eyeglow.Weld.Part0 = arg1.Head
		TroveNew:Add(eyeglow)
		Parent.EmitOnly(eyeglow.Emit)

		local FX = purple.Charging.FX:Clone()
		FX.Parent = arg1.Torso
		TroveNew:Add(FX)
		Parent.EmitOnly(FX)

		return eyeglow, FX
	end

	-- [[ Time / Lighting ]]:
	local function Time()
		local Info = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
		Lighting.ClockTime = 0.75

		local PointLight = Instance.new("PointLight")
		PointLight.Brightness = 0
		PointLight.Range = 15
		PointLight.Parent = arg1
		TweenService:Create(PointLight, Info, { Brightness = 7 }):Play()

		local existingCC = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
		if existingCC then existingCC.Enabled = false end

		local ColorCorrec = Instance.new("ColorCorrectionEffect")
		ColorCorrec.Parent = workspace.CurrentCamera
		TweenService:Create(ColorCorrec, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Brightness = -0.15,
			Contrast = 1.3,
		}):Play()

		task.delay(1.6, function()
			TweenService:Create(PointLight, Info, { Brightness = 0 }):Play()
			TweenService:Create(ColorCorrec, Info, { Brightness = 0, Contrast = 0 }):Play()
			if existingCC then existingCC.Enabled = true end
			Lighting.ClockTime = ClockTime
			task.wait(0.25)
			ColorCorrec:Destroy()
			PointLight:Destroy()
		end)
	end

	-- [[ Purple explosion ]]:
	local function DoPurple(Controller, Blue, Red)
		local function ClearPart(part)
			for _, v in part do
				if v:IsA("ParticleEmitter") then
					v:Destroy()
				elseif v:IsA("PointLight") then
					TweenService:Create(v, TweenInfo.new(0.2), { Brightness = 0 }):Play()
				end
			end
		end
		ClearPart(Blue:GetDescendants())
		ClearPart(Red:GetDescendants())

		TweenService:Create(Blue, TweenInfo.new(0.2), { Transparency = 1, Size = Vector3.zero }):Play()
		TweenService:Create(Red, TweenInfo.new(0.2), { Transparency = 1, Size = Vector3.zero }):Play()

		local Cast = purple.PurpleCast:Clone()
		Cast.CFrame = Controller.CFrame
		Cast.Parent = workspace
		Parent.EmitOnly(Cast)
		TroveNew:Add(Cast)

		local Bubble = purple.Bubble:Clone()
		Bubble.Size = Vector3.one * 10
		Bubble.Transparency = 1
		Bubble.CFrame = Controller.CFrame
		Bubble.Parent = workspace
		TweenService:Create(Bubble, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), { Transparency = 2 }):Play()
		TweenService:Create(Bubble, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), { Size = Vector3.one }):Play()
		task.delay(0.1, function()
			TweenService:Create(Bubble, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
			task.wait(0.1)
			Bubble:Destroy()
		end)

		local PurplePart = purple.Purple:Clone()
		PurplePart.CFrame = Controller.CFrame
		PurplePart.Parent = workspace
		TroveNew:Add(PurplePart)

		TweenService:Create(PurplePart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = PurplePart.Size * 2.8,
		}):Play()

		-- Store + scale particles over 1s
		local storedParticles = {}
		for _, v in PurplePart:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				storedParticles[v] = StoreParticle(v)
			end
		end

		local elapsed = 0
		local conn
		local startTime = os.clock()
		conn = RunService.Heartbeat:Connect(function()
			elapsed = math.min((os.clock() - startTime) / 1, 1)
			local t = TweenService:GetValue(elapsed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			for emitter, stored in storedParticles do
				ScaleParticle(emitter, stored, 2.8 * t)
			end
			if elapsed >= 1 then conn:Disconnect() end
		end)

		task.wait(1)
		local Eyeglow, ChargingVFX = Charging()
		if Utility.Idk.Players.Character == arg1 then Time() end

		task.wait(0.7)
		TweenService:Create(ChargingVFX.PointLight, TweenInfo.new(0.2), { Brightness = 0 }):Play()
		for _, v in ChargingVFX:GetDescendants() do
			if v:IsA("ParticleEmitter") then v.Enabled = false end
		end

		task.wait(0.5)
		for _, v in Eyeglow:GetDescendants() do
			if v:IsA("ParticleEmitter") then v.Enabled = false end
		end

		TweenService:Create(PurplePart, TweenInfo.new(0.2), { Transparency = 1 }):Play()

		local Explode = purple.PurpleExplode:Clone()
		Explode.CFrame = PurplePart.CFrame
		Explode.Parent = workspace

		local Area = purple.Area:Clone()
		Area.CFrame = PurplePart.CFrame
		Area.Parent = workspace
		for _, v in Area:GetDescendants() do
			if v:IsA("ParticleEmitter") then v.Enabled = true end
		end
		task.delay(0.8, function()
			for _, v in Area:GetDescendants() do
				if v:IsA("ParticleEmitter") then v.Enabled = false end
			end
		end)

		TweenService:Create(Explode.PointLight, TweenInfo.new(0.5), { Brightness = 0 }):Play()
		Parent.EmitOnly(Explode)

		if Utility.Services.Players.LocalPlayer:DistanceFromCharacter(RootPart.Position) < 70 then
			task.delay(0.15, function()
				Parent.newCameraShake({{ 3, 20, 0, 3 }, Vector3.yAxis * 20 + Vector3.xAxis * 20 })
				local Flash = purple.Flashbang:Clone()
				Flash.Parent = PlayerGui
				TweenService:Create(Flash.Frame, TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 1,
				}):Play()
				local ImpactFrames = {
					FPS = 0.05,
					Frames = { 16745636008, 16745636207, 16745636444, 16745636628, 16745636853, 16745637091, 16745637267, 16745637590, 16745637851, 16745638039 },
				}
				if Utility.Idk.Players.Character == arg1 then
					Parent.Frames(ImpactFrames, Flash.Frame)
				end
				task.wait(1.25)
				Flash:Destroy()
			end)
		end

		game:GetService("Debris"):AddItem(Explode, 4)
		game:GetService("Debris"):AddItem(Area, 6)
		TroveNew:Destroy()

		task.wait(3)
		local Raycast = Utility.Modules.RayCast(RootPart.Position, Vector3.new(0, -1e19, 0))
		local Land = purple.Land:Clone()
		Land.Position = Raycast.Position
		Land.Parent = workspace
		for _, v in Land.EmitIt:GetChildren() do
			if v.Name == "Dust" then
				v.Color = ColorSequence.new(Raycast.Instance.Color)
			end
		end
		Parent.EmitOnly(Land)
	end

	-- [[ Rotate ]]:
	local function Rotate(Controller, Blue, Red)
		task.wait(0.7)

		local PreviousAngle = Instance.new("NumberValue")
		PreviousAngle.Value = 0
		local UpValue = Instance.new("NumberValue")
		UpValue.Value = 0
		local Connection
		local Tick = tick()

		local AngleTween = TweenService:Create(PreviousAngle, TweenInfo.new(2.5), { Value = 800 })
		local UpTween = TweenService:Create(UpValue, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Value = 53.5 })
		AngleTween:Play()
		UpTween:Play()

		Connection = RunService.RenderStepped:Connect(function(dt)
			if tick() - Tick < 2.5 then
				local verticalMovement = UpValue.Value * dt
				Controller.CFrame = Controller.CFrame + Vector3.new(0, verticalMovement, 0)
			end
			if PreviousAngle.Value > 0 then
				Controller.CFrame = Controller.CFrame * CFrame.Angles(0, math.rad(PreviousAngle.Value * dt), 0)
			else
				Connection:Disconnect()
			end
		end)
		TroveNew:Add(Connection)

		TroveNew:Add(task.delay(2.6, function()
			TweenService:Create(PreviousAngle, TweenInfo.new(0.8), { Value = 0 }):Play()
			task.wait(0.7)
			Connection:Disconnect()

			if not arg1 or not Controller:FindFirstChild("blue") then return end

			TweenService:Create(Controller.blue, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(-11, 0, 0) }):Play()
			TweenService:Create(Controller.red, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(11, 0, 0) }):Play()
			task.wait(0.35)

			TweenService:Create(Controller.blue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = CFrame.new(0, 0, 0) }):Play()
			TweenService:Create(Controller.red, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = CFrame.new(0, 0, 0) }):Play()
			task.wait(0.2)

			DoPurple(Controller, Blue, Red)
		end))
	end

	-- [[ Main ]]:
	local Controller = purple.Controller:Clone()
	Controller.CFrame = RootPart.CFrame * CFrame.new(0, -0.8, 2)
	Controller.Parent = workspace
	Controller.Anchored = true
	Controller.CanCollide = false
	TroveNew:Add(Controller)

	-- Follow character until Rotate takes over
	local followConn = RunService.RenderStepped:Connect(function()
		if not RootPart.Parent then return end
		Controller.CFrame = RootPart.CFrame * CFrame.new(0, -0.8, 2)
	end)
	TroveNew:Add(followConn)

	task.wait(1)
	local Blue = SpawnBalls("Blue", Controller)
	task.spawn(function()
		task.wait()
		TweenService:Create(Controller.blue, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(-5.5, 0, 0) }):Play()
	end)

	task.wait(1)
	local Red = SpawnBalls("Red", Controller)
	task.spawn(function()
		task.wait()
		TweenService:Create(Controller.red, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(5.5, 0, 0) }):Play()
	end)

	task.wait(4)
	followConn:Disconnect()
	SpeedLines(Controller)
	Rotate(Controller, Blue, Red)
end

return module