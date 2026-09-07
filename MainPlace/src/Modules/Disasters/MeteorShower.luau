local Runtime = require(script.Parent.WeatherRuntime)
return {
	Name = "Meteor shower",
	Duration = 300,
	Start = function()
		local event = Runtime.new("MeteorShower")
		event:Loop(1, function()
			event:Fall("Meteor", 15, 12)
		end)
		return function()
			event:Destroy()
		end
	end,
}
