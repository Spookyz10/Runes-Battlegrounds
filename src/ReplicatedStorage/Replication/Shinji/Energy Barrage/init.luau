local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local collectionservice = game:GetService("CollectionService")

local Module = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local rock = require(Module.Rock)
local MeshEmit = require(Module.MeshEmit)

local module = {
	["LastKick"] = function(character : Model, bodyvelocity : BodyVelocity)
		if character.Parent and bodyvelocity.Parent then
			local rootpart : Part = character.HumanoidRootPart

			local numbervalue = Instance.new("NumberValue")
			numbervalue.Value = 135

			bodyvelocity.MaxForce = Vector3.new(1 * 100000, 0, 1 * 100000)
			bodyvelocity.P = 25000
			bodyvelocity.Velocity = rootpart.CFrame.LookVector * numbervalue.Value

			local connection
			connection = RunService.Heartbeat:Connect(function(dt)
				if character.Parent then
					if bodyvelocity.Parent then
						bodyvelocity.MaxForce = Vector3.new(1 * 100000, 0, 1 * 100000)
						bodyvelocity.P = 25000
						bodyvelocity.Velocity = rootpart.CFrame.LookVector * numbervalue.Value
					end
				else
					connection:Disconnect()
				end
			end)

			TweenService:Create(numbervalue, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Value = 0
			}):Play()
		end
	end,
	["Emit"] = function(character : Model, action : string)
		if character.Parent then
			local rootpart : Part = character:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			if character:GetAttribute("Stunned") == true then return end

			if action == "push" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Push:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end

				local path = Assets.VFX.Shinji.EnergyBarrage.Eye:Clone()
				path.Parent = character:WaitForChild("Head")

				for _, v in pairs(path:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = true
						task.delay(6, function()
							v.Enabled = false
						end)
					end
				end
			elseif action == "run1" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Run1:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "run2" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Run2:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "hit1" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Hit1:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "hit11" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Hit11:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end

				local meshEmit = require(ReplicatedStorage.Modules.MeshEmit)
				local meshes = Assets.VFX.Shinji.EnergyBarrage.Meshes.Hit

				for _, v in meshes:GetChildren() do
					v:PivotTo(character:WaitForChild("HumanoidRootPart").CFrame)
					meshEmit(v.Start)
				end
			elseif action == "stomp" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Stomp:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "bite" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Bite:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end

				local meshEmit = require(ReplicatedStorage.Modules.MeshEmit)
				local meshes = Assets.VFX.Shinji.EnergyBarrage.Meshes.Hit2

				for _, v in meshes:GetChildren() do
					v:PivotTo(character:WaitForChild("HumanoidRootPart").CFrame)
					meshEmit(v.Start)
				end
			elseif action == "run3" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Run3:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "run4" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Run4:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "jump" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Jump:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "headspin" then
				local path = Assets.VFX.Shinji.EnergyBarrage.HeadSpin:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "charspin" then
				local path = Assets.VFX.Shinji.EnergyBarrage.CharSpin2:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "leg" then
				local path = Assets.VFX.Shinji.EnergyBarrage.LegAura

				for _, v in pairs(path:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						local particle = v:Clone()
						particle.Parent = character["Right Leg"]
						Debris:AddItem(particle, 5)
						particle.Enabled = true
						task.delay(1, function()
							particle.Enabled = false
						end)
					end
				end
			elseif action == "hit2" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Hit2:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end
			elseif action == "hit22" then
				local path = Assets.VFX.Shinji.EnergyBarrage.Hit22:Clone()
				path.Parent = rootpart
				Debris:AddItem(path, 10)

				for _, particle in pairs(path:GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Emit(particle:GetAttribute("EmitCount"))
					end
				end

				local meshEmit = require(ReplicatedStorage.Modules.MeshEmit)
				local meshes = Assets.VFX.Shinji.EnergyBarrage.Meshes.Hit3

				for _, v in meshes:GetChildren() do
					v:PivotTo(character:WaitForChild("HumanoidRootPart").CFrame)
					meshEmit(v.Start)
				end
			end
		end
	end,

}

return module
