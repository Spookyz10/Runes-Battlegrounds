local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {
	Bump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		return c
	end;

	BigBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.8, 0.8, 0.8)
		return c
	end;
	
	SmallBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.01, 0.01, 0.01)
		return c
	end;
	
	Explosion = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		return c
	end;
	
	Impact = function()
		local c = CameraShakeInstance.new(10, 20, 0, 2)
		c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
		return c
	end;
	
	BumpRemaked = function()
		local c = CameraShakeInstance.new(2, 5, 0, 1)
		c.PositionInfluence = Vector3.new(0.2, 0.2, 0.2)
		return c
	end;
		
	BigExplosion = function()
		local c = CameraShakeInstance.new(20, 40, 0, 2)
		c.PositionInfluence = Vector3.new(0.55, 0.55, 0.55)
		return c
	end;
	
	ReallyBigExplosion = function()
		local c = CameraShakeInstance.new(30, 50, 0, 1.5)
		c.PositionInfluence = Vector3.new(1, 1, 1)
		return c
	end;
	
	SmallExplosion = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		return c
	end;
	
	ExplosionNormal = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(3,3,3)
		return c
	end;

	Earthquake = function()
		local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		return c
	end;
	
	BadTrip = function()
		local c = CameraShakeInstance.new(10, 0.15, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0.15)
		return c
	end;
	
	HandheldCamera = function()
		local c = CameraShakeInstance.new(1, 0.25, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		return c
	end;
	
	Vibration = function()
		local c = CameraShakeInstance.new(2, 20, 2, 2)
		c.PositionInfluence = Vector3.new(0, 0.15, 0)
		return c
	end;
	
	RoughDriving = function()
		local c = CameraShakeInstance.new(1, 2, 1, 1)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		return c
	end
	
	
}


return setmetatable({}, {
	__index = function(t, i)
		local f = CameraShakePresets[i]
		if (type(f) == "function") then
			return f()
		end
		error("No preset found with index \"" .. i .. "\"")
	end;
})