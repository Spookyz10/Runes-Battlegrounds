local module = {}
local RNS = game:GetService('RunService')
local TS = game:GetService('TweenService')
local PlayingAnimations = {}
local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Player:GetPropertyChangedSignal('Character'):Connect(function()
	Character = Player.Character
end)
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

local CameraTableFunctions = {
	['Dropkick'] = function(Table, MainPart)
		local StartRootCF = Character.HumanoidRootPart.CFrame
		local startTick = tick()
		local FrameTime = 0

		PlayingAnimations['Dropkick'] = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
			local realDelta = deltaTime * 60
			FrameTime = FrameTime + realDelta
			local CurrVal = tonumber((math.ceil(FrameTime)))
			if CurrVal >= 922 then
				CurrVal = 2000000000
			end
			local CurrValTable = Table[CurrVal]
			if CurrValTable and Character.Parent then
				if Camera.CameraType ~= Enum.CameraType.Scriptable then
					Camera.CameraType = Enum.CameraType.Scriptable
				end


				if tick() - startTick > 0.5 then
					Camera.FieldOfView = CurrValTable.fov
				else
					local Camera = Camera
					local l_FieldOfView_1 = Camera.FieldOfView
					Camera.FieldOfView = l_FieldOfView_1 + (CurrValTable.fov - l_FieldOfView_1) * 0.25
				end
			else
				module:StopAnimations()
			end
		end)
	end,

	['Counter'] = function(Table, MainPart)
		local startTick = tick()

		local FrameTime = 0
		PlayingAnimations['Counter'] = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
			local realDelta = deltaTime * 60
			FrameTime = FrameTime + realDelta
			local CurrTable = Table[tonumber((math.ceil(FrameTime)))]
			if Character.Parent and CurrTable then
				if Camera.CameraType ~= Enum.CameraType.Scriptable then
					Camera.CameraType = Enum.CameraType.Scriptable
				end
				if tick() - startTick > 1.8 then
					Camera.FieldOfView = CurrTable.fov
				else
					local lastFov = Camera.FieldOfView

					Camera.FieldOfView = lastFov + (CurrTable.fov - lastFov) * 0.25
				end

				Camera.CFrame = Camera.CFrame:lerp(MainPart.CFrame * CurrTable.cframe, 0.5)
			else
				module:StopAnimations()
			end
		end)
	end,
	
	['combatgods'] = function(Table, MainPart)
		local startTick = tick()
		local FrameTime = 0
		local CamOffset = CFrame.new(-0.5, 0, 0)

		PlayingAnimations['combatgods'] = RNS.RenderStepped:Connect(function(deltaTime)
			FrameTime += deltaTime * 60
			local CurrentFrame = math.ceil(FrameTime)
			local fov = Table.FOV[CurrentFrame]
			if not fov then
				module:StopAnimations()
				return
			end

			if Camera.CameraType ~= Enum.CameraType.Scriptable then
				Camera.CameraType = Enum.CameraType.Scriptable
			end

			local moreThan1 = tick() - startTick > 1
			local currFov = Camera.FieldOfView
			local alpha = deltaTime * (moreThan1 and 5 or 10)

			Camera.FieldOfView = currFov + (fov - currFov) * alpha

			local targetCFrame = MainPart.CFrame * CamOffset
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
		end)
	end,
}



function module:PlayAnimation(TableName: string, MainPart: Part)
	local TableModule = script[TableName]
	local Table = require(TableModule)
	local CamTFunc = CameraTableFunctions[TableName]

	if CamTFunc ~= nil then
		CamTFunc(Table, MainPart)
	else
		local FrameTime = 0
		local startTick = tick()
		local LastPos

		PlayingAnimations[TableName] = RNS.RenderStepped:Connect(function(deltaTime)
			FrameTime += deltaTime * 60

			local CurrentFrame = tonumber((math.ceil(FrameTime)))
			local FrameInfo = Table[CurrentFrame]
			if Character.Parent and FrameInfo then
				local moreThan1 = tick() - startTick > 1


				if FrameInfo.fov then
					local currFov = Camera.FieldOfView
					if moreThan1 then
						Camera.FieldOfView = currFov + ((FrameInfo.fov - currFov) * (1 - 9.0E-25 ^ deltaTime))
					else
						Camera.FieldOfView = currFov + ((FrameInfo.fov - currFov) * (1 - 9.0E-7 ^ deltaTime))
					end
				end


				if FrameInfo.cframe then
					if Camera.CameraType ~= Enum.CameraType.Scriptable then
						Camera.CameraType = Enum.CameraType.Scriptable
					end

					local nextPos = MainPart.CFrame * FrameInfo.cframe
					local noLerp = nil
					if LastPos and (LastPos.Position - nextPos.Position).magnitude >= 10 then
						noLerp = true
					end
					LastPos = nextPos

					if noLerp then
						Camera.CFrame = nextPos
					elseif moreThan1 then
						Camera.CFrame = Camera.CFrame:lerp(nextPos, 1 - 9.0E-25 ^ deltaTime)
					else
						Camera.CFrame = Camera.CFrame:lerp(nextPos, 1 - 9.0E-7 ^ deltaTime)
					end
				end
			else
				module:StopAnimations()
			end
		end)
	end
end

function module:StopAnimations()
	for TableName, Connection in PlayingAnimations do
		Connection:Disconnect()
		PlayingAnimations[TableName] = nil

		if TableName == 'FiveEnd' or TableName == 'KJWallcombo' or TableName == 'OneInch' then
			Camera.CameraType = Enum.CameraType.Custom
			TS:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
		elseif TableName == 'NMG' then
			TS:Create(Camera, TweenInfo.new(.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
		end
	end

	if shared.triggerAwkbar then
		shared.triggerAwkbar(true)
	end

	if shared.triggerHotbar then
		shared.triggerHotbar(true)
	end
end

return module