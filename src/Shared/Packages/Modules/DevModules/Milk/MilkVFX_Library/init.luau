local v1 = {}

local v2 = script.Modules
v1.Lighting = require(v2.Lighting)
v1.Particles = require(v2.Particles)
v1.Highlight = require(v2.Highlight)

for _, v3 in pairs({
	v1.Lighting,
	v1.Particles,
	v1.Highlight
}) do
	for v4, v5 in pairs(v3) do
		if type(v5) == "function" then
			v1[v4] = v5
		end
	end
end

return v1
