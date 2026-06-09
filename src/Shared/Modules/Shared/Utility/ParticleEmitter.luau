--// VARIABLES
local Module = {}
local TS = game:GetService("TweenService")

--// MODULE FUNCTIONS
function Module.Emit(instance: Instance)
	if instance:IsA("ParticleEmitter") then
		local duration = instance:GetAttribute("EmitDuration")
		if duration then
			instance.Enabled = true
			task.delay(duration, function()
				instance.Enabled = false
			end)
		end

		local count = instance:GetAttribute("EmitCount")
		if count then
			local emitDelay = instance:GetAttribute("EmitDelay") or 0
			task.delay(emitDelay, function()
				instance:Emit(count)
			end)
		end
	elseif instance:IsA("Beam") then
		local duration = instance:GetAttribute("EmitDuration")
		if duration and duration > 0 then
			instance.Enabled = true
			task.delay(duration, function()
				instance.Enabled = false
			end)
		end
	end

	task.spawn(function()
		for _, emitter in ipairs(instance:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				local duration = emitter:GetAttribute("EmitDuration")
				if duration and duration > 0 then
					emitter.Enabled = true
					task.delay(duration, function()
						emitter.Enabled = false
					end)
					continue
				end

				local count = emitter:GetAttribute("EmitCount")
				if count then
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					task.delay(emitDelay, function()
						emitter:Emit(count)
					end)
				end
			elseif emitter:IsA("Beam") then
				local duration = emitter:GetAttribute("EmitDuration")
				if duration and duration > 0 then
					emitter.Enabled = true
					task.delay(duration, function()
						emitter.Enabled = false
					end)
				end
			elseif emitter:IsA("Attachment") or emitter:IsA("Folder") or emitter:IsA("Model") or emitter:IsA("BasePart") then
				Module.Emit(emitter)
			end
		end
	end)
end

function Module.EnableEmitting(instance: Instance, onlyChildren: boolean?)
	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		instance.Enabled = true
	end

	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") or emitter:IsA("Beam") or emitter:IsA("Trail") then
			emitter.Enabled = true
		elseif not onlyChildren and emitter:IsA("Attachment") or emitter:IsA("Folder") or emitter:IsA("BasePart") or emitter:IsA("Model") then
			Module.EnableEmitting(emitter)
		end
	end
end

function Module.DisableEmitting(instance: Instance, onlyChildren: boolean?)
	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		instance.Enabled = false
	end

	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") or emitter:IsA("Beam") or emitter:IsA("Trail") then
			emitter.Enabled = false
		elseif not onlyChildren and emitter:IsA("Attachment") or emitter:IsA("Folder") or emitter:IsA("BasePart") or emitter:IsA("Model") then
			Module.DisableEmitting(emitter)
		end
	end
end

function Module.SetTimeScale(instance: Instance, timeScale: number)
	if instance:IsA("ParticleEmitter") then
		instance.TimeScale = timeScale
	end

	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.TimeScale = timeScale
		elseif emitter:IsA("Attachment") or emitter:IsA("Folder") or emitter:IsA("BasePart") or emitter:IsA("Model") then
			Module.SetTimeScale(emitter, timeScale)
		end
	end
end

function Module.FadeInParticleEmitter(instance: Instance, duration: number)
	if instance:IsA("ParticleEmitter") then
		instance.Transparency = NumberSequence.new(1) -- Start as fully transparent
		instance.Enabled = true

		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local goal = {Transparency = NumberSequence.new(0)} -- Fade to fully visible

		local tween = TS:Create(instance, tweenInfo, goal)
		tween:Play()
	end
end

return Module
