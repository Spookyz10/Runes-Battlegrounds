local RNS = game:GetService('RunService')

local module = {}
module.__index = module

function module.new(AnimationTrack: AnimationTrack)
	local Object = setmetatable({}, module)
	Object.AnimationTrack = AnimationTrack
	Object.Events = {}
	Object.Playing = false
	Object.StoppedFunctions = {}
	Object.Tasks = {}
	Object.StoppedConnection = nil

	return Object
end

function module:AddEvent(EventName: string, Timestamps, Function)
	if EventName == 'Stopped' then
		table.insert(self.StoppedFunctions, Function)
	else
		if self.Playing == false then
			self.Events[EventName] = { Timestamps = Timestamps, Function = Function }
		else
			for _,Timestamp in Timestamps do
				pcall(function()
					task.delay(Timestamp, Function)
				end)
			end
		end
	end
end

function module:Play()
	self.Playing = true

	self.StoppedFunction = function()
		if not self then return end


		for _,Task in self.Tasks do
			pcall(function()
				task.cancel(Task)
			end)
		end


		task.spawn(function()
			for _,Function in self.StoppedFunctions do
				Function()
			end
		end)


		if self.StoppedConnection then
			self.StoppedConnection:Disconnect()
			self.StoppedConnection = nil
		end

		self.Playing = false
		self.Events = {}

		setmetatable(self, nil)
	end

	self.StoppedConnection = self.AnimationTrack.Stopped:Once(self.StoppedFunction)


	for Name, Data in self.Events do
		for _,Timestamp in Data.Timestamps do
			local Task = task.delay(Timestamp, Data.Function)

			table.insert(self.Tasks, Task)
		end
	end
end

function module:Stop()
	self.StoppedFunction()

	if self.StoppedConnection then
		self.StoppedConnection:Disconnect()
		self.StoppedConnection = nil
	end

	self.Playing = false
	self.Events = {}

	setmetatable(self, nil)
end

return module
