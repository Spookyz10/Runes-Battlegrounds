local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local l_TweenService_0 = game:GetService("TweenService")
local l_RunService_0 = game:GetService("RunService")
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer
local l_CurrentCamera_0 = workspace.CurrentCamera

local v5 = require(l_ReplicatedStorage_0.Modules.Game.Utility)
local v6 = require(l_ReplicatedStorage_0.Modules.Game.Job)
local v7 = nil

return function(v8, v9, v10, v11, v12) 
    if v7 then
        v7()
        v7 = nil
	end
	
    v11 = v11 or {}
    v10 = v10 or CFrame.identity
    local v13 = true
    local l_CFrame_0 = l_CurrentCamera_0.CFrame
    local l_AttachTo_0 = v9:FindFirstChild("AttachTo")
    local v16 = l_AttachTo_0 and l_AttachTo_0.Value or v9.camera
    local v17 = v6.new()
    v17:Task(v9)
    local l_NumberValue_0 = Instance.new("NumberValue")
	v17:Task(l_NumberValue_0)
	
	local function DisconnectRunner()
        l_RunService_0:UnbindFromRenderStep("CutsceneCamera")
	end
	
    local v20 = false
    local function v22()
        if v20 then
            return
        else
            v20 = true
            l_RunService_0:UnbindFromRenderStep("CutsceneCamera")
            v17:Destroy()
            if not v11.DontSaveCameraPosition and v13 then
                l_CurrentCamera_0.CFrame = l_CFrame_0
			end
			
            if l_LocalPlayer_0.Character then
                local l_Humanoid_0 = l_LocalPlayer_0.Character:FindFirstChild("Humanoid")
                if l_Humanoid_0 then
                    l_CurrentCamera_0.CameraSubject = l_Humanoid_0
                end
			end
			
            l_LocalPlayer_0.CameraMinZoomDistance = 0.5
            l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
            return
        end
	end
	
	local function OnDisabledSetting()
        l_RunService_0:UnbindFromRenderStep("CutsceneCamera")
        if not v11.DontSaveCameraPosition then
            l_CurrentCamera_0.CFrame = l_CFrame_0
		end
		
        l_LocalPlayer_0.CameraMinZoomDistance = 0.5
        l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
	end
	
    local function v26() 
        l_LocalPlayer_0.CameraMinZoomDistance = 2
        if l_LocalPlayer_0.Character then
            for _, v25 in l_LocalPlayer_0.Character:GetDescendants() do
                if v25:IsA("BasePart") then
                    v25.LocalTransparencyModifier = 0
                end
            end
		end
		
        l_CFrame_0 = l_CurrentCamera_0.CFrame
        l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
        if not v11.DontDoTransition then
            l_NumberValue_0.Value = 0
            l_TweenService_0:Create(l_NumberValue_0, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Value = 1
            }):Play()
		end
		
        l_RunService_0:BindToRenderStep("CutsceneCamera", v5.ShiftlockRenderPriority, function()
            if l_LocalPlayer_0.Character == nil or v9.Parent == nil then
                return v22()
            else
                if v8 then
                    v9:PivotTo(v8.CFrame * v10)
                end
                if not v11.DontDoTransition then
                    l_CurrentCamera_0.CFrame = l_CFrame_0:Lerp(v16.CFrame, l_NumberValue_0.Value)
                    return
                else
                    l_CurrentCamera_0.CFrame = v16.CFrame
                    return
                end
            end
        end)
	end
	
    local v27 = {}
    for _, v29 in ipairs(v9:GetDescendants()) do
        if v29:IsA("BasePart") then
            v27[v29] = v29.Transparency
        end
	end
	
    local function v32() 
        if v20 then
            return
        else
            v13 = l_LocalPlayer_0:GetAttribute("Cutscenes") and not l_LocalPlayer_0:GetAttribute("InFreecam")
            if v13 then
                v26()
            else
                l_RunService_0:UnbindFromRenderStep("CutsceneCamera")
                if not v11.DontSaveCameraPosition then
                    l_CurrentCamera_0.CFrame = l_CFrame_0
                end
                l_LocalPlayer_0.CameraMinZoomDistance = 0.5
                l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
            end
            if v12 then
                task.spawn(v12, v13)
            end
            for v30, v31 in v27 do
                if v31 == 0 then
                    v30.Transparency = v13 and 0 or 1
                end
            end
            return
        end
	end
	
    if not v11.DontSupportCutsceneSetting then
        v17:Task(l_LocalPlayer_0:GetAttributeChangedSignal("Cutscenes"):Connect(v32))
        v32()
    else
        v26()
    end
    v7 = v22
    return v22
end