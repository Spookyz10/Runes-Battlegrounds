local TS = game:GetService('TweenService')
local RNS = game["Run Service"]

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player:GetPropertyChangedSignal('Character'):Connect(function()
	Character = Player.Character
end)

local CameraTableAnims = require(script.Parent.CameraTableAnims)
local Camera = workspace.CurrentCamera
local CamAnims = script.Animations
local RS = game:GetService("ReplicatedStorage")

local rad = math.rad
workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
	Camera = workspace.CurrentCamera
end)


local getCframe = {
	["Instance"] = function(point)
		return point.CFrame
	end,

	["CFrame"] = function(point)
		return point
	end,
}


local camRigs = {
	[1] = RS.Assets.CameraRigs.CameraRig,
	[2] = RS.Assets.CameraRigs.CameraRig2,
	[3] = RS.Assets.CameraRigs.CameraRig3,
}

local AnimTracks = {
	[1] = {},
	[2] = {},
	[3] = {}
}


local module = {}
module.__index = module


local function CameraSmoothOut()
	local CamCF = Camera.CFrame
	local startClock = os.clock()
	local bindName = 'CutsceneCameraSmoothOut'..startClock..Player.UserId

	local easeStyle = Enum.EasingStyle.Exponential
	local easeDirection = Enum.EasingDirection.Out

	RNS:BindToRenderStep(bindName, Enum.RenderPriority.Camera.Value + 1, function()
		Camera.CFrame = CamCF:Lerp(Camera.CFrame, TS:GetValue((os.clock() - startClock) / .6, easeStyle, easeDirection))
	end)

	TS:Create(Camera, TweenInfo.new(.6, easeStyle, easeDirection), { FieldOfView = 70; }):Play()

	task.delay(.6, function()
		RNS:UnbindFromRenderStep(bindName)
	end)
end

local function finalCameraPart(isNMG, MainPart, doSmoothOut)
	module:StopAnims()
	CameraTableAnims:StopAnimations()


	if isNMG == true then
		local CF = MainPart
		if typeof(MainPart) ~= "CFrame" then
			CF = MainPart.CFrame
		end

		Camera.CFrame = CFrame.new((CF * CFrame.new(0, 24, -100)).Position, CF.Position)
	end

	Camera.CameraType = Enum.CameraType.Custom


	shared.triggerTopbar(true)
	shared.triggerAwkbar(true)
	shared.triggerHotbar(true)

	if doSmoothOut ~= false then
		CameraSmoothOut()
	end
end


function module:PlayCameraAnimation(AnimationName: string, MainPart: Part, smoothInTime: number, doSmoothOut: boolean, changeToScriptable: boolean): (AnimationTrack, Model)
	if not Character or (Character and Character:FindFirstChild('CameraRig')) then return end


	local Animation = CamAnims:FindFirstChild(AnimationName)
	if Animation then
		local Offset = Animation:GetAttribute("Offset") or CFrame.new(0, 0, 0)


		shared.triggerTopbar(false)
		shared.triggerAwkbar(false)
		shared.triggerHotbar(false)


		local currentRig, currentAnimsTable
		local customRigNumber = Animation:GetAttribute("CustomRig")
		if not customRigNumber then
			currentRig = camRigs[1]
			currentAnimsTable = AnimTracks[1]
		else
			currentRig = camRigs[customRigNumber]
			currentAnimsTable = AnimTracks[customRigNumber]
		end


		if typeof(MainPart) == 'CFrame' then
			currentRig.RootPart.Anchored = true

			currentRig:PivotTo(MainPart * Offset)

		else
			currentRig.RootPart.Anchored = false


			if currentRig.RootPart.Weld.ClassName == "WeldConstraint" then
				currentRig.RootPart:PivotTo(MainPart.CFrame * Offset)
				currentRig.RootPart.Weld.Part0 = MainPart

			else
				currentRig.RootPart.Weld.Part0 = MainPart
				currentRig.RootPart.Weld.C0 = Offset

			end

		end

		currentRig.Parent = workspace.Thrown

		if changeToScriptable ~= false then
			Camera.CameraType = Enum.CameraType.Scriptable
		end


		smoothInTime = smoothInTime or .5
		local AnimTrack: AnimationTrack = currentAnimsTable[Animation]
		local startTick = tick()
		AnimTrack:Play()

		local AnimC: RBXScriptConnection
		AnimC = RNS.RenderStepped:Connect(function(deltaTime)
			if AnimTrack.IsPlaying == true and Character.Parent then
				if not Camera:GetAttribute("Paused") and Camera.CameraType == Enum.CameraType.Scriptable then
					if tick() - startTick < smoothInTime then
						Camera.CFrame = Camera.CFrame:Lerp(currentRig.Cam.CFrame, (1 - smoothInTime)/2)
					else
						Camera.CFrame = Camera.CFrame:Lerp(currentRig.Cam.CFrame, 0.9)
					end
				end
			else
				AnimC:Disconnect()

				currentRig.RootPart.Weld.Part0 = nil
				currentRig.RootPart.CFrame = CFrame.new(0,0,0) * CFrame.Angles(0,0,0)
				if AnimationName ~= 'NMG' then
					Camera.CameraType = Enum.CameraType.Custom
				end
				currentRig.Parent = script
			end
		end)

		if AnimationName == 'NMG' then
			task.delay(15.583, function()
				finalCameraPart(true, MainPart, doSmoothOut)
			end)
		else
			AnimTrack.Stopped:Once(function()
				finalCameraPart(false, nil, doSmoothOut)
			end)
		end

		return AnimTrack, currentRig
	end
