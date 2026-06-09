local l_CollectionService_0 = game:GetService("CollectionService")
local l_TextService_0 = game:GetService("TextService")
local l_TweenService_0 = game:GetService("TweenService")
local l_Players_0 = game:GetService("Players")
local l_Debris_0 = game:GetService("Debris")
local l_LocalPlayer_0 = l_Players_0.LocalPlayer
local v7 = {}

getColor = function(v8, v9)
    local v10 = v9[1]
    local v11 = v9[#v9]
    local v12 = 0.5
    local l_Value_0 = v10.Value
    for v14 = 1, #v9 - 1 do
        if v9[v14].Time <= v8 and v8 <= v9[v14 + 1].Time then
            v10 = v9[v14]
            v11 = v9[v14 + 1]
            v12 = (v8 - v10.Time) / (v11.Time - v10.Time)
            return (v10.Value:lerp(v11.Value, v12))
        end
    end
    return l_Value_0
end

local function v18(v15)
    for _, v17 in v15:GetChildren() do
        if v17.Name == "letter" then
            v17:SetAttribute("Ending", true)
            l_TweenService_0:Create(v17, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = v17.Position + UDim2.new(0, 0, 0, 50), 
                TextTransparency = 1, 
                TextStrokeTransparency = 1
            }):Play()
            l_TweenService_0:Create(v17.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Transparency = 1
            }):Play()
            l_Debris_0:AddItem(v17, 0.5)
        end
    end
end

