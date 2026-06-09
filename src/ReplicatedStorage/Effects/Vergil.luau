local ReplicatedStorage = game:GetService('ReplicatedStorage')


local module = {
	durationTime = {}
}
local Utility = require(ReplicatedStorage.Utility)
local Parent = require(script.Parent)
local function sheathVFX(arg1)
	for _, v in pairs(arg1.Sheath:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
end

local function Emit(arg1) 
	for _, v_2_upvr in pairs(arg1) do
		if v_2_upvr:IsA("ParticleEmitter") then
			if v_2_upvr:GetAttribute("EmitDelay") then
				task.delay(v_2_upvr:GetAttribute("EmitDelay"), function()
					v_2_upvr:Emit(v_2_upvr:GetAttribute("EmitCount"))
				end)
			else
				v_2_upvr:Emit(v_2_upvr:GetAttribute("EmitCount"))
			end
			if v_2_upvr:GetAttribute("EmitDuration") then
				v_2_upvr.Enabled = true
				task.delay(v_2_upvr:GetAttribute("EmitDuration"), function() 
					v_2_upvr.Enabled = false
				end)
			end
		end
	end
end
function module.sheathVFX(arg1) 
	sheathVFX(arg1.Parent)
end

function module.JudgementCut(arg1, arg2)
	local clone_7 = ReplicatedStorage.Resources.Vergil.judend:Clone()
	clone_7.Parent = game.Workspace.Effects
	clone_7:SetPrimaryPartCFrame(arg1.CFrame)
	for _, v_3 in pairs(clone_7.wind.Emit1:GetDescendants()) do
		if v_3:IsA("ParticleEmitter") then
			v_3:Emit(v_3:GetAttribute("EmitCount"))
		end
	end
	for _, v_4 in pairs(clone_7.wind.Enables:GetDescendants()) do
		if v_4:IsA("ParticleEmitter") then
			v_4.Enabled = true
		end
	end
	for _, v_5 in pairs(clone_7.Bwind.Beam:GetDescendants()) do
		if v_5:IsA("Beam") then
			game:GetService("TweenService"):Create(v_5, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Brightness = 0.5;
			}):Play()
		end
	end
	for _, v_6 in pairs(clone_7.Aura:GetDescendants()) do
		if v_6:IsA("ParticleEmitter") then
			v_6.Enabled = true
		end
	end
	task.wait(1.6)
	for _, v_7 in pairs(clone_7.wind.Enables:GetDescendants()) do
		if v_7:IsA("ParticleEmitter") then
			v_7.Enabled = false
		end
	end
	for _, v_8 in pairs(clone_7.Bwind.Beam:GetDescendants()) do
		if v_8:IsA("Beam") then
			game:GetService("TweenService"):Create(v_8, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Brightness = 0;
			}):Play()
		end
	end
	for _, v_9 in pairs(arg1.Parent.JUDSheath:GetDescendants()) do
		if v_9:IsA("ParticleEmitter") then
			v_9:Emit(v_9:GetAttribute("EmitCount"))
		end
	end
	task.wait(0.1)
	for _, v_10 in pairs(clone_7.Slash:GetDescendants()) do
		if v_10:IsA("ParticleEmitter") then
			v_10.Enabled = true
		end
	end
	for _, v_11 in pairs(clone_7.Dash:GetDescendants()) do
		if v_11:IsA("ParticleEmitter") then
			v_11:Emit(v_11:GetAttribute("EmitCount"))
		end
	end
	for _, v_12 in pairs(clone_7.Aura:GetDescendants()) do
		if v_12:IsA("ParticleEmitter") then
			v_12.Enabled = false
		end
	end
	for _, v_13 in pairs(clone_7.Slash:GetDescendants()) do
		if v_13:IsA("ParticleEmitter") then
			game:GetService("TweenService"):Create(v_13, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TimeScale = 0;
			}):Play()
		end
	end
	for _, v_14 in pairs(clone_7.Slash1:GetDescendants()) do
		if v_14:IsA("ParticleEmitter") then
			v_14.Enabled = true
		end
	end
	task.wait(0.1)
	for _, v_15 in pairs(clone_7.Slash:GetDescendants()) do
		if v_15:IsA("ParticleEmitter") then
			v_15.Enabled = false
		end
	end
	for _, v_16 in pairs(clone_7.Slash1:GetDescendants()) do
		if v_16:IsA("ParticleEmitter") then
			v_16.Enabled = false
		end
	end
	task.wait(1.5)
	for _, v_17 in pairs(clone_7.land:GetDescendants()) do
		if v_17:IsA("ParticleEmitter") then
			v_17:Emit(v_17:GetAttribute("EmitCount"))
		end
	end
	for _, v_18 in pairs(clone_7.land:GetDescendants()) do
		if v_18:IsA("ParticleEmitter") then
			game:GetService("TweenService"):Create(v_18, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TimeScale = 0;
			}):Play()
		end
	end
	for _, v_19 in pairs(clone_7.land:GetDescendants()) do
		if v_19:IsA("ParticleEmitter") then
			v_19:Emit(v_19:GetAttribute("EmitCount"))
		end
	end
	task.wait(1.15)
	for _, v_20 in pairs(clone_7.Slash:GetDescendants()) do
		if v_20:IsA("ParticleEmitter") then
			game:GetService("TweenService"):Create(v_20, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TimeScale = 1;
			}):Play()
		end
	end
	for _, v_21 in pairs(clone_7.land:GetDescendants()) do
		if v_21:IsA("ParticleEmitter") then
			v_21:Emit(v_21:GetAttribute("EmitCount"))
		end
	end
	for _, v_22 in pairs(clone_7.land:GetDescendants()) do
		if v_22:IsA("ParticleEmitter") then
			game:GetService("TweenService"):Create(v_22, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TimeScale = 1;
			}):Play()
		end
	end
	task.wait(0.365)
	for _, v_23 in pairs(clone_7.wind.Emit1:GetDescendants()) do
		if v_23:IsA("ParticleEmitter") then
			v_23:Emit(v_23:GetAttribute("EmitCount"))
		end
	end
	for _, v_24 in pairs(arg1.Parent.JUDSheath:GetDescendants()) do
		if v_24:IsA("ParticleEmitter") then
			v_24:Emit(v_24:GetAttribute("EmitCount"))
		end
	end
	Utility.Services.Debris:AddItem(clone_7, 5)