end

function module:StopAnims()
	for _,v in AnimTracks do
		for _,vv in v do
			vv:Stop()
		end
	end

	for _, CameraRig in camRigs do
		CameraRig.RootPart.Weld.Part0 = nil
		CameraRig:PivotTo(CFrame.new(0,0,0) * CFrame.Angles(0,0,0))
		CameraRig.Parent = script
	end

	if shared.triggerTopbar then
		shared.triggerTopbar(true)
	end
	
	if shared.triggerAwkbar then
		shared.triggerAwkbar(true)
	end

	if shared.triggerHotbar then
		shared.triggerHotbar(true)
	end
end

function module:StopAnim(AnimName)
	for _,v in AnimTracks do
		for _,vv in v do
			if vv.Animation.Name == AnimName then
				vv:Stop()

				break
			end
		end
	end

	for _,v in AnimTracks do
		for _,vv: AnimationTrack in v do
			if vv.IsPlaying then
				return
			end
		end
	end
	
	shared.triggerTopbar(true)
	shared.triggerAwkbar(true)
	shared.triggerHotbar(true)
end

function module:StartCustomCutscene(CutsceneName, Framerate, AnimationId, MainPart, Offset, LerpingInfo, TweeningInfo, AnimationFadeIn)
	if not CutsceneName or not MainPart or not MainPart.Parent or not MainPart:IsA("BasePart") then return end


	if not Framerate then
		Framerate = 60
	end

	if typeof(Offset) ~= "CFrame" then
		Offset = CFrame.new()
	end

	if typeof(LerpingInfo) ~= "table" then
		LerpingInfo = {
			Time = 0.8, 
			EasingStyle = Enum.EasingStyle.Exponential, 
			EasingDirection = Enum.EasingDirection.Out
		}
	end

	if typeof(TweeningInfo) ~= "table" then
		TweeningInfo = {
			Time = 0.6, 
			EasingStyle = Enum.EasingStyle.Exponential, 
			EasingDirection = Enum.EasingDirection.Out
		}
	end

	if typeof(LerpingInfo.Time) ~= "number" then
		LerpingInfo.Time = 1.2
	end

	if typeof(LerpingInfo.EasingStyle) ~= "EnumItem" then
		LerpingInfo.EasingStyle = Enum.EasingStyle.Exponential
	end

	if typeof(LerpingInfo.EasingDirection) ~= "EnumItem" then
		LerpingInfo.EasingDirection = Enum.EasingDirection.Out
	end

	if typeof(TweeningInfo.Time) ~= "number" then
		TweeningInfo.Time = 1
	end

	if typeof(TweeningInfo.EasingStyle) ~= "EnumItem" then
		TweeningInfo.EasingStyle = Enum.EasingStyle.Sine
	end

	if typeof(TweeningInfo.EasingDirection) ~= "EnumItem" then
		TweeningInfo.EasingDirection = Enum.EasingDirection.Out
	end

	if typeof(AnimationFadeIn) ~= "number" then
		AnimationFadeIn = -1
	end


	local CutsceneFolder = script.Cutscenes:FindFirstChild(CutsceneName)
	if CutsceneFolder == nil or CutsceneFolder.Parent == nil then return end

	local FovFolder = CutsceneFolder:FindFirstChild("FOV")
	if FovFolder == nil or FovFolder.Parent == nil then return end


	Camera.CameraType = Enum.CameraType.Scriptable

	local StartCamCF = Camera.CFrame
	local StartCamFOV = Camera.FieldOfView
	local StartTime = os.clock()

	local CameraRig = Instance.new("Model")
	CameraRig.Name = "CameraRig"
	CameraRig.Parent = workspace.Thrown

	local CameraPart = Instance.new("Part")
	CameraPart.Name = "Camera"
	CameraPart.Transparency = 1
	CameraPart.CanCollide = false
	CameraPart.CanTouch = false
	CameraPart.CastShadow = false
	CameraPart.CanQuery = false
	CameraPart.EnableFluidForces = false
	CameraPart.Anchored = false
	CameraPart.Size = Vector3.zero
	CameraPart.Massless = true
	CameraPart.Material = Enum.Material.SmoothPlastic
	CameraPart.Parent = CameraRig

	local CameraRoot = Instance.new("Part")
	CameraRoot.Name = "HumanoidRootPart"
	CameraRoot.Transparency = 1
	CameraRoot.CanCollide = false
	CameraRoot.CanTouch = false
	CameraRoot.CastShadow = false
	CameraRoot.CanQuery = false
	CameraRoot.EnableFluidForces = false
	CameraRoot.Anchored = false
	CameraRoot.Size = Vector3.zero
	CameraRoot.Massless = true
	CameraRoot.Material = Enum.Material.SmoothPlastic

	local WeldConstraint = Instance.new("WeldConstraint")
	WeldConstraint.Parent = CameraRoot
	WeldConstraint.Part0 = MainPart

	CameraRoot.Parent = CameraRig
	CameraRoot.CFrame = MainPart.CFrame * Offset

	WeldConstraint.Part1 = CameraRoot

	local Motor6D = Instance.new("Motor6D")
	Motor6D.Parent = CameraRoot
	Motor6D.Part0 = CameraRoot
	Motor6D.Part1 = CameraPart


	if workspace.Thrown:FindFirstChild("CutsceneBind") then
		workspace.Thrown.CutsceneBind:Destroy()
	end

	local CutsceneBind = Instance.new("Folder")
	CutsceneBind.Name = "CutsceneBind"
	CutsceneBind.Parent = workspace.Thrown


	local function EndCutscene()
		local LastFrame

		RNS:UnbindFromRenderStep("CutsceneCamera" .. StartTime)

		if CameraRig ~= nil and CameraRig.Parent ~= nil then
			CameraRig:Destroy()
		end

		if TweeningInfo.Time > 0 then
			local EndStartTime = os.clock()
			LastFrame = Camera.CFrame

			RNS:BindToRenderStep("CutsceneCameraSmoothOut" .. EndStartTime, Enum.RenderPriority.Camera.Value, function()
				Camera.CFrame = LastFrame:Lerp(Camera.CFrame, TS:GetValue((os.clock() - EndStartTime) / TweeningInfo.Time, TweeningInfo.EasingStyle, TweeningInfo.EasingDirection))
			end)

			if Camera.FieldOfView ~= 70 then
				TS:Create(Camera, TweenInfo.new(TweeningInfo.Time, TweeningInfo.EasingStyle, TweeningInfo.EasingDirection), {
					FieldOfView = 70
				}):Play()
			end

			Camera.CameraType = Enum.CameraType.Custom


			task.delay(TweeningInfo.Time, function()
				RNS:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. EndStartTime)
			end)

		else
			LastFrame = Camera.CFrame
			Camera.CameraType = Enum.CameraType.Custom
			Camera.FieldOfView = 70

		end
	end


	CutsceneBind.Destroying:Once(EndCutscene)


	if AnimationId then
		local Humanoid = Instance.new("Humanoid")
		Humanoid.Parent = CameraRig

		local Animator = Instance.new("Animator")
		Animator.Parent = Humanoid

		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://" .. tostring(AnimationId)

		local AnimationTrack = Animator:LoadAnimation(Animation)
		Animation:Destroy()
		AnimationTrack.Priority = Enum.AnimationPriority.Action4
		AnimationTrack:Play(AnimationFadeIn)


		local FrameCount = 0
		if LerpingInfo.Time > 0 then
			local FollowPart = Instance.new("Part")
			FollowPart.Name = "Follow"
			FollowPart.Transparency = 1
			FollowPart.CanCollide = false
			FollowPart.CanTouch = false
			FollowPart.CastShadow = false
			FollowPart.CanQuery = false
			FollowPart.EnableFluidForces = false
			FollowPart.Anchored = true
			FollowPart.Size = Vector3.zero
			FollowPart.Massless = true
			FollowPart.Material = Enum.Material.SmoothPlastic
			FollowPart.Parent = CameraRig
			FollowPart.CFrame = StartCamCF

			RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime)
				FrameCount += DeltaTime

				if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil and FollowPart ~= nil and FollowPart.Parent ~= nil then
					local GoalCF = CameraPart.CFrame
					local Alpha = TS:GetValue(FrameCount / LerpingInfo.Time, LerpingInfo.EasingStyle, LerpingInfo.EasingDirection)

					FollowPart.CFrame = StartCamCF:Lerp(GoalCF, Alpha)
					Camera.CFrame = FollowPart.CFrame


					local PastFrames = FrameCount * Framerate
					local MaxFrames = math.floor(PastFrames)
					local CurrentFrame = math.round(PastFrames)
					local CurrentFrameName = tostring(CurrentFrame)
					local NextFrameName = tostring(CurrentFrame + 1)

					if FovFolder:FindFirstChild(CurrentFrameName) then
						if FovFolder:FindFirstChild(NextFrameName) then
							local GoalFov = FovFolder[CurrentFrameName].Value
							local MaxFov = math.max(FovFolder[NextFrameName].Value, GoalFov)

							local FinalFov = (PastFrames - MaxFrames) * (GoalFov - MaxFov) + MaxFov
							if FinalFov < StartCamFOV then
								Camera.FieldOfView = Alpha * (FinalFov - StartCamFOV) + StartCamFOV
							else
								Camera.FieldOfView = StartCamFOV + Alpha * (FinalFov - StartCamFOV)
							end
						else
							Camera.FieldOfView = FovFolder[CurrentFrameName].Value
						end

					else
						local FirstFov = FovFolder["0"].Value
						local MinFov = math.min(FirstFov, StartCamFOV)
						local MaxFov = math.max(FirstFov, StartCamFOV)
						Camera.FieldOfView = Alpha * (MinFov - MaxFov) + MaxFov

					end

					if Alpha >= 1 then
						RNS:UnbindFromRenderStep("CutsceneCamera" .. StartTime)
						RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime)
							FrameCount += DeltaTime
							if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil then
								Camera.CFrame = CameraPart.CFrame
								local GoalFov = tostring(math.round(FrameCount * Framerate))
								if FovFolder:FindFirstChild(GoalFov) then
									Camera.FieldOfView = FovFolder[GoalFov].Value

									return
								end
							else
								CutsceneBind:Destroy()
							end
						end)
						return
					end
				else
					CutsceneBind:Destroy()
				end
			end)

		else
			RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime)
				FrameCount += DeltaTime

				if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil then
					Camera.CFrame = CameraPart.CFrame

					local GoalFov = tostring(math.round(FrameCount * Framerate))
					if FovFolder:FindFirstChild(GoalFov) then
						Camera.FieldOfView = FovFolder[GoalFov].Value
						return
					end

				else
					CutsceneBind:Destroy()
				end
			end)
		end

		AnimationTrack.Stopped:Connect(function()
			CutsceneBind:Destroy()
		end)

		return CameraRig, AnimationTrack

	else
		local FramesFolder = CutsceneFolder:FindFirstChild("Frames")

		local FrameCount = 0
		CameraRig:SetAttribute("Frame", 0)

		if LerpingInfo.Time > 0 then
			local FollowPart = Instance.new("Part")
			FollowPart.Name = "Follow"
			FollowPart.Transparency = 1
			FollowPart.CanCollide = false
			FollowPart.CanTouch = false
			FollowPart.CastShadow = false
			FollowPart.CanQuery = false
			FollowPart.EnableFluidForces = false
			FollowPart.Anchored = true
			FollowPart.Size = Vector3.zero
			FollowPart.Massless = true
			FollowPart.Material = Enum.Material.SmoothPlastic
			FollowPart.Parent = CameraRig
			FollowPart.CFrame = StartCamCF

			RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime) --[[ Line: 2634 ]]
				FrameCount += DeltaTime

				if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil and FollowPart ~= nil and FollowPart.Parent ~= nil and Motor6D ~= nil and Motor6D.Parent ~= nil then
					local CurrentFrame = FrameCount * Framerate
					local MaxFrame = math.floor(CurrentFrame)
					local CurrentFrame = math.round(FrameCount * Framerate)
					local CurrentFrameName = tostring(CurrentFrame)
					local Alpha = TS:GetValue(FrameCount / LerpingInfo.Time, LerpingInfo.EasingStyle, LerpingInfo.EasingDirection)

					if FramesFolder:FindFirstChild(CurrentFrameName) then
						Motor6D.C0 = FramesFolder[CurrentFrameName].Value
					end

					local GoalCF = CameraPart.CFrame
					Camera.CFrame = StartCamCF:Lerp(GoalCF, Alpha)

					local NextFrameName = tostring(CurrentFrame + 1)
					if FovFolder:FindFirstChild(CurrentFrameName) then
						if FovFolder:FindFirstChild(NextFrameName) then
							local GoalFov = FovFolder[CurrentFrameName].Value
							local NextFov = FovFolder[NextFrameName].Value
							local MaxFov = math.max(NextFov, GoalFov)
							local FinalFov = (CurrentFrame - MaxFrame) * (GoalFov - MaxFov) + MaxFov

							if FinalFov < StartCamFOV then
								Camera.FieldOfView = Alpha * (FinalFov - StartCamFOV) + StartCamFOV
							else
								Camera.FieldOfView = StartCamFOV + Alpha * (FinalFov - StartCamFOV)
							end
						else
							Camera.FieldOfView = FovFolder[CurrentFrameName].Value
						end

					else
						local FirstFov = FovFolder["0"].Value
						local MinFov = math.min(FirstFov, StartCamFOV)
						local MaxFov = math.max(FirstFov, StartCamFOV)

						Camera.FieldOfView = Alpha * (MinFov - MaxFov) + MaxFov
					end

					CameraRig:SetAttribute("Frame", CurrentFrame)

					if Alpha >= 1 then
						RNS:UnbindFromRenderStep("CutsceneCamera" .. StartTime)
						RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime)
							FrameCount += DeltaTime

							if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil then
								local FrameNumber = math.round(FrameCount * Framerate)
								local FrameName = tostring(FrameNumber)
								if FramesFolder:FindFirstChild(FrameName) then
									Motor6D.C0 = FramesFolder[FrameName].Value
								end

								Camera.CFrame = CameraPart.CFrame

								if FovFolder:FindFirstChild(FrameName) then
									Camera.FieldOfView = FovFolder[FrameName].Value
								end

								CameraRig:SetAttribute("Frame", FrameNumber)
								return

							else
								CutsceneBind:Destroy()
								return
							end
						end)

						return
					end
				else
					CutsceneBind:Destroy()
				end
			end)
		else
			RNS:BindToRenderStep("CutsceneCamera" .. StartTime, Enum.RenderPriority.Camera.Value, function(DeltaTime)
				FrameCount += DeltaTime

				if MainPart ~= nil and MainPart.Parent ~= nil and MainPart.Parent.Parent ~= nil and CameraPart ~= nil and CameraPart.Parent ~= nil then
					local FrameNumber = math.round(FrameCount * Framerate)
					local FrameName = tostring(FrameNumber)
					if FramesFolder:FindFirstChild(FrameName) then
						Motor6D.C0 = FramesFolder[FrameName].Value
					end

					Camera.CFrame = CameraPart.CFrame

					if FovFolder:FindFirstChild(FrameName) then
						Camera.FieldOfView = FovFolder[FrameName].Value
					end

					CameraRig:SetAttribute("Frame", FrameNumber)
					return
				else
					CutsceneBind:Destroy()
					return
				end
			end)
		end

		return CameraRig
	end
end

task.spawn(function()
	for Index, CameraRig in camRigs do
		for _, Animation: Animation in CamAnims:GetChildren() do
			if Animation:IsA('Animation') then
				AnimTracks[Index][Animation] = CameraRig.AnimationController.Animator:LoadAnimation(Animation)
			end
		end
	end
end)

return module