v7.Speak = function(v19, v20, v21, v22)
	v19 = v19 or l_LocalPlayer_0
	local v23 = l_LocalPlayer_0.PlayerGui:FindFirstChild(v19.Name .. "CUSTOM_DIALOGUE") or script.CUSTOM_DIALOGUE:Clone()
	local l_Holder_0 = v23:WaitForChild("Holder")
	local l_Template_0 = l_Holder_0:WaitForChild("Template")
	local l_ImageLabel_0 = l_Template_0:WaitForChild("ImageLabel")
	local l_Name_0 = l_Template_0:WaitForChild("Name")
	local v28 = 0
	local v29 = 0
	local v30 = 0
	local v31 = false

	if not v23:GetAttribute("Created") then
		l_Holder_0.Position = l_Holder_0.Position - UDim2.fromOffset(0, #l_CollectionService_0:GetTagged("CUSTOM_DIALOGUE") * 100)
		l_ImageLabel_0.Position = l_ImageLabel_0.Position - UDim2.fromOffset(0, 100)
		l_Name_0.Position = l_Name_0.Position - UDim2.fromOffset(0, 100)
		if v20.Image then
			l_ImageLabel_0.Image = "rbxassetid://" .. v20.Image
		end

		if v20.ExtraImageSize then
			l_ImageLabel_0.Size = l_ImageLabel_0.Size + v20.ExtraImageSize
		end

		l_Name_0.TextTransparency = 1
		if v21 then
			l_Name_0.Gradient.Color = v21.Color or ColorSequence.new(Color3.new(1, 1, 1))
			l_Name_0.Stroke.Color = v21.StrokeColor or Color3.new(0, 0, 0)
		end

		l_TweenService_0:Create(l_ImageLabel_0, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = l_ImageLabel_0.Position + UDim2.fromOffset(0, 100), 
			ImageTransparency = 0
		}):Play()

		l_TweenService_0:Create(l_Name_0, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = l_Name_0.Position + UDim2.fromOffset(0, 100), 
			TextTransparency = 0
		}):Play()

		l_TweenService_0:Create(l_Name_0.Stroke, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()

		task.spawn(function()
			v23:SetAttribute("Created", os.clock())
			repeat
				task.wait()
			until os.clock() - v23:GetAttribute("Created") > (v22 or 5) or not v23.Parent or v31
			v23.Name = "deleting"
			v18(l_Template_0)
			local v32 = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			l_TweenService_0:Create(l_ImageLabel_0, v32, {
				Position = l_ImageLabel_0.Position - UDim2.fromOffset(0, 100), 
				ImageTransparency = 1
			}):Play()
			l_TweenService_0:Create(l_Name_0, v32, {
				Position = l_Name_0.Position - UDim2.fromOffset(0, 100), 
				TextTransparency = 1
			}):Play()
			l_TweenService_0:Create(l_Name_0.Stroke, v32, {
				Transparency = 1
			}):Play()
			task.delay(1, v23.Destroy, v23)
		end)
	else
		v23:SetAttribute("Created", os.clock())
	end

	v23.Name = v19.Name .. "CUSTOM_DIALOGUE"
	v23:AddTag("CUSTOM_DIALOGUE")
	l_Name_0.Text = v19.Name
	v23.Enabled = true
	v23.Parent = l_LocalPlayer_0.PlayerGui
	local v33 = v20.HigherUp and 0.8888888888888888 or 1
	local v34 = UDim2.fromScale(0.5, v33)

	if l_Holder_0.Position ~= v34 then
		l_TweenService_0:Create(l_Holder_0, TweenInfo.new(v20.HigherUp and 0.6 or 1), {
			Position = v34
		}):Play()
	end

	v18(l_Template_0)
	v33 = string.split(v20.Text, "")
	v34 = v20.Bold and Enum.Font.SourceSansBold or v20.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans
	for _, v36 in v33 do
		v28 = v28 + l_TextService_0:GetTextSize(v36, 25, v34, Vector2.new(100, 100)).X
	end

	for _, v38 in v33 do
		local l_l_TextService_0_TextSize_0 = l_TextService_0:GetTextSize(v38, 25, v34, Vector2.new(100, 100))
		local l_TextLabel_0 = Instance.new("TextLabel")
		local v41 = Instance.new("UIStroke", l_TextLabel_0)
		local l_v28_0 = v28
		local l_v29_0 = v29
		l_TextLabel_0.Name = "letter"
		l_TextLabel_0.AnchorPoint = Vector2.new(0, 0.5)
		l_TextLabel_0.Position = UDim2.new(0.5, l_v29_0 - l_v28_0 / 2 // 1, 0.5, 10)
		l_TextLabel_0.Size = UDim2.fromOffset(l_l_TextService_0_TextSize_0.X, l_l_TextService_0_TextSize_0.Y)
		l_TextLabel_0.Font = v34
		l_TextLabel_0.Text = v38
		l_TextLabel_0.TextSize = 25
		l_TextLabel_0.BackgroundTransparency = 1
		v41.Color = v20.TextStrokeColor

		if v20.Shake then
			v41.Transparency = 1
			l_TextLabel_0.TextTransparency = 1
			task.delay(v30, function()
				local v44 = os.clock()
				repeat
					local v45 = math.min((os.clock() - v44) / 0.35, 1)
					local v46 = math.min((os.clock() - v44) / v20.Shake.Lifetime, 1)
					local v47 = not v20.Shake.Enabled and UDim2.fromOffset(0, 0) or UDim2.fromOffset(math.random(-v20.Shake.Intensity, v20.Shake.Intensity) * (1 - v46), math.random(-v20.Shake.Intensity, v20.Shake.Intensity) * (1 - v46))
					local v48 = 1 - (math.pow(v45 - 1, 3) * 2.70158 + 1 + math.pow(v45 - 1, 2) * 1.70158)
					v41.Transparency = (1 - v45) ^ 10
					l_TextLabel_0.TextTransparency = v48
					l_TextLabel_0.TextSize = v48 * 25 + 25
					l_TextLabel_0.TextColor3 = getColor(v45, v20.Color.Keypoints)
					l_TextLabel_0.Position = UDim2.new(0.5, l_v29_0 - l_v28_0 / 2 // 1, 0.5, 0) + v47
					task.wait()
				until os.clock() - v44 > math.max(0.35, v20.Shake.Lifetime) or not l_TextLabel_0 or not l_TextLabel_0:IsDescendantOf(v23) or l_TextLabel_0:GetAttribute("Ending")
				if l_TextLabel_0 then
					l_TextLabel_0.Position = UDim2.new(0.5, l_v29_0 - l_v28_0 / 2 // 1, 0.5, 0)
					l_TextLabel_0.TextSize = 25
					l_TextLabel_0.TextColor3 = v20.Color.Keypoints[#v20.Color.Keypoints].Value
					v41.Transparency = 0
					l_TextLabel_0.TextTransparency = 0
				end
			end)
		else
			l_TextLabel_0.TextColor3 = v20.Color.Keypoints[#v20.Color.Keypoints].Value
			v41.Transparency = 0
			l_TextLabel_0.TextTransparency = 0
		end
		l_TextLabel_0.Parent = l_Template_0
		v30 = v30 + v20.TypeSpeed
		v29 = v29 + l_l_TextService_0_TextSize_0.X
	end
	return function()
		v31 = true
	end
end
return v7