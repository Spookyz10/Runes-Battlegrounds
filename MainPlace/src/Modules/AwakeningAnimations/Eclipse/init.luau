local Eclipse = {}

local Solar = require(script.Solar)
local Lunar = require(script.Lunar)

function Eclipse:Activate(Player)
	local Mode = Player:GetAttribute("MovesetMode_Eclipse")

	if Mode == "Solar" then
		Solar:Activate(Player)
	elseif Mode == "Lunar" then
		Lunar:Activate(Player)
	end
end

return Eclipse
