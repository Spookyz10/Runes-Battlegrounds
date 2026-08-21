local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client

local LocalPlayer = game.Players.LocalPlayer

return {
	GetHLF = function(Part)
		local HighestLifetime = 0
		for _, v in Part:GetDescendants() do
			if v:IsA("ParticleEmitter") and v.Lifetime.Max > HighestLifetime then
				HighestLifetime = v.Lifetime.Max
			end
		end

		return HighestLifetime
	end,

	Emit = function(Part)
		if Part:IsA("ParticleEmitter") then
			local EmitDelay = Part:GetAttribute("EmitDelay")
			if typeof(EmitDelay) ~= "number" or EmitDelay <= 0 then
				local EmitCount = Part:GetAttribute("EmitCount") or tonumber(Part.Name) or 1

				if not LocalPlayer:GetAttribute("Fast_Mode") then
					Part:Emit(EmitCount)
				else
					Part:Emit(math.ceil(EmitCount / 2))
				end

				local EmitDuration = tonumber(Part:GetAttribute("EmitDuration"))
				if typeof(EmitDuration) == "number" and EmitDuration > 0 then
					Part.Enabled = true

					task.delay(EmitDuration, function()
						if not Part or not Part.Parent then
							return
						end
						Part.Enabled = false
					end)
				end
			else
				task.delay(EmitDelay, function()
					if Part ~= nil and Part.Parent ~= nil then
						local EmitCount = Part:GetAttribute("EmitCount") or tonumber(Part.Name) or 1

						if not LocalPlayer:GetAttribute("Fast_Mode") then
							Part:Emit(EmitCount)
						else
							Part:Emit(math.ceil(EmitCount / 2))
						end

						local EmitDuration = tonumber(Part:GetAttribute("EmitDuration"))
						if typeof(EmitDuration) == "number" and EmitDuration > 0 then
							Part.Enabled = true

							task.delay(EmitDuration, function()
								if not Part or not Part.Parent then
									return
								end
								Part.Enabled = false
							end)
						end
					end
				end)
			end
		else
			for _, Particle in pairs(Part:GetDescendants()) do
				if Particle:IsA("ParticleEmitter") then
					local EmitDelay = Particle:GetAttribute("EmitDelay")
					if typeof(EmitDelay) ~= "number" or EmitDelay <= 0 then
						local EmitCount = Particle:GetAttribute("EmitCount") or tonumber(Particle.Name) or 1

						local FastMode = Data.Settings.FastMode()
						Particle:Emit(FastMode and math.ceil(EmitCount / 2) or EmitCount)

						local EmitDuration = tonumber(Particle:GetAttribute("EmitDuration"))
						if typeof(EmitDuration) == "number" and EmitDuration > 0 then
							Particle.Enabled = true

							task.delay(EmitDuration, function()
								if not Particle or not Particle.Parent then
									return
								end
								Particle.Enabled = false
							end)
						end
					else
						task.delay(EmitDelay, function()
							if not Particle or not Particle.Parent then
								return
							end

							local EmitCount = Particle:GetAttribute("EmitCount") or tonumber(Particle.Name) or 1

							if not LocalPlayer:GetAttribute("Fast_Mode") then
								Particle:Emit(EmitCount)
							else
								Particle:Emit(math.ceil(EmitCount / 2))
							end

							local EmitDuration = tonumber(Particle:GetAttribute("EmitDuration"))
							if typeof(EmitDuration) == "number" and EmitDuration > 0 then
								Particle.Enabled = true

								task.delay(EmitDuration, function()
									if not Particle or not Particle.Parent then
										return
									end
									Particle.Enabled = false
								end)
							end
						end)
					end
				elseif Particle:IsA("Beam") then
					local EmitDuration = Particle:GetAttribute("EmitDuration")

					if typeof(EmitDuration) == "number" and EmitDuration > 0 then
						local EmitDelay = Particle:GetAttribute("EmitDelay")

						if typeof(EmitDelay) == "number" and EmitDelay > 0 then
							task.delay(EmitDelay, function()
								if not Particle or not Particle.Parent then
									return
								end

								Particle.Enabled = true

								task.delay(EmitDuration, function()
									if not Particle or not Particle.Parent then
										return
									end

									Particle.Enabled = false
								end)
							end)
						else
							Particle.Enabled = true
							task.delay(EmitDuration, function()
								if Particle ~= nil and Particle.Parent ~= nil then
									Particle.Enabled = false
								end
							end)
						end
					end
				end
			end
		end
	end,

	Enabled = function(Part, State)
		for _, v in Part:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				if not LocalPlayer:GetAttribute("Fast_Mode") then
				end
				if LocalPlayer:GetAttribute("Fast_Mode") and not v:GetAttribute("Optimized") then
					v:SetAttribute("Optimized", true)
					v.Rate /= 2
				elseif not LocalPlayer:GetAttribute("Fast_Mode") and v:GetAttribute("Optimized") then
					v:SetAttribute("Optimized", nil)
					v.Rate *= 2
				end

				v.Enabled = State
			elseif v:IsA("Beam") or v:IsA("Trail") then
				if LocalPlayer:GetAttribute("Fast_Mode") and not v:GetAttribute("Optimized") then
					v:SetAttribute("Optimized", true)
				elseif not LocalPlayer:GetAttribute("Fast_Mode") and v:GetAttribute("Optimized") then
					v:SetAttribute("Optimized", nil)
				end

				v.Enabled = State
			end
		end
	end,

	EnableTrail = function(Part, State)
		for _, v in Part:GetDescendants() do
			if v:IsA("Trail") then
				v.Enabled = State
			end
		end
	end,

	scaleLifetime = function(Part, newScale)
		for _, Particle in Part:GetDescendants() do
			if Particle:IsA("ParticleEmitter") then
				Particle.Lifetime = NumberRange.new(Particle.Lifetime.Min * newScale, Particle.Lifetime.Max * newScale)
			end
		end
	end,

	tweenScale = function(Model, Parameters)
		local scaleValue = Instance.new("NumberValue")
		scaleValue.Value = Parameters.startScale or Model:GetScale()
		scaleValue:GetPropertyChangedSignal("Value"):Connect(function()
			Model:ScaleTo(scaleValue.Value)
		end)

		TS:Create(scaleValue, Parameters.Info, { Value = Parameters.goalScale }):Play()

		Debris:AddItem(scaleValue, Parameters.Info.Time)
	end,

	resizeParticle = function(Container: Part, GoalSize: number)
		local ResizeContainer = Instance.new("Model")
		local Parent = Container.Parent

		Container.Parent = ResizeContainer

		ResizeContainer:ScaleTo(GoalSize)

		Container.Parent = Parent

		ResizeContainer:Destroy()

		return Container
	end,

	toggleAllEmitters = function(inside, new)
		for _, Emitter in inside:GetDescendants() do
			if Emitter:IsA("ParticleEmitter") then
				Emitter.Enabled = new or false
			end
		end
	end,

	doEmitCount = function(inside)
		for _, Emitter in inside:GetDescendants() do
			if not Emitter:IsA("ParticleEmitter") then
				continue
			end

			if not Emitter:IsA("ParticleEmitter") then
				return
			end
			if Emitter:GetAttribute("EmitDelay") then
				task.spawn(function()
					task.wait(Emitter:GetAttribute("EmitDelay"))
					Emitter:Emit(Emitter:GetAttribute("EmitCount") or 0)
				end)
			else
				Emitter:Emit(Emitter:GetAttribute("EmitCount") or 0)
			end
		end
	end,
}