end
function module.Glass(arg1)
	for _, v_36 in pairs(arg1.Parent:GetChildren()) do
		if v_36:IsA("BasePart") and v_36.Parent.PrimartPart ~= v_36 then
			local Part = Instance.new("Part")
			Part.Anchored = true
			Part.Material = Enum.Material.Glass
			Part.Transparency = 0.5
			Part.Size = v_36.Size
			Part.CFrame = v_36.CFrame
			Part.CanCollide = false
			Part.Parent = workspace.Effects
			Utility.Services.Tween:Create(v_36, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Transparency = 1;
			}):Play()
			Utility.Services.Debris:AddItem(v_36, 0.5)
		end
	end
end
function module.END()
	local clone_11_upvr = ReplicatedStorage.Resources.Flash:Clone()
	clone_11_upvr.Brightness = 0.8
	clone_11_upvr.Enabled = true
	clone_11_upvr.Parent = game.Lighting
	Parent.fieldOfView(true, 100, 3.5, Enum.EasingStyle.Linear)
	task.delay(0.1, function() 
		Utility.Services.Tween:Create(clone_11_upvr, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Saturation = -3.5;
			Contrast = 0.4;
		}):Play()
	end)
	Utility.Services.Tween:Create(clone_11_upvr, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
		Brightness = 0;
	}):Play()
	task.wait(3)
	clone_11_upvr:Destroy()
	local clone_14 = ReplicatedStorage.Resources.Flash:Clone()
	clone_14.Brightness = 0.6
	clone_14.Enabled = true
	clone_14.Parent = game.Lighting
	Utility.Services.Tween:Create(clone_14, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
		Brightness = 0;
	}):Play()
	Parent.fieldOfView(true, 70, 0.36, Enum.EasingStyle.Linear)
	task.wait(0.36)
	clone_14:Destroy()
end


return module
