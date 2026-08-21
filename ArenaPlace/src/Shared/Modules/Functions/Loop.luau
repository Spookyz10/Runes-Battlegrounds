local RunService = game:GetService("RunService")

local Loop = {}

function Loop.new(Function, Rate, Yield)
	Rate = 1 / (Rate or 60)

	local pastTime = 0
	local deltaTime = 0
	local doLoop = true

	local function stopLoop()
		doLoop = false
	end

	local function loopFunction()
		while doLoop do
			pastTime += deltaTime

			while Rate <= pastTime do
				Function(stopLoop)

				pastTime -= Rate

				if not doLoop then
					break
				end
			end

			deltaTime = RunService.RenderStepped:Wait()
		end
	end

	if not Yield then
		task.spawn(loopFunction)
	else
		loopFunction()
	end

	return stopLoop
end

return Loop
