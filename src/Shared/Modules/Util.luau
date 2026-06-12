local RNS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Util = {}
local TempFunctions = {}

local function Lerp(x, y, z)
    return x + (y - x) * z
end

function Util:Lerp(a1, a2, t)
	return a1 + (a2 - a1) * t
end

function Util:AddTempFunction(v16, v17)
	local v18 = v17 or true
	local v19 = nil
	v19 = if v18 then {
		callback = v16, 
		Creation = os.clock(), 
		HasWarned = false, 
		traceback = debug.traceback()
	} else {
			callback = v16, 
			DONTWARN = true
		}
	table.insert(TempFunctions, v19)
end

function Util:UnixConnection(Time, Function)
	if not Function then return end
	
    local LoopType = if RNS:IsClient() then RNS.RenderStepped else RNS.Heartbeat
	local Connection, HasTimePassed, startClock = nil, false, os.clock()
    Connection = LoopType:Connect(function(deltaTime)
		HasTimePassed = not (startClock + Time > os.clock())
		
		if not HasTimePassed then
			local passedTime = (os.clock() - startClock) / Time
			local lerp = Lerp(1, 0, passedTime)
			Function(passedTime, deltaTime, lerp, os.clock() - startClock)
		else
			Connection:Disconnect()

			if Function and HasTimePassed then
				Function(1, deltaTime, 0, Time)
			end
		end
    end)
    return Connection
end

function Util:UnixConnection2(Time, Function, CheckFunction, ExtraFunction)
	local DoFunction, DidFunction, startTick = false, false, tick()
	
	Util:AddTempFunction(function(v76)
		DoFunction = not (startTick + Time > tick())
		
		if Function and (not (not CheckFunction or not CheckFunction()) or CheckFunction == nil) and not DoFunction then
			local v77 = (tick() - startTick) / Time
			
			Function(v77, v76, Lerp(1, 0, v77), tick() - startTick)
			
			return
				
		elseif not DidFunction then
			DidFunction = true
			
			if Function and DoFunction then
				Function(1, v76, 0, Time)
			end
			
			if ExtraFunction then
				ExtraFunction(1, v76, 0)
			end
			
			return true
			
		else
			return
				
		end
	end)
end


(if RNS:IsServer() then RNS.Heartbeat else RNS.RenderStepped):Connect(function(v103)
	for _, v108 in pairs(TempFunctions) do
		if v108.callback(v103) then
			table.remove(TempFunctions, table.find(TempFunctions, v108))
		end
	end
end)


return Util